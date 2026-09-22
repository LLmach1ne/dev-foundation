# DEV FOUNDATION — Codex Standard

**Versão do documento:** 0.1
**Status:** Draft
**Escopo:** Foundation

## 1. Objetivo

Este documento define como o Codex deve ser configurado e utilizado nos projetos desenvolvidos sob a DEV FOUNDATION.

VS Code e Codex pertencem ao fluxo de engenharia da metodologia, mas não são
requisitos técnicos para `New-Project.ps1` gerar um projeto. Instalação,
autenticação e atualização dessas ferramentas são passos humanos; os requisitos
do gerador e dos profiles estão em [Environment Standard](ENVIRONMENT_STANDARD.md).

## 2. Camadas de configuração

A configuração do Codex é dividida em duas camadas principais.

### Global

Local:

`%USERPROFILE%\.codex\`

Responsável por configurações do usuário e estado local do Codex.

A Foundation controla diretamente apenas as instruções globais reutilizáveis por meio de:

`%USERPROFILE%\.codex\AGENTS.md`

A versão mestre dessas instruções fica em:

`dev-foundation/global/codex/AGENTS.md`

Para aplicar essas instruções em uma máquina nova, a pessoa responsável deve
ler a versão versionada, comparar seu conteúdo com o `AGENTS.md` global já
existente e decidir conscientemente se e como incorporá-lo. A Foundation não
substitui nem mescla esse arquivo automaticamente.

### Projeto

Cada repositório pode possuir:

`AGENTS.md`

e:

`.codex/config.toml`

para instruções e configurações específicas daquele projeto.

Configurações específicas de produto não devem ser colocadas na camada global.

## 3. config.toml global

O arquivo:

`%USERPROFILE%\.codex\config.toml`

não deve ser substituído integralmente pela Foundation.

Ele pode conter:

- preferências pessoais;
- configurações gerenciadas pelo aplicativo;
- plugins;
- MCPs;
- estado de projetos;
- funcionalidades experimentais;
- configurações específicas da máquina.

Scripts da Foundation devem preservar esse arquivo, salvo quando uma alteração específica e explicitamente aprovada for necessária.

Qualquer alteração global exige revisão humana prévia. Ela deve preservar
preferências, integrações e estado local existentes, e nunca incluir
credenciais, tokens ou arquivos de autenticação no repositório.

## 4. AGENTS.md global

O arquivo global contém apenas regras universais de engenharia.

Ele deve permanecer:

- curto;
- estável;
- independente de stack;
- independente de produto;
- seguro para reutilização em todos os repositórios.

Regras específicas devem permanecer no repositório correspondente.

## 5. Configuração por projeto

Projetos confiáveis podem utilizar:

`.codex/config.toml`

para definir comportamento necessário àquele repositório.

A configuração do projeto deve ser mínima e justificada.

A Foundation poderá fornecer defaults apropriados através de seus templates.

## 6. Modelo e esforço de raciocínio

A Foundation não fixa permanentemente um modelo específico como requisito universal.

A seleção deve acompanhar:

- complexidade;
- ambiguidade;
- risco;
- custo de uso.

Política inicial:

- tarefas simples e mecânicas: esforço baixo ou médio;
- features normais e bem especificadas: esforço médio;
- bugs difíceis, arquitetura, segurança e migrations críticas: esforço alto quando necessário.

O esforço mais alto não deve ser utilizado como padrão sem necessidade.

## 7. Planejamento

Para tarefas simples e bem definidas, o Codex pode executar diretamente.

Para trabalhos complexos, ambíguos ou de alto risco:

1. investigar;
2. elaborar plano;
3. validar abordagem quando necessário;
4. implementar;
5. verificar.

## 8. Segurança

A Foundation deve preferir:

- acesso restrito ao workspace;
- aprovação para ações que escapem do escopo esperado;
- preservação de alterações existentes;
- proibição de operações destrutivas sem autorização explícita.

Credenciais, tokens e arquivos de autenticação nunca devem ser adicionados ao repositório.

## 9. Verificação

O Codex não deve declarar sucesso apenas porque uma alteração foi escrita.

Deve executar os gates aplicáveis e reportar:

- alterações realizadas;
- verificações executadas;
- resultado dos testes;
- riscos ou limitações restantes.

## 10. Evolução

Quando um comportamento indesejado do Codex se repetir em diferentes projetos, deve-se avaliar se a prevenção pertence a:

- AGENTS global;
- AGENTS do projeto;
- testes;
- quality gates;
- scripts;
- documentação;
- arquitetura.

A Foundation deve evoluir a partir de problemas reais, não de regras preventivas sem evidência.
