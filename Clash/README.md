# Clash smart-routing rules

This directory publishes credential-free Mihomo-compatible rule sets derived
from the Clash format maintained by blackmatrix7/ios_rule_script.

`config/local-priority-rules.yaml` is local-only. It always runs before remote
rule providers and is never changed by the sync workflow. It protects LAN and
Tailscale traffic from proxy routing.

`config/clash-template.yaml` is parseable without proxy credentials. Add real
nodes to the `PROXY` group before using it as a standalone configuration.

`config/mac-overlay.example.yaml` documents the intended mapping for the Mac:
OpenAI uses `ChatGPT`, Gemini uses `Gemini`, Google uses `谷歌服务`, and general
traffic uses `节点选择`. It is not applied automatically.

The workflow runs daily at 02:31 UTC (10:31 Asia/Shanghai) and writes only
`Clash/rules/`. Mihomo checks the published raw rule providers every six hours.

The upstream Shadowrocket lists include USER-AGENT rules. Mihomo has no
equivalent User-Agent rule type for transparent/TUN traffic, so those rules are
not represented in the official Clash YAML and are reported by verification.

Run `Clash/scripts/verify-rules.sh` after setting `MIHOMO_BIN` to a Mihomo
binary. Set `MIHOMO_DATA_DIR` to an existing Mihomo data directory when the
template uses GeoIP rules. This verifies rule YAML, payload presence, supported
types, and the template parser. It cannot test proxy connectivity without real
nodes.

Rollback a published rule update with `git revert <sync-commit>`. Before any
Mac integration, back up the active Clash Verge enhancement files and restore
them before reloading the core if a regression occurs.
