#!/usr/bin/env node
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { fileURLToPath } from 'url';
import { realpathSync } from 'fs';
import { z } from 'zod';
import axios from 'axios';
import dotenv from 'dotenv';
import { v4 as uuidv4 } from 'uuid';

dotenv.config();
const localEnv = dotenv.config({ path: '.env' });
if (localEnv.error) {
  dotenv.config({ path: `${process.env.HOME}/.config/iaedu/env` });
}

const IAEDU_ENDPOINT = process.env.IAEDU_ENDPOINT;
const IAEDU_API_KEY = process.env.IAEDU_API_KEY;
const IAEDU_CHANNEL_ID = process.env.IAEDU_CHANNEL_ID;
const IAEDU_AGENT_ID = process.env.IAEDU_AGENT_ID;

export const MODELS = [
  { id: 'iaedu/default', name: 'IAEDU Default', description: 'Default IAEDU language model' },
];

function getEndpoint() {
  if (IAEDU_ENDPOINT) {
    let url = IAEDU_ENDPOINT.trim();
    while (url.endsWith('/')) url = url.slice(0, -1);
    return url;
  }
  if (IAEDU_AGENT_ID) return `https://api.iaedu.pt/agent-chat/api/v1/agent/${IAEDU_AGENT_ID}/stream`;
  throw new Error('IAEDU endpoint not configured. Set IAEDU_ENDPOINT or IAEDU_AGENT_ID.');
}

/**
 * Envia um prompt para a API do IAEDU e retorna o texto completo da resposta.
 * A API usa form-data POST com SSE (Server-Sent Events) para streaming.
 * Esta função consome o stream e devolve o texto concatenado.
 */
export async function callIAEDU(prompt, system) {
  const endpoint = getEndpoint();
  const formData = new FormData();
  formData.append('thread_id', uuidv4());
  formData.append('user_info', '{}');
  formData.append('channel_id', IAEDU_CHANNEL_ID);
  formData.append('message', system ? `${system}\n\n${prompt}` : prompt);

  let response;
  try {
    response = await axios.post(endpoint, formData, {
      headers: { 'x-api-key': IAEDU_API_KEY },
      timeout: 120000,
      responseType: 'stream',
    });
  } catch (err) {
    const detail = err.response?.status ? `HTTP ${err.response.status}` : err.message;
    throw new Error(`IAEDU API request failed: ${detail}`);
  }

  let fullText = '';
  const reader = response.data.getReader();
  const decoder = new TextDecoder('utf-8');
  let buffer = '';

  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      buffer += decoder.decode(value, { stream: true });
      let pos;
      while ((pos = buffer.indexOf('\n')) !== -1) {
        const line = buffer.slice(0, pos);
        buffer = buffer.slice(pos + 1);
        if (!line.startsWith('data: ')) continue;
        const dataStr = line.slice(6).trim();
        if (dataStr === '[DONE]') return fullText;
        try {
          const data = JSON.parse(dataStr);
          if (data.type === 'token' && data.content) fullText += data.content;
        } catch {
          // Linha SSE com formato inesperado — ignora silenciosamente
        }
      }
    }
  } finally {
    reader.releaseLock();
  }

  return fullText;
}

/**
 * Cria e configura o servidor MCP com as ferramentas `complete` e `list_models`.
 * Exportada para ser usada tanto pelo entry point CLI como pelos testes (via InMemoryTransport).
 */
export function createServer() {
  const server = new McpServer(
    { name: 'opencode-iaedu', version: '1.0.0' },
    { capabilities: { tools: {} } }
  );

  server.tool(
    'complete',
    'Send a prompt to an IAEDU model and get a completion',
    {
      prompt: z.string().describe('The user prompt to send'),
      system: z.string().optional().describe('Optional system message'),
      model: z.string().optional().describe('Model identifier (only iaedu/default is available)'),
    },
    async ({ prompt, system, model }) => {
      if (model && model !== 'iaedu/default') {
        return {
          content: [{ type: 'text', text: `Model "${model}" not found. Available: iaedu/default` }],
          isError: true,
        };
      }
      const text = await callIAEDU(prompt, system);
      return { content: [{ type: 'text', text }] };
    }
  );

  server.tool(
    'list_models',
    'List available IAEDU models',
    {},
    async () => {
      return { content: [{ type: 'text', text: JSON.stringify(MODELS, null, 2) }] };
    }
  );

  return server;
}

async function main() {
  const args = process.argv.slice(2);
  if (args.includes('--list-models')) {
    console.log(JSON.stringify({ models: MODELS }, null, 2));
    process.exit(0);
  }

  if (!IAEDU_API_KEY) console.warn('Warning: IAEDU_API_KEY not set.');
  if (!IAEDU_CHANNEL_ID) console.warn('Warning: IAEDU_CHANNEL_ID not set.');
  if (!IAEDU_ENDPOINT && !IAEDU_AGENT_ID) console.warn('Warning: IAEDU_ENDPOINT nor IAEDU_AGENT_ID set.');

  const server = createServer();
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

const thisFile = fileURLToPath(import.meta.url);
if (process.argv[1]) {
  try {
    if (realpathSync(process.argv[1]) === thisFile) {
      main().catch((err) => {
        console.error('Fatal error:', err);
        process.exit(1);
      });
    }
  } catch {
    // process.argv[1] pode não ser um caminho válido (ex: node -e)
  }
}
