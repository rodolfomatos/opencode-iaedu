# Hostile Insights Registry

## [Error Handling] - IAEDU API call sem try/catch
- **Task**: T001 — Code review
- **Insight**: A função `callIAEDU` não tinha tratamento de erro no axios POST.
  Se a API devolvesse 4xx/5xx, o erro propagava como unhandled rejection no
  handler MCP, dando uma mensagem enigmática ao utilizador.
- **Origin**: Revisão sistemática (Lens 1 — Correctness)
- **Applied To**: Adicionado try/catch com mensagem descritiva (HTTP status + detail)
- **Date**: 2026-06-25

## [API Design] - Parâmetro `model` aceite mas ignorado
- **Task**: T001 — Code review
- **Insight**: A tool `complete` aceitava `model` como parâmetro opcional mas ignorava-o.
  O utilizador podia pedir um modelo inexistente sem qualquer feedback.
- **Origin**: Revisão sistemática (Lens 1 — Correctness)
- **Applied To**: Adicionada validação com mensagem de erro clara
- **Date**: 2026-06-25
