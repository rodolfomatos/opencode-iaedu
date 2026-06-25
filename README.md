# opencode-iaedu

MCP server for IAEDU models — use IAEDU as tools inside opencode.

```bash
# One-liner (recomendado)
curl -fsSL https://raw.githubusercontent.com/rodolfomatos/opencode-iaedu/main/install.sh | bash
```

Provides the `complete` tool to send prompts to IAEDU models and `list_models` to view available models.

## Installation

### Opção 1 — curl (recomendado)

```bash
curl -fsSL https://raw.githubusercontent.com/rodolfomatos/opencode-iaedu/main/install.sh | bash
```

O script faz tudo: instala dependências, pede credenciais, instala globalmente e regista o MCP server no opencode.

### Opção 2 — make

```bash
git clone https://github.com/rodolfomatos/opencode-iaedu.git
cd opencode-iaedu
make install
```

### Opção 3 — manual

```bash
git clone https://github.com/rodolfomatos/opencode-iaedu.git
cd opencode-iaedu
npm install
npm install -g .
```

Depois regista o MCP no `~/.config/opencode/opencode.jsonc`:

```jsonc
{
  "mcp": {
    "iaedu": {
      "type": "local",
      "command": ["opencode-iaedu"]
    }
  }
}
```

## Configuração

As credenciais são carregadas por esta ordem:
1. Variáveis de ambiente (`IAEDU_API_KEY`, `IAEDU_CHANNEL_ID`, `IAEDU_AGENT_ID`)
2. Ficheiro `.env` no diretório atual
3. Ficheiro `~/.config/iaedu/env` (criado pelo `make configure` ou pelo `install.sh`)

Podes defini-las manualmente:

```bash
export IAEDU_API_KEY="your-api-key"
export IAEDU_CHANNEL_ID="your-channel-id"
export IAEDU_AGENT_ID="your-agent-id"
```

## Uso

Numa sessão opencode, pede ao agente para usar a ferramenta IAEDU:

> *"usa a complete tool do IAEDU para responder: o que é a capital de Portugal?"*

O agente descobre e invoca a ferramenta `complete` automaticamente.

## Tools MCP

- **`complete`** — Envia um prompt para um modelo IAEDU e devolve a resposta
- **`list_models`** — Lista os modelos IAEDU disponíveis

## Makefile

| Target | Descrição |
|--------|-----------|
| `make install` | Instalação completa (interativa) |
| `make setup` | `npm install` |
| `make configure` | Configuração interativa de credenciais |
| `make install-deps` | `npm install -g .` |
| `make mcp-add` | Regista o MCP server no opencode |
| `make check` | Verifica configuração e binário |
| `make test` | Corre os testes |

## Desenvolvimento

O projeto segue o protocolo AES (Aggressive Engineering System).

```
aes/
├── kanban.md              → estado global do projeto
├── sprints/               → sprints e retrospectivas
├── tickets/               → tickets com fases plan/build/verify/review/learn
├── handoffs/              → continuidade entre sessões
└── verification/          → output de testes e logs
docs/
├── VISION.md              → problema, solução, valor
├── REQUIREMENTS.md        → requisitos funcionais e não-funcionais
├── ROADMAP.md             → backlog e prioridades
└── HOSTILE_INSIGHTS.md    → lições aprendidas
CLAUDE.md                  → contrato operacional
```

```bash
make test        # vitest (5 testes, InMemoryTransport)
```

## Como funciona

Comunica com a API do IAEDU via form-data POST + SSE streaming, embalado como um servidor MCP stdio. Usa `@modelcontextprotocol/sdk` para a comunicação com o opencode.

Inspirado pelo [llm-iaedu](https://github.com/rodolfomatos/llm-iaedu).
