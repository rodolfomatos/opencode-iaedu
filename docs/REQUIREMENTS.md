# Requirements

## Functional
- Expose `complete` tool: send prompt → receive IAEDU completion text
- Expose `list_models` tool: return available IAEDU model list
- Support `--list-models` CLI flag for standalone inspection
- Parse SSE streaming responses from IAEDU API
- Load credentials from env vars, .env, or ~/.config/iaedu/env

## Non-Functional
- Communicate via stdin/stdout (MCP stdio transport)
- Timeout after 120s for IAEDU API calls
- No external runtime state — stateless per-request
