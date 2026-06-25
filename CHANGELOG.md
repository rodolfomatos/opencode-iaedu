# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-06-25
### Added
- Initial release of opencode-iaedu as an MCP server
- Provides `complete` and `list_models` MCP tools for IAEDU models
- Implementation of IAEDU API client based on llm-iaedu (form-data POST + SSE streaming)
- Environment variable and .env file configuration support
- MCP SDK integration with stdio transport for opencode compatibility
- Full test suite using InMemoryTransport
- Shebang entry point for direct execution
- Usage documentation for opencode.jsonc MCP configuration
