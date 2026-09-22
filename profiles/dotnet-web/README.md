# dotnet-web

Profile mínimo e neutro para aplicações web .NET com ASP.NET Core.

## Pré-requisitos

- .NET SDK `10.0.401`
- Target framework `net10.0`

`template/global.json` fixa o SDK `10.0.401` para os projetos gerados por este
profile. Antes de gerar ou validar o projeto, confirme que o SDK está
instalado:

```powershell
dotnet --list-sdks
dotnet --version
```

## Validação

```powershell
dotnet restore .\src\App\App.csproj
dotnet build .\src\App\App.csproj --configuration Release --no-restore
```

.NET é requisito deste profile, não do core de `New-Project.ps1`. Consulte o
contrato completo de ambiente em
[`docs/ENVIRONMENT_STANDARD.md`](../../docs/ENVIRONMENT_STANDARD.md).

## Fora do escopo

- banco de dados;
- ORM;
- autenticação;
- Blazor;
- MVC;
- Razor Pages;
- frontend separado;
- arquitetura específica de produto;
- dependências externas sem necessidade concreta.
