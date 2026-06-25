# CLAUDE.md — opencode-iaedu

## Project
MCP server for IAEDU models. Runs as a stdio-based MCP server that provides
`complete` and `list_models` tools to opencode.

## Commands
- `make test` — run vitest suite
- `make install-deps` — npm install -g .
- `make check` — verify credentials and binary
- `make configure` — interactive credential setup

## Critical Files
- `index.js` — entry point, MCP server, IAEDU API client
- `test/provider.test.js` — test suite using InMemoryTransport

## Never Do
- Do not add emojis to source code
- Do not add external runtime dependencies without discussion
- Do not modify the IAEDU API integration without updating tests
