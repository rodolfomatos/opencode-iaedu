# VISION

## Problem
The IAEDU platform provides access to language models but has no MCP server,
making it impossible to use IAEDU models as tools inside opencode.

## Solution
A lightweight stdio-based MCP server that wraps the IAEDU API (form-data POST +
SSE streaming) and exposes `complete` and `list_models` MCP tools.

## Value Proposition
One `make install` and an opencode config entry, and users can invoke IAEDU
models from within any opencode session.
