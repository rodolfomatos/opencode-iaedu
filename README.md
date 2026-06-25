# opencode-iaedu

MCP server for IAEDU models — use IAEDU as tools inside opencode.

Provides the `complete` tool to send prompts to IAEDU models and `list_models` to view available models.

## Installation

```bash
npm install -g /path/to/opencode-iaedu
```

## Configuration

Set credentials via env vars:

```bash
export IAEDU_API_KEY="your-api-key"
export IAEDU_CHANNEL_ID="your-channel-id"
export IAEDU_AGENT_ID="your-agent-id"
```

Or via `~/.config/iaedu/env` or a local `.env` file.

## Usage

Add to `opencode.jsonc`:

```jsonc
{
  "mcp": {
    "iaedu": {
      "type": "local",
      "command": ["opencode-iaedu"],
      "environment": {
        "IAEDU_API_KEY": "your-api-key",
        "IAEDU_CHANNEL_ID": "your-channel-id",
        "IAEDU_AGENT_ID": "your-agent-id"
      }
    }
  }
}
```

Or run: `opencode mcp add iaedu`

Then in an opencode session, ask: *"Use the IAEDU complete tool to answer: what is the capital of Portugal?"*

## Tools

- **`complete`** — Send a prompt to an IAEDU model
- **`list_models`** — List available IAEDU models

## How It Works

Communicates with the IAEDU API via form-data POST + SSE streaming, packaged as a stdio-based MCP server.

Inspired by [llm-iaedu](https://github.com/rodolfomatos/llm-iaedu).
