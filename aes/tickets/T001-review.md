---
ticket: T001
phase: review
status: done
created: 2026-06-25
verdict: approved-with-conditions
---

# T001 — Code review and documentation audit

## Decision: APPROVED WITH CONDITIONS

## Summary
Código funcional e bem estruturado para um projeto deste tamanho (142 linhas no index.js). A separação API client / MCP wiring / CLI entry point está clara. Faltam comentários nos exports e tratamento de erros na chamada axios. Os testes usam InMemoryTransport corretamente mas têm uma variável morta.

## Problems Found

### Blocking
None

### Important
1. **callIAEDU sem try/catch no axios POST** — se a API do IAEDU falhar (4xx/5xx/network), o erro propaga como unhandled rejection no handler do MCP tool. A mensagem de erro pode ser enigmática para o utilizador.
2. **Módulo com side effects ao importar** — `dotenv.config()` e captura de `process.env` correm no load do módulo. Dificulta testes com env vars diferentes e impede re-import limpo.
3. **Parâmetro `model` ignorado no tool handler** — a tool `complete` aceita `model` mas nunca o usa. O utilizador pode passar um modelo diferente e receber o default sem feedback.

### Suggestions
1. Adicionar JSDoc nos exports (`callIAEDU`, `createServer`, `MODELS`)
2. Remover `session` não usado no test/provider.test.js
3. `normalizeEndpoint` é uma função de 5 linhas usada uma vez — pode ser inline
4. `MODELS` devia descrever o modelo real (ou ler dum config) em vez de ser hardcoded

## Highlights
- Uso correto do `InMemoryTransport.createLinkedPair()` nos testes — padrão recomendado pelo MCP SDK
- SSE parsing robusto com buffer parcial e `[DONE]` sentinel
- Deteção de symlink no `process.argv[1]` com `realpathSync` — permite correr via `npm -g install`

## Backlog Tickets Created
None (all issues are fixable within this ticket)

## Context for Learn
- A opção de ler config de 3 sítios diferentes (.env, ~/.config/iaedu/env, env vars) foi copiada do llm-iaedu e funciona bem
- A decisão de MCP server vs provider plugin foi acertada — o ecossistema opencode suporta bem MCPs locais com stdio
