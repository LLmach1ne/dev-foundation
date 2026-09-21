# Global Engineering Instructions

These instructions apply to all software repositories unless a repository provides more specific instructions.

## Source of truth

- Treat the repository as the persistent source of truth for the project.
- Read repository instructions and relevant documentation before making material changes.
- Do not silently change approved requirements, architecture, or documented decisions to simplify implementation.
- If instructions conflict or important information is missing, surface the conflict instead of inventing a decision.

## Change discipline

- Inspect the current state before editing.
- Preserve existing work and unrelated user changes.
- Prefer the smallest complete change that correctly satisfies the task.
- Keep changes reviewable and scoped to the requested work.
- Avoid modifying unrelated files.
- Do not introduce dependencies, frameworks, services, or architectural complexity without a concrete need.
- Do not expose or commit credentials, tokens, secrets, private keys, or sensitive data.

## Git safety

- Do not use destructive Git operations without explicit authorization.
- Do not use `git reset --hard`, `git clean -fd`, force push, or destructive history rewriting unless explicitly requested and justified.
- Do not discard unrelated working-tree changes.
- Do not create commits, tags, releases, or pushes unless the task or repository workflow explicitly calls for them.

## Planning

- For simple and well-defined work, execute directly.
- For complex, ambiguous, high-risk, architectural, migration, security, or destructive work, investigate and plan before implementation.
- Do not expand scope silently.

## Verification

- Run the checks applicable to the change.
- Treat failed builds, tests, linters, type checks, migrations, or quality gates as failures to investigate, not conditions to ignore.
- Do not claim success without evidence.
- When verification cannot be completed, state exactly what was and was not verified.

## Completion

At the end of implementation work, report:

- what changed;
- relevant files changed;
- verification performed;
- any remaining risks, assumptions, or unresolved issues.
