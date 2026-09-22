# DEV FOUNDATION — Environment Standard

**Versão do documento:** 0.1
**Status:** Draft
**Escopo:** Foundation

## 1. Objetivo

Este documento materializa o contrato de ambiente para a Foundation v1: uma
máquina Windows nova deve poder clonar, validar e usar a Foundation sem
depender de conhecimento mantido apenas em outra máquina ou em conversas.

A máquina local é uma estação reconstruível. Informações permanentes,
configurações reutilizáveis e decisões devem permanecer nos repositórios
apropriados; credenciais são fornecidas pelos canais apropriados e não entram
na Foundation.

## 2. Plataforma e evidência atual

A Foundation v1 usa Windows nativo. Windows PowerShell 5.1 é o baseline
efetivamente exercitado e homologado para `New-Project.ps1` e para a suíte
atual. Isso não declara incompatibilidade com versões de PowerShell não
testadas.

WSL e Docker não são requisitos da Foundation. Ferramentas adicionais só
entram quando um profile ou projeto justificar sua necessidade.

As evidências atualmente homologadas são:

- Windows nativo;
- Windows PowerShell 5.1;
- Git capaz de executar `git init --initial-branch main`;
- .NET SDK `10.0.401` para o profile `dotnet-web`.

## 3. Requisitos por finalidade

| Finalidade | Requisitos | Não exige |
| --- | --- | --- |
| Gerar um projeto | Windows PowerShell, Git no `PATH`, manifesto válido, destino existente e gravável | .NET, VS Code e Codex, salvo se o profile escolhido os exigir posteriormente |
| Usar `dotnet-web` | Requisitos do gerador e .NET SDK `10.0.401` | Banco, Docker, WSL ou dependências de produto |
| Fluxo de engenharia | Ferramentas humanas escolhidas para editar, revisar, testar e trabalhar com agentes, como VS Code e Codex | Que `New-Project.ps1` dependa dessas ferramentas |
| Manter/testar a Foundation | Windows PowerShell 5.1 e Pester `3.4.0`, além de Git | Pester para quem apenas gera projetos |

## 4. Git

`New-Project.ps1` requer que `git` esteja disponível no `PATH`. O Git usado
deve aceitar o comando abaixo, pois o gerador cria o repositório com a branch
inicial determinística `main`:

```powershell
git --version
git init --help
```

Não há versão mínima numérica declarada sem evidência adicional. A confirmação
operacional é que `git init --initial-branch main <destino>` seja suportado.

O bootstrap apenas inicializa o repositório. `user.name` e `user.email` não
são necessários nessa etapa, mas serão necessários quando a pessoa criar o
primeiro commit:

```powershell
git config --get user.name
git config --get user.email
```

Autenticação com GitHub ou outro remoto é um passo humano de setup da conta. O
gerador não configura credenciais, remotos ou identidade Git.

## 5. PowerShell e Execution Policy

Antes de executar scripts, diagnostique a política efetiva:

```powershell
Get-ExecutionPolicy -List
```

Políticas restritivas podem bloquear `New-Project.ps1`. A alternativa
temporária usada e homologada é:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
```

Ela vale somente para a sessão atual, não altera permanentemente a política e
nunca deve ser aplicada automaticamente pela Foundation. `MachinePolicy` e
`UserPolicy` corporativas devem ser respeitadas: não devem ser contornadas por
scripts, instruções ou parâmetros alternativos.

## 6. Profiles e .NET

.NET não é requisito do core nem de `New-Project.ps1`; o gerador compõe o
profile solicitado, mas não executa restore ou build.

O profile `dotnet-web` exige atualmente o SDK `10.0.401`. A fonte versionada
da fixação é `profiles/dotnet-web/template/global.json`. Antes de usar esse
profile, confirme a instalação:

```powershell
dotnet --list-sdks
dotnet --version
```

Depois de gerar um projeto `dotnet-web`, valide o mínimo da stack:

```powershell
dotnet restore .\src\App\App.csproj
dotnet build .\src\App\App.csproj --configuration Release --no-restore
```

Não há regra genérica antecipada para profiles futuros; cada profile publicado
deve documentar seus próprios pré-requisitos e verificações.

## 7. VS Code e Codex

VS Code e Codex fazem parte do fluxo de engenharia da metodologia, mas não
são requisitos técnicos para `New-Project.ps1` funcionar. Instalação,
autenticação e atualização dessas ferramentas são passos humanos.

Configurações necessárias a um projeto pertencem ao próprio repositório.
Configurações globais do Codex exigem revisão humana e seguem o
[Codex Standard](CODEX_STANDARD.md); a Foundation não instala extensões nem
altera configurações globais automaticamente.

## 8. Testes da própria Foundation

A suíte atual `tests/New-Project.Tests.ps1` foi exercitada em Windows
PowerShell 5.1 com Pester `3.4.0`. Pester não é pré-requisito para pessoas que
apenas usam o gerador.

Para mantenedores da Foundation, o comando oficial atual é:

```powershell
Invoke-Pester -Script .\tests\New-Project.Tests.ps1
```

Execute-o em uma sessão que possa executar scripts conforme a seção 5. A suíte
usa diretórios temporários descartáveis para seus fixtures.

## 9. Segurança e privilégios

O setup deve preferir o escopo da sessão ou do usuário. Nenhuma instrução da
Foundation exige privilégios administrativos sem necessidade comprovada.

A Foundation não altera silenciosamente `PATH`, Execution Policy, configuração
Git, configuração Codex ou credenciais. Segredos, tokens, chaves privadas e
dados de autenticação não pertencem ao repositório.

## 10. Reconstrução de uma máquina Windows

1. Instale manualmente Windows PowerShell/Git e as ferramentas humanas que o
   fluxo exigir; instale o SDK somente se for usar `dotnet-web`.
2. Clone a Foundation e selecione a referência pretendida:

   ```powershell
   git clone https://github.com/LLmach1ne/dev-foundation.git C:\Dev\00-foundation\dev-foundation
   Set-Location C:\Dev\00-foundation\dev-foundation
   git switch main
   ```

3. Inspecione `Get-ExecutionPolicy -List` e `git --version`. Se necessário e
   permitido, aplique `RemoteSigned` somente ao processo atual.
4. Para `dotnet-web`, confirme `dotnet --list-sdks` e `dotnet --version` antes
   de gerar o projeto.
5. Crie um `project.bootstrap.json` conforme
   [Bootstrap Specification](BOOTSTRAP_SPEC.md), com `foundation_version`
   exatamente igual ao conteúdo de `VERSION`.
6. Execute o bootstrap para um diretório-pai existente:

   ```powershell
   .\tools\New-Project.ps1 -Manifest .\project.bootstrap.json -Destination C:\Dev\10-projects
   ```

7. Valide o projeto gerado. Confirme a existência de `FOUNDATION.lock` e
   `.git`, execute `git -C <diretorio-do-projeto> status --short` e, para
   `dotnet-web`, faça restore e build conforme a seção 6.

## 11. Estrutura local recomendada

Em Windows, `C:\Dev\` é uma convenção recomendada, não uma dependência do
gerador:

```text
C:\Dev\
├── 00-foundation\
│   └── dev-foundation\
├── 10-projects\
├── 90-archive\
└── 99-scratch\
```

`00-foundation` contém a cópia da Foundation; `10-projects` contém projetos
reais; `90-archive` pode conter cópias locais inativas; e `99-scratch` é
descartável. Nada importante deve permanecer apenas em `99-scratch`.
