# DEV FOUNDATION — Bootstrap Specification

**Versão do documento:** 0.1
**Status:** Draft
**Escopo:** Foundation Core

## 1. Objetivo

Este documento define o contrato conceitual para criar um novo projeto com a DEV FOUNDATION. Um projeto é gerado pela composição de:

**Foundation Core + profile tecnológico existente + nível de governança + dados do projeto**

Esta especificação define o contrato do futuro `New-Project`; ela não define sua implementação, comandos, scripts ou profiles tecnológicos.

## 2. Manifesto `project.bootstrap.json`

O arquivo `project.bootstrap.json` representa a solicitação de criação de um projeto. Ele deve ser validado integralmente antes de qualquer alteração no filesystem.

### 2.1 Campos

| Campo | Obrigatório | Formato | Significado e validação |
| --- | --- | --- | --- |
| `schema_version` | Sim | string de versão do esquema, inicialmente `"1.0"` | Identifica o contrato usado para interpretar o manifesto. A versão deve ser suportada pelo bootstrap. |
| `project_name` | Sim | string não vazia, com texto significativo | Nome legível do projeto. Não pode conter somente espaços. |
| `project_slug` | Sim | `^[a-z0-9]+(?:-[a-z0-9]+)*$` | Identificador estável usado em caminhos e placeholders. Deve ser único no destino escolhido e não pode ser `.` ou `..`. |
| `description` | Sim | string não vazia | Descrição breve do problema ou propósito inicial do projeto. Não pode conter somente espaços. |
| `foundation_version` | Sim | string de versão não vazia | Versão exata da Foundation a ser usada. Deve estar disponível e ser reconhecida pela instalação da Foundation selecionada. |
| `profile` | Sim | string de identificador não vazia | Identificador do profile tecnológico. Deve corresponder a um profile existente e compatível com a `foundation_version` solicitada. Esta especificação não fixa quais profiles existem. |
| `governance_level` | Sim | enum | Nível de controles aplicáveis: `light`, `standard` ou `critical`. |

Não há campos opcionais na primeira versão do contrato. Um campo opcional futuro só poderá ser incluído quando tiver justificativa operacional clara, sem deslocar dados de produto, segredos ou configurações mutáveis para o manifesto.

### 2.2 Exemplo estrutural

O exemplo a seguir é estruturalmente completo, mas não é executável enquanto não existir um profile tecnológico oficial na Foundation. Ele não representa um manifesto válido para geração nesta fase.

```json
{
  "schema_version": "1.0",
  "project_name": "Portal de Atendimento",
  "project_slug": "portal-atendimento",
  "description": "Centraliza solicitações e acompanhamento de atendimento.",
  "foundation_version": "0.1.0",
  "profile": "<profile-existente-na-foundation>",
  "governance_level": "standard"
}
```

O valor de `profile` no exemplo é intencionalmente genérico: antes da geração ele deve ser substituído pelo identificador de um profile que exista e seja compatível com a Foundation selecionada. A regra de produção permanece inalterada: um manifesto real que referencie profile inexistente é inválido.

### 2.3 Regras gerais de validação

- O documento deve ser JSON válido e conter exatamente os campos definidos para a versão do esquema; campos desconhecidos devem falhar até serem especificados em versão futura.
- Os valores de texto devem ser interpretados como dados, nunca como comandos, caminhos arbitrários ou conteúdo a executar.
- `project_slug` não pode ser transformado silenciosamente pelo bootstrap. Se não obedecer ao formato, a solicitação falha.
- `foundation_version`, `profile` e `governance_level` devem ser resolvidos e validados antes da criação do destino.
- O manifesto não pode conter segredos, tokens, senhas, chaves privadas ou credenciais.

## 3. Arquivo `FOUNDATION.lock`

Cada projeto gerado deve receber `FOUNDATION.lock` na raiz do projeto. Ele registra a origem metodológica da geração e deve conter, pelo menos:

| Campo | Formato | Significado |
| --- | --- | --- |
| `schema_version` | string de versão | Versão do esquema do lock. |
| `foundation_version` | string de versão | Versão da Foundation efetivamente usada. |
| `profile` | string | Profile tecnológico efetivamente aplicado. |
| `governance_level` | `light`, `standard` ou `critical` | Nível de governança efetivamente aplicado. |
| `created_at` | timestamp RFC 3339 em UTC | Momento da geração. |

Exemplo estrutural do formato inicial:

Enquanto não existir um profile tecnológico oficial na Foundation, este exemplo é apenas estrutural e não representa um `FOUNDATION.lock` que possa ser gerado por uma execução válida.

```json
{
  "schema_version": "1.0",
  "foundation_version": "0.1.0",
  "profile": "<profile-existente-na-foundation>",
  "governance_level": "standard",
  "created_at": "2026-09-21T14:30:00Z"
}
```

`FOUNDATION.lock` registra a origem metodológica do projeto. Ele não é configuração mutável de produto, não recebe segredos e não deve ser alterado para simular uma geração diferente. Atualizações deliberadas da Foundation em um projeto existente exigem processo rastreável próprio.

## 4. Processo conceitual de geração

O bootstrap deve executar conceitualmente a seguinte sequência:

1. validar manifesto;
2. validar Foundation;
3. validar profile;
4. validar destino;
5. aplicar `templates/base`;
6. aplicar profile tecnológico;
7. aplicar regras do nível de governança;
8. substituir placeholders permitidos;
9. gerar `FOUNDATION.lock`;
10. inicializar Git, quando aplicável;
11. executar verificações;
12. reportar resultado.

O projeto deve ser tratado como repositório Git quando essa for a forma aplicável de gestão do produto e Git estiver disponível no ambiente. A definição dos comandos e de eventuais exceções operacionais pertence à futura implementação, não a este contrato.

## 5. Composição e precedência

### Base

A Base contém conteúdo universal, independente de linguagem, framework ou produto. `templates/base` é a referência inicial dessa camada.

### Profile

O Profile contém conteúdo específico de uma tecnologia e suas dependências justificadas. Ele só pode ser aplicado se existir na Foundation selecionada.

### Governança

A Governança adiciona controles proporcionais ao risco. `light` mantém o mínimo recuperável; `standard` exige a disciplina normal de sistemas com continuidade; `critical` adiciona controles, evidências, revisões e quality gates compatíveis com maior impacto ou risco.

A composição é aplicada na ordem Base → Profile → Governança. Em caso de conflito, garantias universais da Base prevalecem; a Governança pode acrescentar ou tornar controles mais rigorosos. Um Profile pode complementar pontos de extensão definidos pela Base, mas não pode remover, enfraquecer ou substituir silenciosamente garantias da Base. Conflitos não previstos ou remoções necessárias devem falhar ou ser objeto de decisão explícita e rastreável.

## 6. Placeholders

Templates podem conter placeholders de conteúdo no formato `{{IDENTIFICADOR}}`, com identificadores em maiúsculas, números e `_`. Os placeholders oficialmente permitidos nesta versão e seus valores de origem são:

| Placeholder | Campo de origem | Uso atual |
| --- | --- | --- |
| `{{PROJECT_NAME}}` | `project_name` | Nome legível do projeto em conteúdo de template. |
| `{{PROJECT_DESCRIPTION}}` | `description` | Descrição inicial do projeto em conteúdo de template. |
| `{{PROJECT_SLUG}}` | `project_slug` | Disponível como placeholder permitido; o uso atual de `project_slug` é a identificação estável e o diretório do projeto. Não é necessário inseri-lo artificialmente em documentos. |

Nesta versão, a substituição aplica-se somente ao conteúdo dos arquivos de template. Não há substituição nem renomeação de nomes de arquivos ou diretórios.

Marcadores editoriais entre colchetes, como `[DESCREVA_O_PROBLEMA]`, não são placeholders do bootstrap e devem permanecer no projeto gerado para preenchimento humano posterior.

Somente placeholders previamente permitidos pela Foundation podem ser substituídos. O bootstrap futuro deve detectar placeholders desconhecidos ou não resolvidos e tratá-los como falha de geração ou verificação, conforme a etapa aplicável. Esta especificação não implementa o mecanismo de substituição.

## 7. Segurança e integridade

O bootstrap deve:

- nunca sobrescrever silenciosamente um diretório de projeto existente;
- falhar de forma segura quando o destino não estiver vazio, até que exista modo explícito e especificado para esse caso;
- validar todas as entradas antes de modificar o filesystem;
- não apagar arquivos para resolver conflitos;
- não armazenar segredos no manifesto nem em `FOUNDATION.lock`;
- preservar evidência suficiente para reportar qualquer execução parcial com clareza.

Uma falha após o início da geração não autoriza limpeza destrutiva automática. O relatório deve identificar o destino, as etapas concluídas, a etapa que falhou e os arquivos ou estado parcial conhecidos.

## 8. Determinismo

Com a mesma `foundation_version`, o mesmo conteúdo de manifesto, o mesmo Profile e o mesmo nível de governança, o bootstrap deve produzir a mesma estrutura e o mesmo conteúdo derivado de templates. Valores legitimamente variáveis, como `created_at`, são exceções explícitas.

O bootstrap não deve depender de estado implícito da máquina, ordem não determinística de arquivos ou escolha automática de versão/profile diferente da solicitada.

## 9. Erros e resultado

Os códigos numéricos de saída permanecem em aberto. A implementação futura deve distinguir, ao menos, as seguintes categorias conceituais:

| Categoria | Quando ocorre |
| --- | --- |
| Manifesto inválido | JSON, esquema, campos ou valores não atendem ao contrato. |
| Foundation inválida | A versão solicitada não está disponível, não é reconhecida ou não é utilizável. |
| Profile inexistente | O profile solicitado não existe ou não é compatível com a Foundation selecionada. |
| Destino inválido | O caminho de destino é inadequado, inacessível ou não pode receber o projeto com segurança. |
| Conflito de arquivos | O destino contém arquivos, já existe projeto ou uma composição tentaria colidir sem regra explícita. |
| Falha na geração | Uma etapa de materialização, composição, substituição ou lock não é concluída. |
| Falha na verificação | A estrutura ou os gates definidos para o projeto gerado não são aprovados. |

O resultado deve informar sucesso ou falha, a categoria quando houver falha, a etapa alcançada e se houve estado parcial.

## 10. Critérios de aceite do futuro `New-Project`

A implementação futura será aceitável quando puder demonstrar que:

- aceita um manifesto válido e rejeita manifestos inválidos antes de escrever no destino;
- rejeita Foundation e Profile inexistentes ou incompatíveis;
- cria a Base, aplica o Profile e adiciona as regras de Governança na ordem definida;
- preserva garantias da Base diante da aplicação de Profile e Governança;
- substitui somente placeholders permitidos e detecta placeholders não resolvidos;
- gera `FOUNDATION.lock` com os campos obrigatórios e os valores efetivamente aplicados;
- não sobrescreve nem apaga conteúdo de destino existente;
- produz estrutura equivalente em execuções equivalentes, ressalvados valores variáveis declarados;
- inicializa Git quando aplicável e reporta quando não for possível;
- executa e reporta as verificações aplicáveis;
- em falha, retorna categoria clara e informa com precisão qualquer estado parcial.
- nesta fase, não trata os exemplos estruturais deste documento como instâncias executáveis de aceite; a demonstração com manifesto e lock semanticamente válidos depende de profile oficial e é obrigatória antes da implementação ou homologação do `New-Project`.

## 11. Exemplos estruturais completos

O par abaixo contém todos os campos do contrato, mas é estrutural e não executável enquanto não existir profile tecnológico oficial na Foundation. O valor de `profile` deve ser substituído pelo identificador de um profile realmente existente e compatível antes de qualquer geração; caso contrário, o manifesto real é inválido.

Manifesto:

```json
{
  "schema_version": "1.0",
  "project_name": "Catálogo Operacional",
  "project_slug": "catalogo-operacional",
  "description": "Organiza a consulta de itens e procedimentos operacionais.",
  "foundation_version": "0.1.0",
  "profile": "<profile-existente-na-foundation>",
  "governance_level": "light"
}
```

`FOUNDATION.lock` correspondente:

```json
{
  "schema_version": "1.0",
  "foundation_version": "0.1.0",
  "profile": "<profile-existente-na-foundation>",
  "governance_level": "light",
  "created_at": "2026-09-21T14:30:00Z"
}
```

## 12. Evolução dos exemplos

Assim que o primeiro profile tecnológico oficial existir, os exemplos desta especificação devem ser atualizados para usar seu identificador real antes da implementação ou homologação do `New-Project`.
