#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_script() {
  local script_path="$1"
  if [[ ! -x "$script_path" ]]; then
    chmod +x "$script_path" 2>/dev/null || true
  fi
  "$script_path"
}

pause() {
  printf '\nPressione Enter para voltar ao menu...'
  read -r _
}

show_details() {
  local title="$1"
  shift
  printf '\n%s\n' "$title"
  printf '%s\n' "----------------------------------------"
  for line in "$@"; do
    printf '%s\n' "$line"
  done
  printf '\n'
}

menu() {
  clear 2>/dev/null || true
  cat <<'EOF'
========================================
 scripts-linux :: centro de instalacao
========================================

Escolha uma etapa para ver detalhes e executar:

  1) Estrutura ~/lab
  2) Base do sistema
  3) Ferramentas de terminal
  4) Stacks de linguagem
  5) Node.js via NVM e PM2
  6) GitHub SSH
  7) Instalacao completa
  8) Mostrar mapa dos scripts
  0) Sair
EOF
  printf '\nOpcao: '
}

map_scripts() {
  show_details \
    "Mapa dos scripts" \
    "00-structure.sh -> cria ~/lab com projetos, repos, scripts, homologacao, backups e downloads" \
    "setup-dev.sh  -> orquestrador completo com todas as etapas" \
    "start.sh      -> menu central com explicacao e disparo dos blocos" \
    "01-base.sh -> base do sistema" \
    "02-terminal.sh -> ferramentas de terminal e produtividade" \
    "03-languages.sh -> Python, Java, Ruby e PHP" \
    "04-node.sh -> NVM, Node LTS e PM2" \
    "05-ssh.sh -> chave SSH e GitHub"
}

confirm_and_run() {
  local label="$1"
  local description="$2"
  local script_path="$3"

  show_details "$label" "$description"
  printf 'Executar agora? [s/N]: '
  read -r answer
  case "$answer" in
    s|S|sim|SIM|y|Y|yes|YES)
      run_script "$script_path"
      ;;
    *)
      printf 'Cancelado.\n'
      ;;
  esac
  pause
}

while true; do
  menu
  read -r choice

  case "$choice" in
    1)
      confirm_and_run \
        "Estrutura ~/lab" \
        "Cria a organizacao pessoal do ambiente em ~/lab com as pastas projetos, repos, scripts, homologacao, backups e downloads. Isso serve como base para separar trabalho, testes e arquivos temporarios." \
        "$ROOT_DIR/00-structure.sh"
      ;;
    2)
      confirm_and_run \
        "Base do sistema" \
        "Instala utilitarios essenciais para qualquer VM de desenvolvimento: curl, wget, git, build-essential, certificados, zip/unzip, SSH client, gnupg, lsb-release, pkg-config, make e rsync." \
        "$ROOT_DIR/01-base.sh"
      ;;
    3)
      confirm_and_run \
        "Ferramentas de terminal" \
        "Instala tmux, htop, tree, jq, ripgrep, fd-find, fzf, btop, bat, fastfetch, eza e zoxide. Aqui entram produtividade, visualizacao e navegacao no terminal." \
        "$ROOT_DIR/02-terminal.sh"
      ;;
    4)
      confirm_and_run \
        "Stacks de linguagem" \
        "Instala Python 3 com pip e venv, JDK e Maven, Ruby, PHP CLI com modulos comuns e Composer. Esta etapa cobre JS indiretamente via Node em outra etapa." \
        "$ROOT_DIR/03-languages.sh"
      ;;
    5)
      confirm_and_run \
        "Node.js via NVM e PM2" \
        "Instala NVM, baixa Node.js LTS, define a versao padrao e instala PM2 para gerenciamento de processos Node." \
        "$ROOT_DIR/04-node.sh"
      ;;
    6)
      confirm_and_run \
        "GitHub SSH" \
        "Configura chave SSH ed25519, ssh-agent, ~/.ssh/config e permite informar nome e e-mail do Git global se quiser." \
        "$ROOT_DIR/05-ssh.sh"
      ;;
    7)
      confirm_and_run \
        "Instalacao completa" \
        "Executa o fluxo inteiro do setup: base do sistema, terminal, linguagens, Node/NVM, PM2 e SSH GitHub." \
        "$ROOT_DIR/setup-dev.sh"
      ;;
    8)
      map_scripts
      pause
      ;;
    0|q|Q|sair|SAIR|exit)
      exit 0
      ;;
    *)
      printf '\nOpcao invalida.\n'
      pause
      ;;
  esac
done
