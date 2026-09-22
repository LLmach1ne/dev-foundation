# Changelog

Todas as mudanças relevantes da DEV FOUNDATION serão registradas neste arquivo.

## [Unreleased]

## [1.0.0] - 2026-09-22

### Adicionado

- metodologia, ciclo de vida, padrões de ambiente, Codex e governança;
- template Base independente de stack;
- profile oficial `dotnet-web` com .NET SDK `10.0.401`;
- overlays de governança `light`, `standard` e `critical`;
- bootstrap `New-Project.ps1` com validação fail-closed, composição determinística, `FOUNDATION.lock` e Git em `main`;
- verificador read-only `Verify-Environment.ps1` para core e profile `dotnet-web`;
- suíte automatizada da Foundation.

### Validado

- bootstrap E2E de projeto `dotnet-web`, incluindo Git em `main`, restore e build;
- suíte Pester completa;
- ambiente Windows PowerShell 5.1, Git e .NET SDK `10.0.401`.

## [0.1.0-dev] - 2026-09-21

### Adicionado

- estrutura inicial do repositório;
- `FOUNDATION_OVERVIEW.md`;
- `PROJECT_LIFECYCLE.md`;
- `ENVIRONMENT_STANDARD.md`;
- definição inicial das áreas `global`, `templates`, `tools` e `tests`.
