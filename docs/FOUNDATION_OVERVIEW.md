# DEV FOUNDATION â€” Overview

**VersÃ£o do documento:** 0.1
**Status:** Stable — v1.0.0
**Escopo:** Foundation
**Fonte técnica oficial:** repositório `dev-foundation`

## 1. PropÃ³sito

A DEV FOUNDATION Ã© a base metodolÃ³gica e tÃ©cnica utilizada para iniciar, desenvolver, verificar, homologar e manter projetos de software assistidos por ChatGPT e Codex.

Seu objetivo nÃ£o Ã© definir como um produto especÃ­fico deve funcionar.

Seu objetivo Ã© definir **como os projetos sÃ£o desenvolvidos**.

A Foundation deve permitir que um projeto seja iniciado e continuado de forma reproduzÃ­vel, rastreÃ¡vel e portÃ¡til, independentemente do computador utilizado.

## 2. Objetivos

A Foundation deve tornar o processo de desenvolvimento:

- reproduzÃ­vel;
- portÃ¡til;
- rastreÃ¡vel;
- proporcional Ã  complexidade do projeto;
- eficiente no uso de modelos e contexto;
- seguro contra alteraÃ§Ãµes destrutivas;
- orientado por requisitos e evidÃªncias;
- verificÃ¡vel por testes;
- independente da memÃ³ria de uma conversa especÃ­fica;
- progressivamente melhor a partir de aprendizados reais.

## 3. PrincÃ­pio fundamental

O desenvolvimento nÃ£o comeÃ§a pelo cÃ³digo.

O fluxo padrÃ£o Ã©:

**Ideia â†’ Discovery â†’ Requisitos â†’ Arquitetura â†’ Planejamento â†’ Bootstrap â†’ ImplementaÃ§Ã£o â†’ VerificaÃ§Ã£o â†’ HomologaÃ§Ã£o â†’ Release â†’ ManutenÃ§Ã£o**

A profundidade de cada etapa deve ser proporcional ao porte, risco e complexidade do projeto.

## 4. SeparaÃ§Ã£o de responsabilidades

### Humano

ResponsÃ¡vel por:

- objetivos;
- prioridades;
- regras de negÃ³cio;
- decisÃµes de produto;
- aceitaÃ§Ã£o de trade-offs;
- aprovaÃ§Ã£o de requisitos;
- homologaÃ§Ã£o final.

### ChatGPT

ResponsÃ¡vel principalmente por:

- descoberta;
- anÃ¡lise;
- refinamento de problema;
- requisitos;
- arquitetura;
- planejamento;
- decomposiÃ§Ã£o de trabalho;
- revisÃ£o estratÃ©gica;
- preparaÃ§Ã£o de tarefas para implementaÃ§Ã£o;
- consolidaÃ§Ã£o de aprendizados.

### Codex

ResponsÃ¡vel principalmente por:

- investigaÃ§Ã£o do repositÃ³rio;
- implementaÃ§Ã£o;
- execuÃ§Ã£o;
- testes;
- correÃ§Ãµes;
- refatoraÃ§Ãµes;
- anÃ¡lise tÃ©cnica;
- revisÃ£o de cÃ³digo.

### VS Code

Ã‰ o ambiente local de engenharia utilizado para:

- ediÃ§Ã£o;
- execuÃ§Ã£o;
- depuraÃ§Ã£o;
- navegaÃ§Ã£o do repositÃ³rio;
- integraÃ§Ã£o com Codex;
- execuÃ§Ã£o de tasks e testes.

### Git

Ã‰ a fonte permanente e versionada da verdade tÃ©cnica.

DecisÃµes oficiais, requisitos aprovados, arquitetura, cÃ³digo, testes e configuraÃ§Ãµes duradouras devem terminar no repositÃ³rio correspondente.

## 5. Camadas do ambiente

A metodologia utiliza quatro camadas complementares.

### ChatGPT

Ã‰ a camada de interaÃ§Ã£o, raciocÃ­nio e coordenaÃ§Ã£o.

O projeto `00 â€” DEV FOUNDATION` contÃ©m o contexto mestre da metodologia.

Cada produto real deve possuir seu prÃ³prio projeto no ChatGPT quando sua complexidade justificar isso.

### DEV FOUNDATION

Ã‰ o repositÃ³rio versionado contendo:

- metodologia;
- padrÃµes;
- templates;
- configuraÃ§Ãµes reutilizÃ¡veis;
- scripts;
- especificaÃ§Ãµes de bootstrap.

### RepositÃ³rio do produto

ContÃ©m tudo que pertence especificamente ao produto:

- requisitos;
- arquitetura;
- ADRs;
- cÃ³digo;
- testes;
- configuraÃ§Ãµes;
- documentaÃ§Ã£o;
- histÃ³rico Git.

### MÃ¡quina local

Ã‰ uma estaÃ§Ã£o de execuÃ§Ã£o reconstruÃ­vel.

NÃ£o deve ser considerada fonte exclusiva de informaÃ§Ã£o importante.

## 6. Fonte da verdade

Conversas sÃ£o utilizadas para raciocÃ­nio, exploraÃ§Ã£o e tomada de decisÃ£o.

Quando uma decisÃ£o se torna oficial e duradoura, ela deve ser materializada no repositÃ³rio apropriado.

A hierarquia conceitual Ã©:

1. requisitos homologados;
2. decisÃµes arquiteturais registradas;
3. documentaÃ§Ã£o e configuraÃ§Ã£o versionadas;
4. regras da Foundation;
5. contexto da conversa;
6. suposiÃ§Ãµes do agente.

Um agente nÃ£o deve alterar silenciosamente uma decisÃ£o oficial apenas porque uma alternativa parece mais conveniente.

## 7. Foundation Core e perfis tecnolÃ³gicos

A Foundation Ã© dividida conceitualmente em:

### Core

Independente de linguagem ou framework.

Inclui:

- ciclo de desenvolvimento;
- requisitos;
- planejamento;
- Git;
- qualidade;
- testes;
- versionamento;
- uso de agentes;
- bootstrap;
- documentaÃ§Ã£o.

### Profiles

ContÃªm convenÃ§Ãµes especÃ­ficas de stacks tecnolÃ³gicas.

Profile oficial atual:

- `dotnet-web`;

Exemplos de profiles que podem ser publicados no futuro quando houver necessidade concreta:

- `python`;
- `node-web`.

Um projeto nasce da combinaÃ§Ã£o:

**Foundation Core + Profile tecnolÃ³gico + nÃ­vel de governanÃ§a + requisitos especÃ­ficos do produto**

## 8. NÃ­veis de governanÃ§a

A Foundation deve suportar nÃ­veis diferentes de rigor.

### Light

Para scripts, experimentos e pequenas automaÃ§Ãµes de baixo risco.

Exige apenas a estrutura necessÃ¡ria para tornar o trabalho compreensÃ­vel e recuperÃ¡vel.

### Standard

Para sistemas reais com continuidade de desenvolvimento.

Inclui requisitos, arquitetura, testes, rastreabilidade, versionamento e processo de homologaÃ§Ã£o.

### Critical

Para projetos de maior impacto, risco operacional, seguranÃ§a, exigÃªncia regulatÃ³ria ou criticidade empresarial.

Adiciona controles, evidÃªncias, revisÃ£o e quality gates adicionais.

A complexidade do processo deve justificar sua existÃªncia.

## 9. PrincÃ­pios operacionais

A Foundation adota os seguintes princÃ­pios:

- nÃ£o iniciar implementaÃ§Ã£o antes de o problema estar suficientemente definido;
- nÃ£o adicionar complexidade sem benefÃ­cio demonstrÃ¡vel;
- nÃ£o repetir em prompts informaÃ§Ã£o que possa permanecer no repositÃ³rio;
- nÃ£o deixar decisÃµes importantes somente em conversas;
- utilizar requisitos identificÃ¡veis;
- preferir alteraÃ§Ãµes pequenas e revisÃ¡veis;
- nÃ£o declarar sucesso sem evidÃªncia;
- automatizar tarefas repetitivas quando o benefÃ­cio justificar;
- utilizar maior esforÃ§o de modelo somente quando risco ou complexidade justificarem;
- testar comportamento de maior risco;
- preservar rastreabilidade;
- evitar dependÃªncias desnecessÃ¡rias;
- manter possibilidade de recuperaÃ§Ã£o por Git;
- transformar erros recorrentes do processo em melhoria da Foundation.

## 10. EvoluÃ§Ã£o da Foundation

A Foundation Ã© um produto versionado.

Aprendizados genÃ©ricos descobertos durante projetos reais devem seguir o fluxo:

**Problema real â†’ soluÃ§Ã£o validada â†’ anÃ¡lise de generalizaÃ§Ã£o â†’ alteraÃ§Ã£o da Foundation â†’ nova versÃ£o**

Uma regra especÃ­fica de um produto nunca deve ser incorporada Ã  Foundation apenas porque apareceu primeiro naquele projeto.

## 11. Compatibilidade com projetos existentes

AtualizaÃ§Ãµes da Foundation nÃ£o alteram automaticamente projetos existentes.

Cada projeto registra a versÃ£o da Foundation utilizada em sua criaÃ§Ã£o.

Uma atualizaÃ§Ã£o de metodologia em projeto existente deve ser deliberada, revisada e rastreÃ¡vel.

## 12. CritÃ©rio de sucesso

A Foundation Ã© bem-sucedida quando reduz:

- retrabalho;
- repetiÃ§Ã£o de contexto;
- erros recorrentes;
- decisÃµes perdidas;
- alteraÃ§Ãµes nÃ£o rastreÃ¡veis;
- dificuldade para trocar de computador;
- dependÃªncia da memÃ³ria de chats;
- esforÃ§o necessÃ¡rio para iniciar um novo projeto.

E aumenta:

- previsibilidade;
- rastreabilidade;
- qualidade;
- seguranÃ§a;
- velocidade de retomada;
- capacidade de verificaÃ§Ã£o;
- reutilizaÃ§Ã£o de conhecimento.
