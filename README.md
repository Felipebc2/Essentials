<div align="center">
  <h1> Mint_Script </h1>
  <h4><b>Instalador Safe-mode para Linux Mint / Ubuntu (22.04 / 24.04)</h4>
</div>

<br>

# Informativos
Este script automatiza o setup inicial de um ambiente de desenvolvimento de forma **segura**:  
- Não executa *pipes remotos* (`curl | sh`)  
- Não sobrescreve pacotes do sistema com `pip` (usa `--user` ou cria um `venv`)  
- Faz backups de arquivos modificados  
- Baixa instaladores apenas para `/tmp`, com permissão segura, para inspeção manual  
- Pergunta antes de instalar pacotes APT  

---

## ✨ O que o script faz
- Detecta sistema e usuário alvo (`SUDO_USER` ou UID 1000).  
- Faz backup de arquivos como `~/.bashrc`, `.gdbinit`, configs do fish.  
- Ajusta o `PATH` para incluir `~/.local/bin`, `~/.cargo/bin` e `~/.venvs/tools/bin`.  
- Oferece instalação opcional de pacotes APT comuns (build-essential, git, vim, htop, etc).  
- Instala pacotes Python em modo seguro:  
  - Tenta `pip install --user`  
  - Se bloqueado (PEP 668), cria automaticamente um venv em `~/.venvs/tools` e instala lá.  
- Baixa scripts de instaladores (rustup, GEF, Burp) em `/tmp` para inspeção manual.  
- Configurações mínimas para GDB.  
- Sugere instalação opcional do `cargo pwninit`.  

---

## 📦 Requisitos
- Linux Mint / Ubuntu recente  
- `bash`  
- `curl` ou `wget`  

---

## 🚀 Como usar
Clone ou baixe o script, torne-o executável e rode com sudo:

```bash
chmod +x ~/repo/essentials/scripts/mint_Script.sh
sudo bash ./setup-mint-safe.sh
```

## ✅ Checklist de segurança

O script imprime no final os caminhos de scripts baixados em `/tmp`.  
Antes de executar qualquer um, **sempre valide**:

```bash
# inspecione o conteúdo
less /tmp/rustup-init.*.sh
less /tmp/gef_install.*.sh
less /tmp/burp-community.*.sh

# calcule SHA256 e compare com fonte oficial (se disponível)
sha256sum /tmp/rustup-init.*.sh
sha256sum /tmp/gef_install.*.sh
sha256sum /tmp/burp-community.*.sh
```

Depois, se estiver tudo certo, execute manualmente como usuário (não como root):

```bash
# instalar rustup como usuário alvo
sudo -H -u "$USER" bash /tmp/rustup-init.*.sh -y

# instalar GEF como usuário alvo
sudo -H -u "$USER" bash /tmp/gef_install.*.sh

# Burp (se baixado e se for um installer executável)
sudo bash /tmp/burp-community.*.sh
```

> **Importante:** só execute os instaladores depois de inspecionar e verificar checksums/assinaturas.  
> Se tiver dúvidas, rode os passos numa VM/snapshot.

---

## 📂 Alterações feitas

O script pode criar / modificar os seguintes itens:

- **Backups:** `/root/setup-safe-backups-<timestamp>/...` (cópias dos arquivos que foram alterados).  
- **Arquivo de shell do usuário:** adiciona linhas em `~/.bashrc` como:
  - `export PATH="$HOME/.local/bin:$PATH"`
  - `export PATH="$HOME/.cargo/bin:$PATH"`
  - (se criado) `export PATH="$HOME/.venvs/tools/bin:$PATH"`
- **Fish:** adiciona linhas em `~/.config/fish/config.fish` com `set -x PATH ...` quando aplicável.  
- **Venv (opcional):** `~/.venvs/tools` criado se `pip --user` estiver bloqueado (PEP 668).  
- **Scripts baixados:** `/tmp/rustup-init.*.sh`, `/tmp/gef_install.*.sh`, `/tmp/burp-community.*.sh` (mantidos para inspeção).  
- **GDB configs:** `~/.gdbinit` e `~/.config/gdb/gdbearlyinit` (configuração mínima escrita).  

---

## 🛠 Troubleshooting rápido

- **`command not found` ao executar o script**  
  Execute com:
```bash
  chmod +x setup-mint-safe.sh
  sudo ./setup-mint-safe.sh
  # ou
  sudo bash setup-mint-safe.sh
```

| Evite usar `source`.

- **`pip` bloqueado por PEP 668**  
  O script faz fallback criando `~/.venvs/tools` e instala os pacotes lá. Para usar os binários:
```fish
  # fish
  source ~/.venvs/tools/bin/activate.fish
  # bash/zsh
  source ~/.venvs/tools/bin/activate
```

- **Usuário alvo incorreto (`TARGET_USER`)**  
  Execute especificando a variável:
```bash
  sudo TARGET_USER=seuusuario ./setup-mint-safe.sh
```
- **Backup não criado (perms/ACL)**  
  O script registra avisos se a cópia de backup falhar; verifique `/root/setup-safe-backups-<timestamp>/` e ajuste permissões se necessário.

---
