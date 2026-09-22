# DEV FOUNDATION — Profile Specification

**Versão do documento:** 0.1
**Status:** Stable — v1.0.0
**Escopo:** Profiles tecnológicos da Foundation

## 1. Objetivo

Este documento define o contrato mínimo dos profiles tecnológicos usados pelo
bootstrap da DEV FOUNDATION.

Um profile representa conteúdo e regras específicos de uma stack tecnológica.
Ele pode atender, por exemplo, a categorias de aplicações web, APIs ou
ferramentas CLI. Essas categorias são conceituais; profiles oficiais são
materializados e publicados separadamente na Foundation. Na v1, `dotnet-web`
é o primeiro profile oficial existente.

Um projeto é composto por **Base + Profile + Governança + dados do produto**.
O profile acrescenta somente o que é necessário para a tecnologia selecionada;
ele não define requisitos ou decisões de produto.

## 2. Identificação

Todo profile deve possuir um identificador estável, usado no campo `profile` de
`project.bootstrap.json`. O identificador deve obedecer a:

- letras minúsculas, números e hífens;
- palavras separadas por um único hífen;
- nenhum espaço;
- formato `^[a-z0-9]+(?:-[a-z0-9]+)*$`;
- imutabilidade após a publicação do profile na Foundation.

O identificador é uma referência técnica, não um rótulo livre. Renomeá-lo após
publicação é uma mudança incompatível da Foundation.

## 3. Estrutura física conceitual

Todo profile oficial possui, no mínimo, a estrutura abaixo.

```text
profiles/
└── <profile-id>/
    ├── profile.json
    └── template/
```

- `profile.json` contém os metadados e o contrato do profile.
- `template/` contém os arquivos específicos da tecnologia que serão compostos
  sobre `templates/base`.

## 4. Manifesto `profile.json`

O manifesto deve ser JSON válido e conter somente os campos mínimos abaixo
nesta fase:

| Campo | Obrigatório | Regra |
| --- | --- | --- |
| `schema_version` | Sim | String da versão do esquema de profile suportada pela Foundation. |
| `id` | Sim | Identificador estável que deve obedecer à convenção desta especificação. |
| `name` | Sim | Nome legível não vazio. |
| `description` | Sim | Descrição breve e não vazia do propósito tecnológico. |

Não há campos opcionais definidos inicialmente. Campos adicionais só devem ser
incluídos quando houver necessidade concreta e especificada. Profiles fazem
parte da própria versão da Foundation; portanto, esta fase não define ranges ou
um mecanismo adicional de compatibilidade. O profile usado deve existir na
versão da Foundation indicada pelo bootstrap.

## 5. Responsabilidades permitidas

Quando necessário para a stack, um profile pode adicionar:

- estrutura de código;
- arquivos de configuração da stack;
- configuração de build e testes;
- arquivos de VS Code;
- configuração local do Codex;
- scripts específicos da stack;
- documentação complementar;
- regras adicionais de `.gitignore` específicas da tecnologia.

O conteúdo adicionado deve permanecer genérico para a tecnologia e compatível
com as garantias da Base e o nível de governança aplicável.

## 6. Restrições

Um profile não pode:

- remover silenciosamente garantias da Base;
- enfraquecer regras de segurança;
- modificar requisitos de produto ou incluir regras de um produto específico;
- armazenar secrets, tokens, chaves privadas ou outras credenciais;
- depender de caminhos absolutos da máquina do autor;
- substituir arquivos da Base sem regra explícita de composição;
- executar ações destrutivas silenciosamente.

## 7. Composição Base + Profile

A composição é aplicada de forma determinística, na ordem **Base → Profile →
Governança**, conforme `BOOTSTRAP_SPEC.md`. A mesma versão da Foundation, o
mesmo manifesto, profile e nível de governança devem produzir a mesma estrutura
derivada de templates, exceto valores explicitamente variáveis.

Um arquivo já existente na Base não pode ser sobrescrito silenciosamente pelo
profile. Uma colisão somente é permitida quando este contrato passar a definir
expressamente a regra de composição para aquele caso; caso contrário, é erro.
Nesta fase não há merge automático de arquivos.

## 8. Relação com Governance

A Base define garantias universais e independentes de stack. O profile define
apenas o conteúdo tecnológico. A Governança adiciona controles proporcionais ao
risco do projeto.

Um profile pode fornecer mecanismos para atender controles aplicáveis, mas não
pode reduzir exigências impostas pelo nível de governança. A Governança pode
acrescentar controles ou torná-los mais rigorosos.

## 9. Relação com `AGENTS.md`

As instruções globais e as instruções de projeto fornecidas pela Base permanecem
válidas. Se uma stack exigir instruções adicionais, o profile pode fornecê-las
como complemento explícito, limitado à tecnologia e compatível com as regras da
Base.

Instruções do profile não podem contradizer silenciosamente `AGENTS.md` da Base
nem reduzir suas garantias. Esta especificação não define, por enquanto, um
merge complexo de `AGENTS.md`; qualquer colisão segue a regra conservadora de
composição e deve falhar se não houver regra explícita.

## 10. Validação de um profile

Antes de poder ser usado pelo bootstrap, deve ser possível verificar ao menos
que:

- o diretório esperado do profile existe;
- `profile.json` existe e contém JSON válido;
- o `id` do manifesto corresponde ao nome do diretório;
- todos os campos obrigatórios estão presentes e são válidos;
- o conteúdo de `profile.json` e de `template/` não contém caminhos absolutos
  nem secrets conhecidos;
- a composição proposta não produz conflitos proibidos com a Base ou a
  Governança.

As verificações de estrutura, existência, JSON, campos obrigatórios e coerência
de identificador são diretamente automatizáveis. A detecção de caminhos
absolutos e de padrões de secrets conhecidos também pode ser automatizada, mas
é heurística e não prova a ausência de todo secret possível; casos suspeitos
exigem revisão apropriada. Sua automação pode evoluir com o bootstrap sem
alterar este contrato.

## 11. Critérios de aceite para profile oficial

Um profile candidato a publicação na Foundation só pode ser considerado pronto
quando houver evidência verificável de que:

- sua estrutura e metadados são válidos;
- sua documentação explica o propósito, os pré-requisitos e a forma de
  verificar o conteúdo específico da stack;
- sua geração foi testada em projeto descartável;
- build, testes e `verify` aplicáveis passam;
- não há conflitos proibidos com a Base;
- não há dependência de produto específico, caminhos locais ou secrets;
- os controles do nível de governança selecionado permanecem preservados.

## 12. Evolução

Profiles são versionados junto com a Foundation. Mudanças incompatíveis devem
seguir o versionamento da Foundation, inclusive quando afetarem o identificador
ou o contrato de um profile.

Um profile evoluído não modifica silenciosamente projetos já gerados. A origem
da geração permanece registrada em `FOUNDATION.lock`, incluindo a versão da
Foundation, o profile e o nível de governança efetivamente aplicados. Uma
atualização de projeto existente requer processo deliberado e rastreável.

## 13. Exemplo estrutural

O exemplo abaixo mostra apenas o formato do manifesto. `<profile-id>` é um
identificador deliberadamente fictício e não representa profile oficial,
existente ou utilizável.

```json
{
  "schema_version": "1.0",
  "id": "<profile-id>",
  "name": "Nome ilustrativo do profile",
  "description": "Descrição estrutural, sem representar uma stack oficial."
}
```
