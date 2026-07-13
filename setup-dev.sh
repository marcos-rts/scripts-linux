#!/usr/bin/env bash

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANUAL_FILE="$SCRIPT_DIR/docs/manual.md"

SKIP_BASE=0
SKIP_STRUCTURE=0
SKIP_SHELL=0
SKIP_LANGS=0
SKIP_NODE=0
SKIP_SSH=0
NO_UPGRADE=0

log() {
  local level="$1"
  shift
  printf '\n[%s] %s\n' "$level" "$*"
}

info() {
  log "INFO" "$*"
}

warn() {
  log "WARN" "$*"
}

step() {
  log "STEP" "$*"
}

die() {
  log "ERROR" "$*"
  exit 1
}

run_root() {
  if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

ensure_apt_index() {
  if [[ "$NO_UPGRADE" -eq 0 ]]; then
    run_root apt-get update
  fi
}

apt_install_available() {
  local packages=("$@")
  local installable=()
  local pkg

  for pkg in "${packages[@]}"; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
      installable+=("$pkg")
    else
      warn "Pacote indisponivel no repositorio atual: $pkg"
    fi
  done

  if [[ "${#installable[@]}" -gt 0 ]]; then
    run_root apt-get install -y --no-install-recommends "${installable[@]}"
  fi
}

append_block_once() {
  local file="$1"
  local marker="$2"

  mkdir -p "$(dirname "$file")"
  touch "$file"

  if ! grep -Fq "$marker" "$file"; then
    printf '\n' >>"$file"
    cat >>"$file"
  fi
}

detect_distro() {
  if [[ ! -f /etc/os-release ]]; then
    die "Nao foi possivel detectar a distro: /etc/os-release ausente."
  fi

  # shellcheck disable=SC1091
  source /etc/os-release

  DISTRO_ID="${ID:-unknown}"
  DISTRO_VERSION="${VERSION_ID:-unknown}"
  DISTRO_CODENAME="${VERSION_CODENAME:-unknown}"

  case "$DISTRO_ID" in
    debian|ubuntu) ;;
    *)
      die "Distro nao suportada: ${DISTRO_ID}. Este setup foi feito para Debian e Ubuntu."
      ;;
  esac
}

prepare_workspace_structure() {
  step "1/7 - Criando estrutura de trabalho"

  local workspace_root="$HOME/lab"
  local folders=(
    "$workspace_root/projetos"
    "$workspace_root/repos"
    "$workspace_root/scripts"
    "$workspace_root/homologacao"
    "$workspace_root/backups"
    "$workspace_root/downloads"
  )

  mkdir -p "$workspace_root"
  mkdir -p "${folders[@]}"

  info "Estrutura criada em $workspace_root"
  info "Pastas: projetos, repos, scripts, homologacao, backups e downloads"
}

prepare_base_system() {
  step "2/7 - Preparando sistema base"
  info "Detectado: ${DISTRO_ID} ${DISTRO_VERSION} (${DISTRO_CODENAME})"

  ensure_apt_index

  if [[ "$NO_UPGRADE" -eq 0 ]]; then
    run_root apt-get upgrade -y
  fi

  apt_install_available \
    curl \
    wget \
    git \
    build-essential \
    ca-certificates \
    software-properties-common \
    zip \
    unzip \
    openssh-client \
    gnupg \
    lsb-release \
    pkg-config \
    make \
    rsync
}

install_shell_and_core_tools() {
  step "3/7 - Instalando ferramentas de terminal"

  apt_install_available \
    tmux \
    htop \
    tree \
    jq \
    ripgrep \
    fd-find \
    fzf \
    btop \
    bat \
    fastfetch \
    eza

  if have_cmd fdfind && ! have_cmd fd; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi

  if have_cmd batcat && ! have_cmd bat; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  fi

  if ! have_cmd zoxide; then
    info "Instalando zoxide via script oficial"
    curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
  fi

  append_block_once "$HOME/.bashrc" "# >>> scripts-linux shell block >>>" <<'EOF'
# >>> scripts-linux shell block >>>
alias ll='ls -lah'
alias la='ls -A'
alias gs='git status'
alias gp='git pull'
alias gc='git commit'
alias ..='cd ..'
alias ...='cd ../..'

if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  alias fd='fdfind'
fi

if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
  alias bat='batcat'
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi
# <<< scripts-linux shell block <<<
EOF
}

install_language_stacks() {
  step "4/7 - Instalando stacks de linguagem"

  apt_install_available \
    python3 \
    python3-pip \
    python3-venv \
    default-jdk \
    maven \
    ruby-full \
    php-cli \
    php-common \
    php-curl \
    php-mbstring \
    php-xml \
    php-zip \
    composer

  if have_cmd python3; then
    python3 -m pip install --user --upgrade pip virtualenv httpie
  fi
}

install_node_stack() {
  step "5/7 - Instalando Node.js via NVM"

  if [[ ! -d "$HOME/.nvm" ]]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
  else
    info "NVM ja existe em $HOME/.nvm"
  fi

  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"

  if ! have_cmd nvm; then
    die "NVM nao ficou disponivel apos a instalacao."
  fi

  nvm install --lts
  nvm alias default 'lts/*'
  nvm use --lts

  if have_cmd corepack; then
    corepack enable || true
  fi

  npm install -g pm2
  pm2 completion install >/dev/null 2>&1 || true
}

configure_git_and_github_ssh() {
  step "6/7 - Configurando Git e SSH para GitHub"

  if [[ -n "${GIT_NAME:-}" ]]; then
    git config --global user.name "${GIT_NAME}"
  fi

  if [[ -n "${GIT_EMAIL:-}" ]]; then
    git config --global user.email "${GIT_EMAIL}"
  fi

  local github_email="${GITHUB_EMAIL:-${GIT_EMAIL:-}}"
  if [[ -z "$github_email" ]]; then
    if have_cmd git; then
      github_email="$(git config --global user.email 2>/dev/null || true)"
    fi
  fi

  if [[ -z "$github_email" && -t 0 ]]; then
    read -r -p "Email do GitHub para a chave SSH (enter para pular): " github_email
  fi

  if [[ -z "$github_email" ]]; then
    warn "Pulando configuracao de SSH porque nenhum e-mail foi informado."
    return 0
  fi

  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  local key_file="$HOME/.ssh/id_ed25519"
  if [[ ! -f "$key_file" ]]; then
    ssh-keygen -t ed25519 -C "$github_email" -f "$key_file" -N ""
  fi

  if have_cmd ssh-agent; then
    eval "$(ssh-agent -s)" >/dev/null
    ssh-add "$key_file" >/dev/null 2>&1 || true
  fi

  append_block_once "$HOME/.ssh/config" "Host github.com" <<'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
EOF

  chmod 600 "$HOME/.ssh/config"

  info "Chave publica pronta. Adicione no GitHub se ainda nao cadastrou:"
  printf '\n'
  cat "${key_file}.pub"
  printf '\n'
}

print_manual_hint() {
  step "7/7 - Finalizando"
  info "Repositorio documentado em: $MANUAL_FILE"
  info "Se este foi o primeiro setup, abra um novo shell ou rode: source ~/.bashrc"

  if have_cmd node; then
    info "Node: $(node -v)"
  fi

  if have_cmd npm; then
    info "npm: $(npm -v)"
  fi

  if have_cmd python3; then
    info "Python: $(python3 --version)"
  fi

  if have_cmd java; then
    info "Java: $(java -version 2>&1 | head -n 1)"
  fi

  if have_cmd php; then
    info "PHP: $(php -v | head -n 1)"
  fi

  if have_cmd ruby; then
    info "Ruby: $(ruby -v)"
  fi
}

usage() {
  cat <<'EOF'
Uso:
  ./setup-dev.sh [opcoes]

Opcoes:
  --skip-base        Pula pacotes base do sistema
  --skip-structure   Pula a criacao da estrutura ~/lab
  --skip-shell       Pula ferramentas de terminal e shell
  --skip-languages   Pula stacks Python, Java, Ruby e PHP
  --skip-node        Pula NVM, Node.js e PM2
  --skip-ssh         Pula configuracao de GitHub SSH
  --no-upgrade       Nao roda apt upgrade
  -h, --help         Mostra esta ajuda

Variaveis opcionais:
  GIT_NAME, GIT_EMAIL, GITHUB_EMAIL
EOF
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skip-base) SKIP_BASE=1 ;;
      --skip-structure) SKIP_STRUCTURE=1 ;;
      --skip-shell) SKIP_SHELL=1 ;;
      --skip-languages) SKIP_LANGS=1 ;;
      --skip-node) SKIP_NODE=1 ;;
      --skip-ssh) SKIP_SSH=1 ;;
      --no-upgrade) NO_UPGRADE=1 ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Opcao desconhecida: $1"
        ;;
    esac
    shift
  done

  detect_distro

  if [[ "$SKIP_STRUCTURE" -eq 0 ]]; then
    prepare_workspace_structure
  fi

  if [[ "$SKIP_BASE" -eq 0 ]]; then
    prepare_base_system
  fi

  if [[ "$SKIP_SHELL" -eq 0 ]]; then
    install_shell_and_core_tools
  fi

  if [[ "$SKIP_LANGS" -eq 0 ]]; then
    install_language_stacks
  fi

  if [[ "$SKIP_NODE" -eq 0 ]]; then
    install_node_stack
  fi

  if [[ "$SKIP_SSH" -eq 0 ]]; then
    configure_git_and_github_ssh
  fi

  print_manual_hint
}

main "$@"
