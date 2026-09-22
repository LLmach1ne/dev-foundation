# DEV FOUNDATION — Bootstrap Specification

**Versão do documento:** 0.1
**Status:** Stable — v1.0.0
**Escopo:** Foundation Core

## 1. Objetivo

Este documento define o contrato conceitual para criar um novo projeto com a DEV FOUNDATION. Um projeto é gerado pela composição de:

**Foundation Core + profile tecnológico existente + nível de governança + dados do projeto**

Esta especificação define o contrato implementado por `tools/New-Project.ps1` na v1. Ela descreve as garantias verificáveis do bootstrap, sem substituir os detalhes operacionais documentados no script e no padrão de ambiente.

## 2. Manifesto `project.bootstrap.json`

O arquivo `project.bootstrap.json` representa a solicitação de criação de um projeto. Ele deve ser validado integralmente antes de qualquer alteração no filesystem.

### 2.1 Campos

| Campo | Obrigatório | Formato | Significado e validação |
| --- | --- | --- | --- |
| `schema_version` | Sim | string de versão do esquema, inicialmente `"1.0"` | Identifica o contrato usado para interpretar o manifesto. A versão deve ser suportada pelo bootstrap. |
| `project_name` | Sim | string não vazia, com texto significativo | Nome legível do projeto. Não pode conter somente espaços. |
| `project_slug` | Sim | `^[a-z0-9]+(?:-[a-z0-9]+)*$` | Identificador estável usado em caminhos e placeholders. Deve ser único no destino escolhido e não pode ser `.` ou `..`. |
| `description` | Sim | string não vazia | Descrição breve do problema ou propósito inicial do projeto. Não pode conter somente espaços. |
| `foundation_version` | Sim | string de versão não vazia | Versão exata da Foundation a ser usada. Nesta Foundation, deve ser exatamente igual ao conteúdo de `VERSION`. |
| `profile` | Sim | string de identificador não vazia | Identificador do profile tecnológico. Deve corresponder a um profile existente e compatível com a `foundation_version` solicitada. Esta especificação não fixa quais profiles existem. |
| `governance_level` | Sim | enum | Nível de controles aplicáveis: `light`, `standard` ou `critical`. |

Não há campos opcionais na primeira versão do contrato. Um campo opcional futuro só poderá ser incluído quando tiver justificativa operacional clara, sem deslocar dados de produto, segredos ou configurações mutáveis para o manifesto.

### 2.2 Exemplo estrutural

O exemplo a seguir é estruturalmente completo e usa o profile tecnológico oficial `dotnet-web`. Ele ilustra uma referência de profile existente, mas não torna esse profile obrigatório para outros projetos.

```json
{
  "schema_version": "1.0",
  "project_name": "Portal de Atendimento",
  "project_slug": "portal-atendimento",
  "description": "Centraliza solicitações e acompanhamento de atendimento.",
  "foundation_version": "1.0.0",
  "profile": "dotnet-web",
  "governance_level": "standard"
}
```

O valor de `profile` no exemplo corresponde a um profile oficial. Em qualquer manifesto real, o identificador continua devendo referir um profile que exista e seja compatível com a `foundation_version` selecionada; um profile inexistente ou incompatível torna o manifesto inválido.

### 2.3 Regras gerais de validação

- O documento deve ser JSON válido e conter exatamente os campos definidos para a versão do esquema; campos desconhecidos devem falhar até serem especificados em versão futura.
- Os valores de texto devem ser interpretados como dados, nunca como comandos, caminhos arbitrários ou conteúdo a executar.
- `project_slug` não pode ser transformado silenciosamente pelo bootstrap. Se não obedecer ao formato, a solicitação falha.
- `foundation_version`, `profile` e `governance_level` devem ser resolvidos e validados antes da criação do destino. Nesta Foundation, `foundation_version` deve ser igual, caractere a caractere, ao conteúdo de `VERSION`; qualquer outro valor torna o manifesto inválido.
- `governance_level` deve ser exatamente `light`, `standard` ou `critical`. O diretório `governance/<governance_level>/template/` correspondente deve existir antes da criação do destino.
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

Este exemplo usa o profile tecnológico oficial `dotnet-web` e ilustra o formato de um `FOUNDATION.lock` correspondente. Outros projetos devem registrar o profile efetivamente aplicado.

```json
{
  "schema_version": "1.0",
  "foundation_version": "1.0.0",
  "profile": "dotnet-web",
  "governance_level": "standard",
  "created_at": "2026-09-21T14:30:00Z"
}
```

`FOUNDATION.lock` registra a origem metodológica do projeto. Ele não é configuração mutável de produto, não recebe segredos e não deve ser alterado para simular uma geração diferente. Atualizações deliberadas da Foundation em um projeto existente exigem processo rastreável próprio.

O campo `foundation_version` do lock deve reproduzir exatamente o valor validado no manifesto e, nesta Foundation, portanto o conteúdo de `VERSION`.

## 4. Processo conceitual de geração

O bootstrap deve executar conceitualmente a seguinte sequência:

1. validar manifesto;
2. validar Foundation;
3. validar profile;
4. validar destino;
5. aplicar `templates/base`;
6. aplicar profile tecnológico;
7. aplicar o overlay concreto `governance/<governance_level>/template/`;
8. substituir placeholders permitidos;
9. gerar `FOUNDATION.lock`;
10. inicializar Git, quando aplicável;
11. executar verificações;
12. reportar resultado.

O bootstrap inicializa o projeto como repositório Git em `main` quando o Git exigido pelo ambiente está disponível. Ele não configura identidade, credenciais ou remoto; os requisitos e limites operacionais estão em `ENVIRONMENT_STANDARD.md`.

## 5. Composição e precedência

### Base

A Base contém conteúdo universal, independente de linguagem, framework ou produto. `templates/base` é a referência inicial dessa camada.

### Profile

O Profile contém conteúdo específico de uma tecnologia e suas dependências justificadas. Ele só pode ser aplicado se existir na Foundation selecionada.

### Governança

A Governança adiciona controles proporcionais ao risco. `light` mantém o mínimo recuperável; `standard` exige a disciplina normal de sistemas com continuidade; `critical` adiciona controles, evidências, revisões e quality gates compatíveis com maior impacto ou risco. O padrão de obrigações de cada nível é definido em `docs/GOVERNANCE_STANDARD.md`.

Nesta Foundation, a Governança é materializada exclusivamente pelo overlay concreto `governance/<governance_level>/template/`, aplicado depois de Base e Profile. O bootstrap deve aceitar somente os níveis `light`, `standard` e `critical`, exigir a existência do overlay correspondente, enumerar seus arquivos em ordem determinística e detectar todas as colisões com Base, Profile ou o destino antes de escrever qualquer arquivo. Sem uma regra explícita de composição para uma colisão, a geração deve falhar; nesta etapa não há sobrescrita nem merge automático de arquivos.

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

Somente placeholders previamente permitidos pela Foundation podem ser substituídos. O bootstrap implementado detecta placeholders desconhecidos ou não resolvidos e os trata como falha de geração ou verificação, conforme a etapa aplicável.

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

O comando retorna `0` em sucesso e `1` em falha. A mensagem de falha informa categoria, etapa alcançada e estado parcial; as categorias conceituais são, ao menos:

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

## 10. Critérios de aceite do `New-Project`

A implementação da v1 deve demonstrar que:

- aceita um manifesto válido e rejeita manifestos inválidos antes de escrever no destino;
- rejeita Foundation e Profile inexistentes ou incompatíveis, inclusive `foundation_version` diferente do conteúdo de `VERSION` nesta Foundation;
- aceita somente `light`, `standard` ou `critical`, exige o overlay `governance/<governance_level>/template/` correspondente e falha se ele não existir;
- cria a Base, aplica o Profile e aplica o overlay de Governança na ordem definida;
- detecta colisões de composição antes de escrever e não sobrescreve nem faz merge automático sem regra explícita;
- preserva garantias da Base diante da aplicação de Profile e Governança;
- substitui somente placeholders permitidos e detecta placeholders não resolvidos;
- gera `FOUNDATION.lock` com os campos obrigatórios e os valores efetivamente aplicados;
- não sobrescreve nem apaga conteúdo de destino existente;
- produz estrutura equivalente em execuções equivalentes, ressalvados valores variáveis declarados;
- inicializa Git quando aplicável e reporta quando não for possível;
- executa e reporta as verificações aplicáveis;
- em falha, retorna categoria clara e informa com precisão qualquer estado parcial.
- trata os exemplos estruturais deste documento como referências que usam um profile oficial; sua presença não substitui a validação de manifesto, Foundation, profile e `FOUNDATION.lock` exigida antes da geração ou homologação do `New-Project`.

## 11. Exemplos estruturais completos

O par abaixo contém todos os campos do contrato e usa o profile tecnológico oficial `dotnet-web`. Ele é ilustrativo e não restringe outros projetos a esse profile. Em qualquer geração, o profile selecionado deve existir e ser compatível com a Foundation; caso contrário, o manifesto real é inválido.

Manifesto:

```json
{
  "schema_version": "1.0",
  "project_name": "Catálogo Operacional",
  "project_slug": "catalogo-operacional",
  "description": "Organiza a consulta de itens e procedimentos operacionais.",
  "foundation_version": "1.0.0",
  "profile": "dotnet-web",
  "governance_level": "light"
}
```

`FOUNDATION.lock` correspondente:

```json
{
  "schema_version": "1.0",
  "foundation_version": "1.0.0",
  "profile": "dotnet-web",
  "governance_level": "light",
  "created_at": "2026-09-21T14:30:00Z"
}
```

## 12. Evolução dos exemplos

Os exemplos desta especificação usam `dotnet-web`, o primeiro profile tecnológico oficial. Eles podem ser atualizados para outros profiles oficiais quando isso for útil para ilustrar o contrato, sem tornar qualquer profile obrigatório para todos os projetos.
