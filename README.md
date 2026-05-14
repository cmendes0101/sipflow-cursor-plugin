# Sipflow Cursor Plugin

SIP/VoIP/telecom grounding for your editor. One-click installs the hosted
[Sipflow MCP server](https://mcp.sipflow.dev/mcp) plus a Skill and a Rule that
nudge the agent to use Sipflow's tools whenever you're working on SIP material.

## One-click install in Cursor

[Install Sipflow in Cursor](cursor://anysphere.cursor-deeplink/mcp/install?name=sipflow&config=eyJ1cmwiOiJodHRwczovL21jcC5zaXBmbG93LmRldi9tY3AifQ)

Or install from the [Cursor Marketplace](https://cursor.com/marketplace).

## What's inside

- **MCP server** (`mcp.json`) - remote Streamable HTTP server at
  `https://mcp.sipflow.dev/mcp`. ~20 read-only tools across:
  - Discovery / grounding: `search_sip_docs`, `lookup_response_code`,
    `lookup_sip_header`
  - Detection: `detect_sip_stack`, `detect_sip_vendor_from_config`
  - Trace tools: `minimize_sip_trace`, `render_sip_ladder`,
    `sip_ladder_example`, `lint_sip_request`, `parse_sip_message`,
    `diff_sip_messages`
  - Config review: `review_sip_config`, `webrtc_sip_checklist`
  - SDP: `parse_sdp`, `compare_sdp_offer_answer`
  - STIR/SHAKEN: `validate_stir_shaken_identity`,
    `stir_attestation_explainer`
  - Telecom: `validate_e164_number`, `troubleshoot_response_code`
  - DNS + TLS cert (rate-limited): `dns_diagnose_sip_target`
  - Share hydration: `fetch_sipflow_share`
  - Resource: `sipflow://docs/{vendor}/{id}`

- **Skill** (`skills/sip-debugger/`) - "When to use Sipflow" playbook that
  surfaces in `/sip-debugger` and in the agent's skill catalog.

- **Rule** (`rules/sip-grounding.mdc`) - auto-attaches when you edit SIP traces,
  Kamailio/OpenSIPS/FreeSWITCH/Asterisk configs, dialplans, or SDP files, so
  the agent prefers grounded answers over training-data recall.

## How it works

The plugin is just a thin shim: all tools and instructions are served from the
remote MCP endpoint, so updates ship without re-publishing the plugin. The
server is read-only (no writes); the only outbound IO is
`dns_diagnose_sip_target` (DNS + TLS handshake) and
`validate_stir_shaken_identity` (cert fetch).

## Smoke-test the endpoint

```bash
curl -sS -X POST https://mcp.sipflow.dev/mcp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

## Development

Test locally by symlinking this repo into Cursor's local plugin folder:

```bash
ln -s "$PWD" ~/.cursor/plugins/local/sipflow
```

Then **Developer: Reload Window** in Cursor. The `sipflow` MCP server should
appear in **Settings -> Features -> Model Context Protocol**, the skill in
**Settings -> Rules** (Agent Decides), and the rule in **Settings -> Rules**.

## Links

- App: <https://sipflow.dev>
- MCP install page: <https://sipflow.dev/tools/mcp>
- MCP endpoint: <https://mcp.sipflow.dev/mcp>

## License

MIT - see [LICENSE](LICENSE).
