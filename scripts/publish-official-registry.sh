#!/usr/bin/env bash
# Publish server.json to the Official MCP Registry (registry.modelcontextprotocol.io).
#
# Prerequisites (one-time):
#   1. Ed25519 key generated at ~/.sipflow-mcp-publisher.key
#   2. DNS TXT record on sipflow.dev:
#        v=MCPv1; k=ed25519; p=<base64-public-key>
#      Verify with: dig +short TXT sipflow.dev
#
# Re-run this script every time `version` in server.json is bumped.

set -euo pipefail

KEY_PATH="${SIPFLOW_MCP_KEY:-$HOME/.sipflow-mcp-publisher.key}"
PUBLISHER="${MCP_PUBLISHER:-$HOME/.local/bin/mcp-publisher}"

if [ ! -f "$KEY_PATH" ]; then
  echo "ERROR: private key not found at $KEY_PATH" >&2
  echo "Generate one with:" >&2
  echo "  openssl genpkey -algorithm Ed25519 -out $KEY_PATH && chmod 600 $KEY_PATH" >&2
  exit 1
fi

if [ ! -x "$PUBLISHER" ]; then
  echo "ERROR: mcp-publisher not found at $PUBLISHER" >&2
  echo "Install with: curl -sSL https://github.com/modelcontextprotocol/registry/releases/latest/download/mcp-publisher_linux_amd64.tar.gz | tar -xzC ~/.local/bin/ mcp-publisher" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

PRIVATE_KEY_HEX="$(openssl pkey -in "$KEY_PATH" -outform DER | tail -c 32 | xxd -p -c 64)"

echo "==> Validating server.json"
"$PUBLISHER" validate

echo "==> Logging in via DNS (sipflow.dev)"
"$PUBLISHER" login dns --domain sipflow.dev --private-key "$PRIVATE_KEY_HEX"

echo "==> Publishing"
"$PUBLISHER" publish

echo ""
echo "Published. View at: https://registry.modelcontextprotocol.io/v0/servers?search=sipflow"
