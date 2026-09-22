# DEV FOUNDATION â€” Project Lifecycle

**VersÃ£o do documento:** 0.1
**Status:** Stable — v1.0.0
**Escopo:** Foundation

## 1. Objetivo

Este documento define o ciclo padrÃ£o utilizado por projetos desenvolvidos sob a DEV FOUNDATION.

O processo deve orientar o desenvolvimento sem criar burocracia desnecessÃ¡ria.

A profundidade das atividades depende do nÃ­vel de governanÃ§a do projeto.

## 2. Ciclo principal

Todo projeto percorre conceitualmente:

**Ideia â†’ Discovery â†’ Requisitos â†’ Arquitetura â†’ Planejamento â†’ Bootstrap â†’ ImplementaÃ§Ã£o â†’ VerificaÃ§Ã£o â†’ HomologaÃ§Ã£o â†’ Release â†’ ManutenÃ§Ã£o**

Nem toda etapa precisa produzir grande quantidade de documentaÃ§Ã£o.

O objetivo Ã© garantir que as decisÃµes necessÃ¡rias sejam tomadas antes do momento em que passam a gerar retrabalho significativo.

## 3. Etapa 1 â€” Ideia

### Objetivo

Registrar o problema ou oportunidade inicial.

### Pergunta principal

**O que queremos resolver e por quÃª?**

### SaÃ­da mÃ­nima

Uma declaraÃ§Ã£o compreensÃ­vel do problema e do resultado esperado.

### Gate

A ideia possui valor ou justificativa suficiente para iniciar Discovery.

## 4. Etapa 2 â€” Discovery

### Objetivo

Entender o problema antes de propor uma soluÃ§Ã£o tÃ©cnica.

### Deve esclarecer

- usuÃ¡rios;
- processo atual;
- dores;
- necessidades;
- restriÃ§Ãµes;
- dados envolvidos;
- contexto operacional;
- riscos;
- critÃ©rios de sucesso;
- limites iniciais de escopo.

### Gate

O problema estÃ¡ suficientemente compreendido para definir o produto.

## 5. Etapa 3 â€” Requisitos

### Objetivo

Transformar necessidades em comportamentos verificÃ¡veis.

Requisitos importantes devem possuir identificadores estÃ¡veis.

Exemplo:

`REQ-OCR-001`

Um bom requisito deve permitir responder posteriormente:

- onde foi implementado;
- como foi testado;
- se foi homologado.

### Gate

O escopo necessÃ¡rio para a prÃ³xima fase de desenvolvimento estÃ¡ suficientemente definido e nÃ£o depende de suposiÃ§Ãµes crÃ­ticas nÃ£o registradas.

## 6. Etapa 4 â€” Arquitetura

### Objetivo

Definir a estrutura tÃ©cnica adequada ao problema.

A arquitetura deve priorizar a soluÃ§Ã£o mais simples que satisfaÃ§a os requisitos e riscos conhecidos.

DecisÃµes de longo impacto devem ser registradas por ADR quando necessÃ¡rio.

### Exemplos

- arquitetura de aplicaÃ§Ã£o;
- banco de dados;
- autenticaÃ§Ã£o;
- autorizaÃ§Ã£o;
- deploy;
- auditoria;
- integraÃ§Ãµes;
- concorrÃªncia;
- seguranÃ§a;
- estratÃ©gia de testes.

### Gate

As decisÃµes tÃ©cnicas necessÃ¡rias para iniciar a construÃ§Ã£o estÃ£o suficientemente definidas.

## 7. Etapa 5 â€” Planejamento

### Objetivo

Transformar requisitos e arquitetura em unidades de trabalho executÃ¡veis.

As tarefas devem ser pequenas o suficiente para:

- compreender;
- implementar;
- revisar;
- testar;
- reverter se necessÃ¡rio.

Mas nÃ£o devem ser fragmentadas artificialmente.

### Definition of Ready

Uma tarefa estÃ¡ pronta para implementaÃ§Ã£o quando contÃ©m contexto suficiente para execuÃ§Ã£o sem que o agente precise inventar decisÃµes importantes.

Quando aplicÃ¡vel, deve possuir:

- objetivo;
- requisitos relacionados;
- comportamento esperado;
- restriÃ§Ãµes;
- critÃ©rios de aceite;
- impacto conhecido;
- estratÃ©gia de verificaÃ§Ã£o.

### Gate

Existe uma unidade de trabalho claramente executÃ¡vel.

## 8. Etapa 6 â€” Bootstrap

### Objetivo

Criar o ambiente tÃ©cnico inicial de forma reproduzÃ­vel.

O bootstrap deve estabelecer:

- repositÃ³rio Git;
- estrutura de diretÃ³rios;
- configuraÃ§Ã£o Codex;
- configuraÃ§Ã£o VS Code;
- documentaÃ§Ã£o inicial;
- scripts;
- testes bÃ¡sicos;
- dependÃªncias essenciais;
- versÃ£o da Foundation utilizada.

### Gate

O projeto pode ser clonado ou recriado e possui caminho documentado para execuÃ§Ã£o e verificaÃ§Ã£o.

## 9. Etapa 7 â€” ImplementaÃ§Ã£o

### Objetivo

Construir incrementos pequenos e verificÃ¡veis.

O desenvolvimento deve preferir fatias verticais quando apropriado.

Cada alteraÃ§Ã£o deve preservar:

- requisitos;
- arquitetura aprovada;
- integridade dos dados;
- rastreabilidade;
- possibilidade de revisÃ£o.

Tarefas complexas devem separar planejamento tÃ©cnico de execuÃ§Ã£o.

### Regra

O Codex nÃ£o recebe liberdade implÃ­cita para redefinir produto ou arquitetura para facilitar a implementaÃ§Ã£o.

## 10. Etapa 8 â€” VerificaÃ§Ã£o

### Objetivo

Produzir evidÃªncia tÃ©cnica de que a alteraÃ§Ã£o funciona conforme esperado.

A verificaÃ§Ã£o pode incluir:

- build;
- anÃ¡lise estÃ¡tica;
- formataÃ§Ã£o;
- testes unitÃ¡rios;
- testes de integraÃ§Ã£o;
- testes E2E;
- inspeÃ§Ã£o de migrations;
- revisÃ£o de diff;
- revisÃ£o automatizada;
- CI.

### Definition of Done

Uma alteraÃ§Ã£o somente pode ser considerada concluÃ­da quando os gates aplicÃ¡veis tiverem sido executados e nÃ£o existirem falhas conhecidas incompatÃ­veis com a entrega.

A declaraÃ§Ã£o â€œimplementadoâ€ nÃ£o Ã© evidÃªncia suficiente.

## 11. Etapa 9 â€” HomologaÃ§Ã£o

### Objetivo

Validar que o resultado tÃ©cnico atende Ã  necessidade real.

A homologaÃ§Ã£o humana Ã© especialmente importante para:

- comportamento de negÃ³cio;
- ergonomia;
- UX;
- processo operacional;
- trade-offs;
- aderÃªncia ao ambiente real.

A aprovaÃ§Ã£o automatizada nÃ£o substitui homologaÃ§Ã£o quando julgamento humano Ã© necessÃ¡rio.

### Gate

O responsÃ¡vel pelo produto aceita o comportamento entregue.

## 12. Etapa 10 â€” Release

### Objetivo

Criar um estado identificÃ¡vel e recuperÃ¡vel do produto.

Uma release deve possuir, conforme a necessidade:

- versÃ£o;
- commit identificÃ¡vel;
- tag;
- changelog;
- artefato de entrega;
- migrations;
- instruÃ§Ãµes de implantaÃ§Ã£o;
- evidÃªncias de verificaÃ§Ã£o.

### Gate

A versÃ£o pode ser implantada e, quando necessÃ¡rio, recuperada ou revertida de forma conhecida.

## 13. Etapa 11 â€” ManutenÃ§Ã£o

ApÃ³s a primeira release, o projeto entra em ciclo contÃ­nuo.

Novas features retornam ao processo a partir da etapa necessÃ¡ria.

Bugs devem seguir, quando aplicÃ¡vel:

**Reproduzir â†’ identificar comportamento esperado â†’ criar evidÃªncia/teste â†’ corrigir â†’ verificar regressÃ£o â†’ revisar â†’ homologar**

Um bug relevante que possa voltar deve preferencialmente deixar uma proteÃ§Ã£o permanente, como teste automatizado ou quality gate.

## 14. Melhoria da Foundation

Ao longo de qualquer projeto, problemas de processo devem ser avaliados.

Quando um aprendizado for genÃ©rico:

**Projeto â†’ aprendizado â†’ proposta â†’ DEV FOUNDATION â†’ validaÃ§Ã£o â†’ nova versÃ£o**

Quando for especÃ­fico:

**Projeto â†’ documentaÃ§Ã£o do prÃ³prio projeto**

Essa separaÃ§Ã£o deve ser preservada.

## 15. Uso proporcional

O processo nÃ£o deve ter o mesmo peso para todos os projetos.

### Light

Pode condensar vÃ¡rias etapas.

### Standard

Executa todas as etapas de maneira objetiva.

### Critical

Exige evidÃªncias e controles adicionais.

A Foundation deve prevenir tanto ausÃªncia de engenharia quanto excesso de engenharia.
