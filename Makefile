.PHONY: setup test configure check install-deps install mcp-add clean help

all: setup

setup:
	npm install

test:
	npm test

configure:
	@echo "============================================"
	@echo "  opencode-iaedu — Interactive Setup"
	@echo "============================================"
	@echo ""
	@echo "Go to iaedu.pt, open your agent, and copy the"
	@echo "values it shows. Paste them below."
	@echo ""
	@read -p "IAEDU Agent ID (paste from iaedu.pt): " AGENT_ID; \
	while [ -z "$$AGENT_ID" ]; do \
		echo "  Agent ID cannot be empty."; \
		read -p "IAEDU Agent ID: " AGENT_ID; \
	done; \
	read -p "IAEDU API Key (paste from iaedu.pt): " API_KEY; \
	while [ -z "$$API_KEY" ]; do \
		echo "  API Key cannot be empty."; \
		read -p "IAEDU API Key: " API_KEY; \
	done; \
	read -p "IAEDU Channel ID (paste from iaedu.pt): " CHANNEL_ID; \
	while [ -z "$$CHANNEL_ID" ]; do \
		echo "  Channel ID cannot be empty."; \
		read -p "IAEDU Channel ID: " CHANNEL_ID; \
	done; \
	mkdir -p ~/.config/iaedu; \
	echo "# iaedu global config — used by opencode-iaedu from any directory" > ~/.config/iaedu/env; \
	echo "IAEDU_AGENT_ID=$$AGENT_ID" >> ~/.config/iaedu/env; \
	echo "IAEDU_CHANNEL_ID=$$CHANNEL_ID" >> ~/.config/iaedu/env; \
	echo "IAEDU_API_KEY=$$API_KEY" >> ~/.config/iaedu/env; \
	chmod 600 ~/.config/iaedu/env; \
	echo ""; \
	echo "  [OK] Config written to ~/.config/iaedu/env"

check:
	@echo "Checking opencode-iaedu configuration..."
	@if [ -f ~/.config/iaedu/env ]; then \
		echo "  [OK] Global config found at ~/.config/iaedu/env"; \
		. ~/.config/iaedu/env && \
		if [ -n "$$IAEDU_API_KEY" ]; then echo "  [OK] IAEDU_API_KEY set"; else echo "  [WARN] IAEDU_API_KEY not set"; fi && \
		if [ -n "$$IAEDU_CHANNEL_ID" ]; then echo "  [OK] IAEDU_CHANNEL_ID set"; else echo "  [WARN] IAEDU_CHANNEL_ID not set"; fi && \
		if [ -n "$$IAEDU_AGENT_ID" ]; then echo "  [OK] IAEDU_AGENT_ID set"; else echo "  [WARN] IAEDU_AGENT_ID not set"; fi; \
	else \
		echo "  [WARN] No global config found at ~/.config/iaedu/env"; \
		echo "  Run 'make configure' to set up credentials"; \
	fi
	@opencode-iaedu --list-models > /dev/null 2>&1 && echo "  [OK] opencode-iaedu is executable" || echo "  [WARN] opencode-iaedu not found on PATH (run 'make install-deps')"

install-deps:
	npm install -g .

mcp-add:
	@if ! opencode mcp list 2>&1 | grep -q iaedu; then \
		echo "Registering iaedu MCP server with opencode..."; \
		cat ~/.config/iaedu/env 2>/dev/null | while read line; do \
			case "$$line" in IAEDU_*) eval "export $$line";; esac; \
		done; \
		node -e "
			const fs = require('fs');
			const path = require('path');
			const configPath = path.join(process.env.HOME, '.config', 'opencode', 'opencode.jsonc');
			let config = {};
			try {
				const content = fs.readFileSync(configPath, 'utf-8');
				config = JSON.parse(content.replace(/\/\/.*$/gm, '').replace(/,\s*([}\]])/g, '\$1'));
			} catch (e) {}
			if (!config.mcp) config.mcp = {};
			if (!config.mcp.iaedu) {
				config.mcp.iaedu = { type: 'local', command: ['opencode-iaedu'] };
				fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
				console.log('[OK] iaedu MCP server added to opencode.jsonc');
			} else {
				console.log('[OK] iaedu MCP server already configured');
			}
		"; \
	else \
		echo "[OK] iaedu MCP server already registered with opencode"; \
	fi

install:
	./install.sh

clean:
	rm -rf node_modules package-lock.json

help:
	@echo "opencode-iaedu Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  setup        npm install"
	@echo "  configure    interactive IAEDU credentials setup"
	@echo "  check        verify configuration"
	@echo "  test         run test suite"
	@echo "  install-deps install opencode-iaedu globally"
	@echo "  mcp-add      register with opencode as MCP server"
	@echo "  install      run install.sh (interactive full install)"
	@echo "  clean        remove node_modules"
