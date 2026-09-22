# DEV FOUNDATION — Governance Standard

**Versão do documento:** 0.1
**Status:** Draft
**Escopo:** Foundation Core

## Objetivo

Este padrão define os controles mínimos proporcionais ao risco para projetos gerados pela DEV FOUNDATION. Ele é independente de stack e produto. A aplicação concreta de cada nível é registrada em `FOUNDATION.lock` e materializada em `docs/GOVERNANCE.md` pelo overlay de governança correspondente.

Os controles devem ser aplicados somente quando forem relevantes ao projeto e à alteração. Exemplos de artefatos, testes, revisões ou planos não criam, por si só, requisitos artificiais.

## Light

Light destina-se a mudanças de baixo risco. Deve manter somente a governança que agrega valor:

- requisitos e critérios de aceite suficientes para executar e verificar a mudança;
- verificações aplicáveis ao comportamento e ao risco envolvidos;
- homologação humana da entrega e de suas evidências;
- documentação e processo proporcionais, evitando artefatos que não agreguem valor.

Os documentos Base normalmente relevantes são `docs/PRODUCT.md`, `docs/REQUIREMENTS.md` e `docs/QUALITY.md`.

## Standard

Standard inclui tudo que for essencial do Light e exige, de forma proporcional:

- requisitos identificáveis;
- arquitetura relevante documentada;
- rastreabilidade entre requisitos, implementação, verificações e homologação;
- estratégia de testes e quality gates aplicáveis;
- evidência registrada de homologação.

Os documentos Base normalmente relevantes são `docs/PRODUCT.md`, `docs/REQUIREMENTS.md`, `docs/ARCHITECTURE.md`, `docs/QUALITY.md` e `docs/TRACEABILITY.md`.

## Critical

Critical inclui tudo do Standard e adiciona, quando aplicável:

- análise explícita dos riscos relevantes;
- revisão independente;
- controles de segurança relevantes;
- plano de rollback ou recuperação;
- evidências mais fortes de verificação e aprovação antes de release.

Os documentos Base normalmente relevantes são `docs/PRODUCT.md`, `docs/REQUIREMENTS.md`, `docs/ARCHITECTURE.md`, `docs/QUALITY.md`, `docs/TRACEABILITY.md` e os registros em `docs/decisions/`.

## Uso

Este padrão define obrigações de governança; não substitui requisitos de produto, decisões arquiteturais nem procedimentos específicos de uma stack. A seleção do nível deve refletir porte, impacto e risco reais da iniciativa.
