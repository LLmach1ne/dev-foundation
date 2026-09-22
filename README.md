# DEV FOUNDATION

Base metodológica e técnica para desenvolvimento de software assistido por ChatGPT e Codex.

## Objetivo

Manter um processo de desenvolvimento que seja:

- reproduzível;
- portátil entre computadores;
- rastreável;
- proporcional à complexidade do projeto;
- eficiente no uso de modelos e contexto;
- seguro contra alterações destrutivas;
- orientado por requisitos, evidências e testes.

## Estado atual

A Foundation está em construção.

Versão de desenvolvimento: `0.1.0-dev`

## Começo rápido em outro computador Windows

Este roteiro cria um projeto; os requisitos, limites e diagnósticos completos
estão em [Environment Standard](docs/ENVIRONMENT_STANDARD.md).

1. Instale os pré-requisitos humanos aplicáveis e clone a Foundation:

   ```powershell
   git clone https://github.com/LLmach1ne/dev-foundation.git C:\Dev\00-foundation\dev-foundation
   Set-Location C:\Dev\00-foundation\dev-foundation
   git switch main
   ```

2. Verifique PowerShell e Git. Se a política bloquear a execução do gerador,
   libere somente a sessão atual:

   ```powershell
   Get-ExecutionPolicy -List
   git --version
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
   ```

   Execute o último comando apenas quando ele for necessário e quando as
   políticas da organização o permitirem.

3. Crie um `project.bootstrap.json` com os sete campos definidos em
   [Bootstrap Specification](docs/BOOTSTRAP_SPEC.md); `foundation_version`
   deve reproduzir exatamente o conteúdo de `VERSION` e `profile` deve existir
   nesta Foundation. Para `dotnet-web`, valide também o SDK conforme o README
   do profile.

4. Gere o projeto em um diretório-pai existente e abra-o na ferramenta de
   engenharia disponível:

   ```powershell
   .\tools\New-Project.ps1 -Manifest .\project.bootstrap.json -Destination C:\Dev\10-projects
   code C:\Dev\10-projects\<project_slug>
   ```

   `code` é opcional: abra o diretório gerado manualmente se o comando não
   estiver instalado. O gerador confirma a criação e inicializa Git em `main`.

### O que cada etapa exige

- O gerador requer Windows PowerShell, Git disponível no `PATH`, um manifesto
  válido e um diretório de destino existente.
- Cada profile declara seus próprios requisitos; `.NET` é exigido somente para
  usar o profile `dotnet-web`.
- VS Code e Codex pertencem ao fluxo de engenharia, mas não são requisitos
  técnicos para `New-Project.ps1` funcionar.

## Documentação inicial

- `docs/FOUNDATION_OVERVIEW.md`
- `docs/PROJECT_LIFECYCLE.md`
- `docs/ENVIRONMENT_STANDARD.md`
- `docs/BOOTSTRAP_SPEC.md`
- `docs/CODEX_STANDARD.md`

## Estrutura

- `docs/` — metodologia e padrões
- `global/` — configurações globais reutilizáveis
- `templates/` — templates para novos projetos
- `tools/` — automações da Foundation
- `tests/` — verificações da própria Foundation

## Fonte da verdade

O repositório `dev-foundation` é a fonte técnica oficial da metodologia.

Conversas no ChatGPT são utilizadas para análise, planejamento e tomada de decisão. Decisões permanentes devem ser materializadas neste repositório.
