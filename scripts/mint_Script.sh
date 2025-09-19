#!/bin/bash
# setup-mint-safe.sh — Safe-mode para Linux Mint / Ubuntu 24.04 (com fallback venv)
set -euo pipefail
umask 022

# ----------------- CONFIG -----------------
CLEANUP_TMP=false
ASK_BEFORE_APT=true
APT_PACKAGES=(build-essential git curl wget vim htop unzip tmux python3-pip)
PY_PACKAGES=(ROPgadget ipython pwntools pycryptodome ropper scapy sympy tqdm xortool z3-solver)
# ------------------------------------------

log() { printf '[%s] %s\n' "$(date +'%F %T')" "$1"; }
is_tty() { [[ -t 0 ]]; }

download() {
  local url="$1" out="$2"
  if command -v curl >/dev/null 2>&1; then
    if ! curl -fsSL -o "$out" "$url"; then
      log "curl falhou para $url"; return 1
    fi
  elif command -v wget >/dev/null 2>&1; then
    if ! wget -qO "$out" "$url"; then
      log "wget falhou para $url"; return 1
    fi
  else
    log "Nem curl nem wget disponíveis."; return 2
  fi
  return 0
}

trap_cleanup() {
  if [[ "${CLEANUP_TMP:-false}" == "true" ]]; then
    log "Cleanup temporários (CLEANUP_TMP=true)."
    rm -f "${RUSTUP_SCRIPT:-}" "${GEF_SCRIPT:-}" "${BURP_SCRIPT:-}" 2>/dev/null || true
  else
    log "Temporários mantidos para inspeção (CLEANUP_TMP=false)."
  fi
}
trap 'trap_cleanup' EXIT

if [[ $EUID -ne 0 ]]; then
  echo "[!] Rode este script como root (sudo). Ex: sudo ./setup-mint-safe.sh"
  exit 1
fi

. /etc/os-release || true
OS_ID=${ID:-unknown}
OS_VER=${VERSION_ID:-unknown}
LSB_VER=$(lsb_release -sr 2>/dev/null || true)
LSB_CODENAME=$(lsb_release -sc 2>/dev/null || echo "${UBUNTU_CODENAME:-}")
log "Detected OS: ID=${OS_ID} VERSION_ID=${OS_VER} LSB=${LSB_VER} CODENAME=${LSB_CODENAME}"

TARGET_USER=${SUDO_USER:-$USER}
if [[ "$TARGET_USER" == "root" && -z "${SUDO_USER:-}" ]]; then
  alt=$(getent passwd 1000 | cut -d: -f1 || true)
  if [[ -n "$alt" ]]; then
    TARGET_USER="$alt"
    log "SUDO_USER não definido; assumindo user alvo: $TARGET_USER (UID 1000)"
  fi
fi
TARGET_HOME=$(eval echo "~$TARGET_USER")
log "Target user: ${TARGET_USER} (home: ${TARGET_HOME})"

if [[ ! -d "$TARGET_HOME" ]]; then
  log "ERRO: diretório home de $TARGET_USER não encontrado: $TARGET_HOME"
  exit 1
fi

BACKUP_DIR="/root/setup-safe-backups-$(date +%Y%m%d%H%M%S)"
mkdir -p "$BACKUP_DIR"
log "Backups irão para: $BACKUP_DIR"

backup_file_if_exists() {
  local f="$1"
  if [[ -e "$f" ]]; then
    local rel="${f#/}"
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    if cp -a "$f" "$BACKUP_DIR/$rel"; then
      log "Backup: $f -> $BACKUP_DIR/$rel"
    else
      log "AVISO: copia de backup falhou para: $f (perms/ACLs?)"
    fi
  fi
}

if [[ ! -f "$TARGET_HOME/.bashrc" ]]; then
  touch "$TARGET_HOME/.bashrc"
  chmod 600 "$TARGET_HOME/.bashrc"
  chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.bashrc" || true
  log "Criado $TARGET_HOME/.bashrc (600)"
fi

add_path_line() {
  local line="$1"
  if ! grep -Fxq "$line" "$TARGET_HOME/.bashrc" 2>/dev/null; then
    backup_file_if_exists "$TARGET_HOME/.bashrc"
    printf "\n# added by setup-mint-safe\n%s\n" "$line" >> "$TARGET_HOME/.bashrc"
    chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.bashrc" || true
    log "Adicionado '$line' em $TARGET_HOME/.bashrc"
  else
    log "Linha já presente em $TARGET_HOME/.bashrc: $line"
  fi
}

add_path_line 'export PATH="$HOME/.local/bin:$PATH"'
add_path_line 'export PATH="$HOME/.cargo/bin:$PATH"'

USER_SHELL=$(getent passwd "$TARGET_USER" | cut -d: -f7 || echo "")
if [[ "$USER_SHELL" == *fish ]]; then
  FISH_CFG="$TARGET_HOME/.config/fish/config.fish"
  if [[ ! -f "$FISH_CFG" ]]; then
    mkdir -p "$(dirname "$FISH_CFG")"
    touch "$FISH_CFG"
    chown "$TARGET_USER:$TARGET_USER" "$FISH_CFG" || true
  fi
  if ! grep -q "# added by setup-mint-safe" "$FISH_CFG" 2>/dev/null; then
    backup_file_if_exists "$FISH_CFG"
    {
      echo "# added by setup-mint-safe"
      echo 'set -x PATH $HOME/.local/bin $PATH'
      echo 'set -x PATH $HOME/.cargo/bin $PATH'
    } >> "$FISH_CFG"
    chown "$TARGET_USER:$TARGET_USER" "$FISH_CFG" || true
    log "Atualizado PATH no fish ($FISH_CFG)."
  else
    log "Fish config já contém marca do setup-mint-safe."
  fi
fi

if [[ "${ASK_BEFORE_APT}" == "true" ]]; then
  echo "Pacotes propostos: ${APT_PACKAGES[*]}"
  if is_tty; then
    read -r -t 30 -p "Instalar estes pacotes agora? (y/N) [30s, padrão=N]: " ans || ans="n"
  else
    log "Sem TTY detectado; padrão = Não instalar APT."
    ans="n"
  fi
  if [[ "${ans,,}" == "y" ]]; then DO_APT_INSTALL=true; else DO_APT_INSTALL=false; fi
else
  DO_APT_INSTALL=false
fi

if [[ "${DO_APT_INSTALL:-false}" == "true" ]]; then
  log "APT: atualizando e instalando pacotes essenciais"
  apt-get -o Dpkg::Use-Pty=0 -qq update || { log "apt-get update falhou"; }
  apt-get -o Dpkg::Use-Pty=0 install -y "${APT_PACKAGES[@]}" || log "apt-get install falhou (ver logs)"
else
  log "APT: pulado (safe-mode)"
fi

NET_OK=true
TMP_NET_CHECK="$(mktemp /tmp/check_net.XXXX)" || { log "mktemp falhou para check_net"; TMP_NET_CHECK=""; NET_OK=false; }
if [[ -n "$TMP_NET_CHECK" ]]; then
  if ! download "https://www.google.com" "$TMP_NET_CHECK"; then
    NET_OK=false
    log "Sem conectividade HTTPS estável; downloads remotos serão pulados."
  fi
  rm -f "$TMP_NET_CHECK" || true
fi
$NET_OK || log "Dica: instale 'curl' ou 'wget' para habilitar downloads automáticos."

# ---------------- Python with fallback to venv ----------------
log "Python: tentando instalar pacotes (prefer --user; fallback venv se PEP 668)"
if command -v python3 >/dev/null 2>&1 && python3 -m pip --version >/dev/null 2>&1; then
  # Try pip --user first (as target user)
  if sudo -H -u "$TARGET_USER" bash -lc 'python3 -m pip install --user --upgrade pip >/dev/null 2>&1'; then
    log "pip --user disponível — instalando pacotes (--user)"
    for p in "${PY_PACKAGES[@]}"; do
      log "pip --user install $p (usuario: $TARGET_USER)"
      sudo -H -u "$TARGET_USER" bash -lc "python3 -m pip install --user '$p' || true"
    done
    log "Instalação --user concluída (executáveis em ~/.local/bin)."
  else
    log "pip --user bloqueado (provável PEP 668) — criando venv em ~/.venvs/tools e instalando ali."
    # create venv dir and venv as target user
    sudo -H -u "$TARGET_USER" bash -lc 'mkdir -p "$HOME/.venvs" && python3 -m venv "$HOME/.venvs/tools" || exit 1'
    # upgrade pip inside venv
    sudo -H -u "$TARGET_USER" bash -lc '$HOME/.venvs/tools/bin/pip install --upgrade pip || true'
    # install packages inside venv
    for p in "${PY_PACKAGES[@]}"; do
      log "venv pip install $p (usuario: $TARGET_USER)"
      sudo -H -u "$TARGET_USER" bash -lc '$HOME/.venvs/tools/bin/pip install '"'"$p"'"' || true'
    done
    # ensure PATH lines for venv in .bashrc and fish config
    VENVPATHLINE='export PATH="$HOME/.venvs/tools/bin:$PATH"'
    if ! sudo -H -u "$TARGET_USER" bash -lc "grep -Fxq '$VENVPATHLINE' \"$HOME/.bashrc\" 2>/dev/null"; then
      backup_file_if_exists "$TARGET_HOME/.bashrc"
      printf "\n# added by setup-mint-safe (venv)\n%s\n" "$VENVPATHLINE" >> "$TARGET_HOME/.bashrc"
      chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.bashrc" || true
      log "Adicionado venv PATH em $TARGET_HOME/.bashrc"
    fi
    # fish
    if [[ -f "$TARGET_HOME/.config/fish/config.fish" ]]; then
      if ! sudo -H -u "$TARGET_USER" grep -Fq '.venvs/tools/bin' "$TARGET_HOME/.config/fish/config.fish" 2>/dev/null; then
        printf "\n# added by setup-mint-safe (venv)\nset -x PATH \$HOME/.venvs/tools/bin \$PATH\n" >> "$TARGET_HOME/.config/fish/config.fish"
        chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config/fish/config.fish" || true
        log "Adicionado venv PATH em $TARGET_HOME/.config/fish/config.fish"
      fi
    fi
    log "Venv instalado em $TARGET_HOME/.venvs/tools (usuário: $TARGET_USER)."
  fi
else
  log "python3/pip não disponíveis; pulando instalação Python."
fi
# ------------------------------------------------------------------

# Downloads (rustup, gef, burp) — use mktemp and check
if [[ "$NET_OK" == "true" ]]; then
  RUSTUP_SCRIPT=""
  if RUSTUP_SCRIPT=$(mktemp /tmp/rustup-init.XXXX.sh 2>/dev/null); then
    if download "https://sh.rustup.rs" "$RUSTUP_SCRIPT"; then
      chown "$TARGET_USER:$TARGET_USER" "$RUSTUP_SCRIPT" || true
      chmod 700 "$RUSTUP_SCRIPT" || true
      SZ=$(stat -c%s "$RUSTUP_SCRIPT" 2>/dev/null || echo 0)
      log "rustup salvo ($SZ bytes) em $RUSTUP_SCRIPT"
    else
      rm -f "$RUSTUP_SCRIPT" || true; RUSTUP_SCRIPT=""; log "Falha ao baixar rustup."
    fi
  else
    log "mktemp falhou para rustup script."
  fi

  GEF_SCRIPT=""
  if GEF_SCRIPT=$(mktemp /tmp/gef_install.XXXX.sh 2>/dev/null); then
    if download "https://raw.githubusercontent.com/bata24/gef/dev/install.sh" "$GEF_SCRIPT"; then
      chown "$TARGET_USER:$TARGET_USER" "$GEF_SCRIPT" || true
      chmod 700 "$GEF_SCRIPT" || true
      SZ=$(stat -c%s "$GEF_SCRIPT" 2>/dev/null || echo 0)
      log "GEF salvo ($SZ bytes) em $GEF_SCRIPT"
    else
      rm -f "$GEF_SCRIPT" || true; GEF_SCRIPT=""; log "Falha ao baixar GEF."
    fi
  else
    log "mktemp falhou para GEF script."
  fi

  BURP_SCRIPT=""
  if BURP_SCRIPT=$(mktemp /tmp/burp-community.XXXX.sh 2>/dev/null); then
    if download "https://portswigger.net/burp/releases/startdownload?product=community&version=2025.1.2&type=Linux" "$BURP_SCRIPT"; then
      chown "$TARGET_USER:$TARGET_USER" "$BURP_SCRIPT" || true
      chmod 700 "$BURP_SCRIPT" || true
      SZ=$(stat -c%s "$BURP_SCRIPT" 2>/dev/null || echo 0)
      log "Burp installer salvo ($SZ bytes) em $BURP_SCRIPT"
    else
      rm -f "$BURP_SCRIPT" || true; BURP_SCRIPT=""; log "Burp não baixado automaticamente (provável redirect/token)."
    fi
  else
    log "mktemp falhou para Burp script."
  fi
else
  log "Downloads remotos foram pulados (NET_OK=false)."
fi

# (rest of your script continues: GDB, cargo prompts, final messages, checklist)
USER_GDBINIT="$TARGET_HOME/.gdbinit"
USER_GDBEARLY="$TARGET_HOME/.config/gdb/gdbearlyinit"
backup_file_if_exists "$USER_GDBINIT"
backup_file_if_exists "$USER_GDBEARLY"
mkdir -p "$(dirname "$USER_GDBEARLY")"
cat > "$USER_GDBINIT" <<'GDBINIT'
# basic safe gdb settings
set disassembly-flavor intel
set history save on
set confirm off
set pagination off
GDBINIT
echo 'set startup-quietly on' > "$USER_GDBEARLY"
chown "$TARGET_USER:$TARGET_USER" "$USER_GDBINIT" "$USER_GDBEARLY" || true
log "GDB config escrita para $TARGET_USER."

if sudo -H -u "$TARGET_USER" bash -lc 'command -v cargo >/dev/null 2>&1'; then
  if is_tty; then
    read -r -t 20 -p "Executar 'cargo install pwninit' agora? (y/N) [20s, padrão=N]: " cargo_ans || cargo_ans="n"
  else
    cargo_ans="n"
  fi
  if [[ "${cargo_ans,,}" == "y" ]]; then
    log "Instalando pwninit (cargo) para $TARGET_USER..."
    sudo -H -u "$TARGET_USER" bash -lc 'cargo install pwninit --locked || true'
  else
    log "pwninit instalação pulada pelo usuário."
  fi
else
  log "cargo não detectado para $TARGET_USER; pulei pwninit."
fi

cat <<-EOF

[SAFE-MODE] Concluído.

Arquivos baixados (INSPECIONE antes de executar manualmente):
  - Rustup: ${RUSTUP_SCRIPT:-(não baixado)}
  - GEF:    ${GEF_SCRIPT:-(não baixado)}
  - Burp:   ${BURP_SCRIPT:-(não baixado)}

Backups feitos em: $BACKUP_DIR

Valide integridade (exemplo):
  sha256sum "${RUSTUP_SCRIPT:-/dev/null}" \
            "${GEF_SCRIPT:-/dev/null}" \
            "${BURP_SCRIPT:-/dev/null}" 2>/dev/null || true

Notas:
  - Para instalar rustup (após inspecionar):
      sudo -H -u "$TARGET_USER" bash "$RUSTUP_SCRIPT" -y
  - Para instalar GEF (após inspecionar):
      sudo -H -u "$TARGET_USER" bash "$GEF_SCRIPT"
  - Burp frequentemente exige redirect/token; se não baixou, baixe manualmente do site oficial.

EOF

# Checklist (short)
echo
echo "---- CHECKLIST: inspecione os scripts em /tmp e valide sha256 antes de executar ----"
[[ -n "${RUSTUP_SCRIPT:-}" ]] && echo "less $RUSTUP_SCRIPT; sha256sum $RUSTUP_SCRIPT"
[[ -n "${GEF_SCRIPT:-}" ]] && echo "less $GEF_SCRIPT; sha256sum $GEF_SCRIPT"
[[ -n "${BURP_SCRIPT:-}" ]] && echo "less $BURP_SCRIPT; sha256sum $BURP_SCRIPT"
echo "Se venv foi criado, ative em fish: source ~/.venvs/tools/bin/activate.fish"
echo "----------------------------------------------------------------------------------"
echo

exit 0
