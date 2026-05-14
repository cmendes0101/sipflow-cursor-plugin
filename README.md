# Sipflow MCP

> SIP/VoIP/telecom grounding for AI agents. Vendor docs across ~40 stacks,
> 60+ RFCs, STIR/SHAKEN, trace and config analysis - every answer cites a
> verbatim `source_url`.

[![smithery badge](https://smithery.ai/badge/sipflow/sipflow)](https://smithery.ai/servers/sipflow/sipflow)

Sipflow is a hosted, read-only [Model Context Protocol](https://modelcontextprotocol.io)
server. It gives your editor or agent ~20 tools that ground SIP/VoIP answers in
a curated corpus instead of training-data recall.

- **Live endpoint:** `https://mcp.sipflow.dev/mcp` (Streamable HTTP)
- **Web app:** <https://www.sipflow.dev>
- **Install page (one-click + all clients):** <https://www.sipflow.dev/tools/mcp>

## Install

### Cursor (one-click)

[Install Sipflow in Cursor](cursor://anysphere.cursor-deeplink/mcp/install?name=sipflow&config=eyJ1cmwiOiJodHRwczovL21jcC5zaXBmbG93LmRldi9tY3AifQ)

Or from the [Cursor Marketplace](https://cursor.com/marketplace). This repo
also ships as a Cursor plugin with a bundled Skill and Rule (see
[What's in this repo](#whats-in-this-repo) below).

### Cursor (manual) - `~/.cursor/mcp.json`

```json
{
  "mcpServers": {
    "sipflow": { "url": "https://mcp.sipflow.dev/mcp" }
  }
}
```

### VS Code - `.vscode/mcp.json` or user `settings.json`

```json
{
  "servers": {
    "sipflow": {
      "type": "http",
      "url": "https://mcp.sipflow.dev/mcp"
    }
  }
}
```

Requires VS Code 1.99+ with the GitHub Copilot extension.

### Claude Desktop - `claude_desktop_config.json`

Claude Desktop is stdio-only, so use the `mcp-remote` shim:

```json
{
  "mcpServers": {
    "sipflow": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.sipflow.dev/mcp"]
    }
  }
}
```

### Claude Code (CLI)

```bash
claude mcp add --transport http sipflow https://mcp.sipflow.dev/mcp
```

### Codex CLI - `~/.codex/config.toml`

```toml
[mcp_servers.sipflow]
url = "https://mcp.sipflow.dev/mcp"
```

### Cline - Settings -> MCP Servers -> Edit JSON

```json
{
  "mcpServers": {
    "sipflow": { "url": "https://mcp.sipflow.dev/mcp" }
  }
}
```

### Continue - `~/.continue/config.yaml`

```yaml
mcpServers:
  - name: sipflow
    transport:
      type: streamable-http
      url: https://mcp.sipflow.dev/mcp
```

### Windsurf - `~/.codeium/windsurf/mcp_config.json`

```json
{
  "mcpServers": {
    "sipflow": {
      "serverUrl": "https://mcp.sipflow.dev/mcp"
    }
  }
}
```

### Goose - `~/.config/goose/config.yaml`

```yaml
extensions:
  sipflow:
    type: http
    uri: https://mcp.sipflow.dev/mcp
    enabled: true
```

### Generic / curl smoke-test

```bash
curl -sS -X POST https://mcp.sipflow.dev/mcp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

## What's in this repo

| File / Folder | Marketplace | Purpose |
| --- | --- | --- |
| `server.json` | [Official MCP Registry](https://registry.modelcontextprotocol.io) | Canonical server descriptor. PulseMCP auto-ingests from here. |
| `smithery.yaml` | [Smithery](https://smithery.ai) | Remote HTTP listing. |
| `.cursor-plugin/plugin.json` | [Cursor Marketplace](https://cursor.com/marketplace) | Plugin manifest. |
| `mcp.json` | Cursor plugin auto-discovery | Points the plugin at the remote endpoint. |
| `skills/sip-debugger/` | Cursor plugin | "When to use Sipflow" playbook surfaced as `/sip-debugger`. |
| `rules/sip-grounding.mdc` | Cursor plugin | Auto-attaches when editing `.pcap`, kamailio/opensips/freeswitch/asterisk configs, dialplans, `.sdp`. |
| `assets/logo.svg` | All | Logo. |

The Cursor-specific files (`.cursor-plugin/`, `mcp.json`, `skills/`, `rules/`)
are silently ignored by non-Cursor marketplaces - they only parse their own
manifest.

## Tool catalog

All tools are read-only. The only outbound IO is `dns_diagnose_sip_target`
(DNS + TLS handshake) and `validate_stir_shaken_identity` (cert fetch).

**Discovery / grounding** - `search_sip_docs`, `lookup_response_code`,
`lookup_sip_header`

**Detection** - `detect_sip_stack`, `detect_sip_vendor_from_config`

**Traces** - `minimize_sip_trace`, `render_sip_ladder`,
`sip_ladder_example`, `lint_sip_request`, `parse_sip_message`,
`diff_sip_messages`

**Config review** - `review_sip_config`, `webrtc_sip_checklist`

**SDP** - `parse_sdp`, `compare_sdp_offer_answer`

**STIR/SHAKEN** - `validate_stir_shaken_identity`,
`stir_attestation_explainer`

**Telecom** - `validate_e164_number`, `troubleshoot_response_code`

**Network** - `dns_diagnose_sip_target` (rate-limited)

**Share hydration** - `fetch_sipflow_share` for `sipflow.dev/share/<token>` URLs

**Resource** - `sipflow://docs/{vendor}/{id}` for a single corpus chunk

## Corpus coverage

- ~40 vendor stacks: Kamailio, OpenSIPS, FreeSWITCH, Asterisk (PJSIP + chan_sip),
  SIP.js, JsSIP, FreePBX, 3CX, OpenSER, Twilio, Cisco, ...
- 60+ RFCs: SIP, SDP, RTP, WebRTC core
- STIR/SHAKEN: RFC 8224/8225/8226/8588/9027/9795
- Branded calling: ATIS-1000074, ATIS-1000094, ATIS-1000084, CTIA BCID

## Local development (Cursor plugin)

Test the plugin locally by symlinking this repo into Cursor's local plugin
folder:

```bash
ln -s "$PWD" ~/.cursor/plugins/local/sipflow
```

Run **Developer: Reload Window** in Cursor. You should see:

- `sipflow` server in **Settings -> Features -> Model Context Protocol**
- `sip-debugger` skill under **Settings -> Rules** (Agent Decides)
- `sip-grounding` rule under **Settings -> Rules**

## Submitting updates

When the MCP server changes, bump `version` in three places to keep
registries in sync:

- `server.json` -> Official MCP Registry
- `.cursor-plugin/plugin.json` -> Cursor Marketplace
- The hosted server's `serverInfo.version`

Then re-run `mcp-publisher publish` for the Official Registry. Cursor,
Smithery, and Glama auto-track the default branch.

## License

MIT - see [LICENSE](LICENSE).
