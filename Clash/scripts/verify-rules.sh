#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
rules_dir="$repo_root/Clash/rules"
template="$repo_root/Clash/config/clash-template.yaml"
mihomo_data_dir="${MIHOMO_DATA_DIR:-$repo_root}"

ruby -ryaml -e '
  allowed = %w[DOMAIN DOMAIN-SUFFIX DOMAIN-KEYWORD IP-CIDR IP-CIDR6 IP-ASN PROCESS-NAME]
  files = ARGV
  abort "no Clash rule files found" if files.empty?
  files.each do |file|
    data = YAML.load_file(file)
    payload = data.is_a?(Hash) ? data["payload"] : nil
    abort "#{file}: payload must be a non-empty array" unless payload.is_a?(Array) && !payload.empty?
    payload.each do |rule|
      type = rule.to_s.split(",", 2).first
      abort "#{file}: unsupported rule type #{type}" unless allowed.include?(type)
    end
  end
' "$rules_dir"/*.yaml

ruby -ryaml -e 'YAML.load_file(ARGV.fetch(0)); YAML.load_file(ARGV.fetch(1))' \
  "$template" "$repo_root/Clash/config/local-priority-rules.yaml"

user_agent_count="$(awk -F, '/^USER-AGENT,/{count++} END {print count+0}' "$repo_root"/rules/*.list)"
printf 'Shadowrocket USER-AGENT rules not representable by Mihomo: %s\n' "$user_agent_count"

if [[ -n "${MIHOMO_BIN:-}" ]]; then
  "$MIHOMO_BIN" -t -d "$mihomo_data_dir" -f "$template"
else
  printf 'Set MIHOMO_BIN and optionally MIHOMO_DATA_DIR to run the Mihomo parser check.\n'
fi
