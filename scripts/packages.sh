#!/usr/bin/env bash
# packages.sh - instala meus pacotes favoritos no Linux MInt (APT)

set -euo pipefail

# ===== LISTA DE PACOTES =====
PACKAGES=(
  fzf
  htop
  tree
  tmux
)

# Atualiza indices e instala so o que faltar
if [[ $EUID -ne 0 ]]; then
  SUDO="sudo"
else
  SUDO=""
fi

$SUDO apt update -y

for pkg in "${PACKAGES[@]}"; do
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    echo "[ok] $pkg ja instalado"
  else
    echo "[*] instalando $pkg..."
    $SUDO apt install -y "$pkg"
  fi
done

echo "Tudo Pronto!"
