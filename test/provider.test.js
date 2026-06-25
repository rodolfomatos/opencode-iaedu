import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';
import { fileURLToPath } from 'url';

describe('opencode-iaedu MCP server', () => {
  let client;
  let session;

  beforeAll(async () => {
    process.env.IAEDU_API_KEY = 'test-key';
    process.env.IAEDU_CHANNEL_ID = 'test-channel';
    process.env.IAEDU_AGENT_ID = 'test-agent';

    const mod = await import('../index.js');
    const server = mod.createServer();

    const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
    client = new Client({ name: 'test-client', version: '1.0.0' });
    await Promise.all([
      client.connect(clientTransport),
      server.connect(serverTransport),
    ]);
  });

  afterAll(async () => {
    await client.close();
  });

  it('should expose tools via MCP', async () => {
    const result = await client.listTools();
    const toolNames = result.tools.map(t => t.name);
    expect(toolNames).toContain('complete');
    expect(toolNames).toContain('list_models');
  });

  it('should list models via list_models tool', async () => {
    const result = await client.callTool({ name: 'list_models', arguments: {} });
    const content = result.content[0];
    expect(content.type).toBe('text');
    const models = JSON.parse(content.text);
    expect(Array.isArray(models)).toBe(true);
    expect(models.length).toBeGreaterThan(0);
    expect(models[0].id).toBe('iaedu/default');
  });

  it('should describe required params for complete tool', async () => {
    const result = await client.listTools();
    const complete = result.tools.find(t => t.name === 'complete');
    expect(complete.inputSchema).toBeDefined();
    expect(complete.inputSchema.properties.prompt).toBeDefined();
  });

  it('should export MODELS', async () => {
    const mod = await import('../index.js');
    expect(Array.isArray(mod.MODELS)).toBe(true);
    expect(mod.MODELS[0].id).toBe('iaedu/default');
  });

  it('should export callIAEDU function', async () => {
    const mod = await import('../index.js');
    expect(typeof mod.callIAEDU).toBe('function');
  });
});
