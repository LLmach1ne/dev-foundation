# DEV FOUNDATION â€” Environment Standard

**VersÃ£o do documento:** 0.1
**Status:** Draft
**Escopo:** Foundation

## 1. Objetivo

Este documento define como o ambiente de desenvolvimento deve ser organizado para permitir portabilidade, recuperaÃ§Ã£o e uso consistente entre diferentes computadores.

A mÃ¡quina local deve ser tratada como uma estaÃ§Ã£o reconstruÃ­vel.

InformaÃ§Ã£o essencial nÃ£o deve existir exclusivamente nela.

## 2. Modelo de ambiente

O ambiente possui quatro camadas:

**ChatGPT â†’ Git remoto â†’ mÃ¡quina local â†’ VS Code/Codex**

Cada camada possui responsabilidade prÃ³pria.

### ChatGPT

ResponsÃ¡vel por:

- discussÃ£o;
- discovery;
- anÃ¡lise;
- planejamento;
- contexto de trabalho;
- coordenaÃ§Ã£o metodolÃ³gica.

### Git remoto

ResponsÃ¡vel por:

- fonte oficial versionada;
- histÃ³rico;
- colaboraÃ§Ã£o;
- recuperaÃ§Ã£o;
- distribuiÃ§Ã£o entre computadores.

### MÃ¡quina local

ResponsÃ¡vel por:

- execuÃ§Ã£o;
- ferramentas;
- caches;
- SDKs;
- repositÃ³rios clonados;
- recursos de desenvolvimento.

### VS Code/Codex

ResponsÃ¡veis pela execuÃ§Ã£o da engenharia dentro do projeto.

## 3. Estrutura local padrÃ£o

Em Windows, a raiz recomendada Ã©:

`C:\Dev\`

Estrutura:

```text
C:\Dev\
â”‚
â”œâ”€â”€ 00-foundation\
â”‚   â””â”€â”€ dev-foundation\
â”‚
â”œâ”€â”€ 10-projects\
â”‚
â”œâ”€â”€ 90-archive\
â”‚
â””â”€â”€ 99-scratch\
```

### `00-foundation`

ContÃ©m a cÃ³pia local do repositÃ³rio `dev-foundation`.

### `10-projects`

ContÃ©m repositÃ³rios reais em desenvolvimento.

Exemplo:

`C:\Dev\10-projects\sicoq`

### `90-archive`

Pode conter cÃ³pias locais de projetos inativos ou encerrados.

O Git remoto continua sendo a principal fonte versionada.

### `99-scratch`

Ãrea explicitamente descartÃ¡vel para:

- protÃ³tipos;
- testes;
- investigaÃ§Ãµes;
- experimentos.

Nada importante deve permanecer apenas em `99-scratch`.

## 4. Portabilidade

Um ambiente Ã© considerado portÃ¡til quando um computador novo consegue ser preparado utilizando:

- acesso Ã  conta ChatGPT;
- acesso aos repositÃ³rios Git;
- documentaÃ§Ã£o da Foundation;
- scripts de configuraÃ§Ã£o;
- credenciais fornecidas pelos canais apropriados.

O processo nÃ£o deve depender de conhecimento informal do tipo:

â€œinstale aquela extensÃ£o que usamos da outra vezâ€.

Esse conhecimento deve estar documentado ou automatizado.

## 5. ConfiguraÃ§Ã£o global e configuraÃ§Ã£o de projeto

ConfiguraÃ§Ãµes devem existir no nÃ­vel mais especÃ­fico adequado.

### Global

Somente regras realmente universais.

Exemplos:

- comportamento geral do Codex;
- princÃ­pios de seguranÃ§a;
- polÃ­tica de alteraÃ§Ãµes destrutivas;
- preferÃªncias pessoais.

### Projeto

Tudo que Ã© necessÃ¡rio para construir corretamente aquele repositÃ³rio.

Exemplos:

- extensÃµes recomendadas;
- formatter;
- tasks;
- debug;
- comandos de teste;
- versÃ£o do SDK;
- regras especÃ­ficas do agente.

O projeto deve evitar depender de configuraÃ§Ãµes pessoais ocultas.

## 6. Codex

A Foundation deve manter um modelo versionado de configuraÃ§Ã£o global do Codex.

A instalaÃ§Ã£o local correspondente deverÃ¡ existir em:

`%USERPROFILE%\.codex\`

A configuraÃ§Ã£o global deve conter somente regras aplicÃ¡veis a todos os projetos.

Cada repositÃ³rio pode possuir adicionalmente:

```text
AGENTS.md
.codex/
```

para regras especÃ­ficas.

A configuraÃ§Ã£o especÃ­fica do produto nÃ£o deve ser colocada no nÃ­vel global.

## 7. VS Code

PreferÃªncias pessoais permanecem no perfil do usuÃ¡rio.

ConfiguraÃ§Ãµes necessÃ¡rias ao projeto devem ser versionadas em:

`.vscode/`

Conforme a necessidade:

```text
.vscode/
â”œâ”€â”€ settings.json
â”œâ”€â”€ extensions.json
â”œâ”€â”€ tasks.json
â””â”€â”€ launch.json
```

O objetivo Ã© que abrir o repositÃ³rio jÃ¡ forneÃ§a orientaÃ§Ã£o suficiente para preparar o workspace corretamente.

## 8. Git

Cada produto real deve possuir seu prÃ³prio repositÃ³rio.

A DEV FOUNDATION tambÃ©m possui repositÃ³rio independente.

Estrutura conceitual:

```text
dev-foundation
sicoq
sistema-x
sistema-y
```

Um produto nÃ£o deve ser criado como subdiretÃ³rio permanente do repositÃ³rio da Foundation.

A Foundation gera projetos; nÃ£o os contÃ©m.

## 9. Arquivos locais e segredos

Nunca devem ser versionados inadvertidamente:

- senhas;
- tokens;
- chaves privadas;
- credenciais;
- secrets de ambiente;
- caches;
- bancos locais descartÃ¡veis;
- artefatos de build;
- dados empresariais sensÃ­veis nÃ£o destinados ao repositÃ³rio.

A Foundation deve fornecer padrÃµes de `.gitignore` e mecanismos apropriados para secrets de acordo com cada stack.

ConfiguraÃ§Ã£o reutilizÃ¡vel e configuraÃ§Ã£o secreta devem ser tratadas como categorias diferentes.

## 10. Ferramentas

A Foundation deve evitar exigir ferramentas sem necessidade comprovada.

O ambiente bÃ¡sico deverÃ¡ convergir para:

- Git;
- VS Code;
- Codex;
- PowerShell;
- ferramentas exigidas pelo profile tecnolÃ³gico do projeto.

Ferramentas adicionais somente entram quando resolvem uma necessidade real.

Exemplos que nÃ£o devem ser obrigatÃ³rios por padrÃ£o:

- Docker;
- Kubernetes;
- Node.js;
- Python;
- bancos locais especÃ­ficos.

Cada profile tecnolÃ³gico declara suas prÃ³prias dependÃªncias.

## 11. AutomaÃ§Ã£o

OperaÃ§Ãµes recorrentes devem convergir para comandos previsÃ­veis.

A Foundation deverÃ¡ fornecer ou exigir equivalentes a:

```text
setup
run
test
verify
```

O desenvolvedor nÃ£o deve precisar memorizar uma longa sequÃªncia de comandos especÃ­ficos para cada projeto.

Os scripts do projeto devem encapsular essa complexidade quando isso produzir benefÃ­cio real.

## 12. Bootstrap de mÃ¡quina

A Foundation deverÃ¡ evoluir para permitir um fluxo aproximado:

```text
Nova mÃ¡quina
â†’ instalar prÃ©-requisitos mÃ­nimos
â†’ clonar dev-foundation
â†’ executar Setup-Machine
â†’ verificar ambiente
â†’ clonar ou criar projeto
â†’ abrir no VS Code
```

O processo deverÃ¡ verificar prÃ©-requisitos antes de modificar a mÃ¡quina.

AlteraÃ§Ãµes sensÃ­veis devem ser explÃ­citas.

## 13. Bootstrap de projeto

Um novo projeto deverÃ¡ poder nascer atravÃ©s de um comando padronizado.

Conceitualmente:

```text
New-Project
+ nome
+ profile
+ nÃ­vel de governanÃ§a
```

O resultado deverÃ¡ conter uma estrutura conhecida e registrar a versÃ£o da Foundation utilizada.

Exemplo de metadados:

```text
foundation: dev-foundation
version: 1.0.0
profile: dotnet-web
level: standard
```

## 14. RecuperaÃ§Ã£o

A Foundation deve considerar como requisito a possibilidade de perda da mÃ¡quina local.

O cenÃ¡rio esperado deve ser:

**nova mÃ¡quina + Git remoto + ChatGPT + credenciais = ambiente reconstruÃ­vel**

A perda de uma instalaÃ§Ã£o local nÃ£o deve significar perda de:

- decisÃµes;
- cÃ³digo;
- metodologia;
- configuraÃ§Ãµes importantes;
- requisitos;
- histÃ³rico.

## 15. CritÃ©rio de homologaÃ§Ã£o do ambiente

Antes de utilizar a Foundation no primeiro projeto real, um projeto descartÃ¡vel deverÃ¡ comprovar que:

- a estrutura pode ser criada;
- Git funciona;
- VS Code reconhece o workspace;
- Codex recebe as instruÃ§Ãµes esperadas;
- scripts executam;
- testes podem ser executados;
- `verify` produz resultado confiÃ¡vel;
- um commit pode ser criado;
- o projeto pode ser removido e recriado.

Somente apÃ³s essa validaÃ§Ã£o a primeira versÃ£o estÃ¡vel da Foundation deve ser declarada pronta para uso.
