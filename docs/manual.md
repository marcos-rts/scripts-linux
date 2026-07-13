# Manual de Provisionamento

Este repositorio existe para preparar uma VM ou maquina Linux para desenvolvimento com uma base unica e sequencial.

## O que o setup faz

1. Cria a estrutura `~/lab` com pastas de trabalho.
1. Atualiza o sistema e instala dependencias base.
1. Instala ferramentas de terminal e navegacao.
1. Instala stacks de linguagem para Python, Java, Ruby e PHP.
1. Instala Node.js via NVM e o PM2.
1. Configura Git e a chave SSH para GitHub.

## Compatibilidade

O script principal detecta:

- Debian 11
- Debian 12
- Debian 13
- Ubuntu nas linhas suportadas pela sua instalacao APT

Quando um pacote nao existe no repositorio atual, ele e ignorado sem quebrar a sequencia.

## Pacotes e para que servem

### Estrutura de trabalho

- `~/lab/projetos`: area principal para projetos em andamento.
- `~/lab/repos`: clones e repositorios auxiliares.
- `~/lab/scripts`: scripts pessoais ou de automacao.
- `~/lab/homologacao`: testes e validacao antes de subir algo.
- `~/lab/backups`: copias e snapshots.
- `~/lab/downloads`: downloads temporarios do ambiente.

### Base do sistema

- `curl`: baixar scripts e instaladores da web.
- `wget`: alternativa para downloads no terminal.
- `git`: controle de versao.
- `build-essential`: compilador e ferramentas para build nativo.
- `ca-certificates`: certificados confiaveis para HTTPS.
- `software-properties-common`: utilitarios para repositorios e PPAs.
- `zip` e `unzip`: compactacao e descompactacao.
- `openssh-client`: acesso SSH para GitHub e servidores.
- `gnupg`: assinatura e verificacao de chaves.
- `lsb-release`: informacoes da distro.
- `pkg-config`: ajuda compilacoes a localizar bibliotecas.
- `make`: automacao de builds.
- `rsync`: sincronizacao de arquivos.

### Terminal e produtividade

- `tmux`: manter sessoes persistentes, dividir o terminal e voltar depois sem perder trabalho.
- `htop`: monitor interativo de processos.
- `tree`: visualizar arvores de diretorios.
- `jq`: manipular JSON no terminal.
- `ripgrep`: busca rapida em arquivos.
- `fd-find`: busca simples e rapida de arquivos.
- `fzf`: busca fuzzy interativa.
- `btop`: monitor grafico de recursos no terminal.
- `bat`: visualizador de arquivos com realce.
- `fastfetch`: resumo rapido do sistema.
- `eza`: substituto moderno do `ls`.
- `zoxide`: navegacao inteligente por diretorios.

### Python

- `python3`: runtime principal.
- `python3-pip`: instalador de pacotes Python.
- `python3-venv`: ambientes virtuais.
- `pip` atualizado via `python3 -m pip`: garante instalacao de pacotes do usuario.
- `virtualenv`: isolacao de projetos antigos ou especificos.
- `httpie`: cliente HTTP amigavel para testar APIs.

### Java

- `default-jdk`: JDK padrao da distro.
- `maven`: gerenciamento de build e dependencias Java.

### Ruby

- `ruby-full`: runtime Ruby e ferramentas basicas.

### PHP

- `php-cli`: runtime PHP para linha de comando.
- `php-common`: base comum dos modulos.
- `php-curl`: acesso HTTP em PHP.
- `php-mbstring`: suporte a strings multibyte.
- `php-xml`: manipulacao de XML.
- `php-zip`: suporte a arquivos zip.
- `composer`: gerenciador de dependencias PHP.

### Node.js e ecossistema

- `nvm`: gerencia multiplas versoes de Node.
- `node` LTS: runtime principal para JS e front-end tooling.
- `npm`: gerenciador de pacotes do Node.
- `pm2`: gerenciamento de processos Node em producao ou laboratorio.

### GitHub SSH

- `ssh-keygen`: cria a chave SSH.
- `ssh-agent`: carrega a chave na sessao.
- `~/.ssh/config`: fixa GitHub com `IdentityFile` dedicado.

## Ordem de uso recomendada

1. Rodar `start.sh` para escolher a etapa ou `setup-dev.sh` para executar tudo.
1. Abrir um novo terminal ou executar `source ~/.bashrc`.
1. Conferir a chave SSH e cadastrar no GitHub.
1. Usar `tmux` para sessoes longas.
1. Usar `nvm` para instalar outras versoes de Node quando precisar.

## Comandos uteis depois da instalacao

```bash
tmux new -s dev
tmux ls
tmux attach -t dev
pm2 startup
pm2 save
eval "$(zoxide init bash)"
```

## Mapa dos scripts

- `00-structure.sh`: cria `~/lab` com as pastas antigas do documento.
- `start.sh`: menu central que explica cada bloco antes de executar.
- `setup-dev.sh`: fluxo completo e sequencial de provisionamento.
- `01-base.sh`: instala a base do sistema.
- `02-terminal.sh`: instala ferramentas de terminal e produtividade.
- `03-languages.sh`: instala Python, Java, Ruby e PHP.
- `04-node.sh`: instala NVM, Node LTS e PM2.
- `05-ssh.sh`: configura GitHub SSH.

## Observacao sobre Linux desktop

O provisionamento foi pensado para VM e maquina de desenvolvimento. Ele evita customizacoes agressivas de interface e foca em utilitarios de terminal, linguagem e automacao.
