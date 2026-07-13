# scripts-linux

Provisionamento sequencial para VM ou maquina Linux de desenvolvimento.

## O que entrega

- Base apt para Debian e Ubuntu
- Estrutura `~/lab` para organizar projetos e arquivos
- Ferramentas de terminal
- Node.js via NVM
- GitHub SSH
- Python, Java, Ruby e PHP
- PM2 para processos Node
- Manual com o papel de cada pacote

## Como usar

Entrada recomendada:

```bash
chmod +x start.sh setup-dev.sh 00-structure.sh 01-base.sh 02-terminal.sh 03-languages.sh 04-node.sh 05-ssh.sh
./start.sh
```

Fluxo direto completo:

```bash
./setup-dev.sh
```

Se quiser pular partes:

```bash
./setup-dev.sh --skip-ssh --skip-node
```

## Estrutura

- `00-structure.sh`: cria `~/lab`
- `start.sh`: menu central com explicacao de cada etapa
- `setup-dev.sh`: orquestrador principal
- `01-base.sh`: base do sistema
- `02-terminal.sh`: ferramentas de terminal
- `03-languages.sh`: Python, Java, Ruby e PHP
- `04-node.sh`: NVM, Node.js e PM2
- `05-ssh.sh`: GitHub SSH
- `docs/manual.md`: manual do que cada item faz
- `LICENSE`: licenca do projeto

## O que instala

Veja o detalhamento em [`docs/manual.md`](docs/manual.md).

## Ideia do repo

Manter um unico fluxo para preparar ambiente de desenvolvimento com foco em:

- JS e front-end
- Java
- Python
- Ruby
- PHP
- Git e GitHub
- produtividade em terminal
