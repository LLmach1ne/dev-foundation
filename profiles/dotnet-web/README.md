# dotnet-web

Profile mínimo e neutro para aplicações web .NET com ASP.NET Core.

## Pré-requisitos

- .NET SDK 10.0.401
- Target framework `net10.0`

## Validação

```powershell
dotnet restore .\src\App\App.csproj
dotnet build .\src\App\App.csproj --configuration Release --no-restore
```

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
