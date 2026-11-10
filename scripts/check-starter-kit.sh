#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
python3 -m json.tool "$ROOT/schemas/phone-action.schema.json" >/dev/null
python3 -c "from pathlib import Path; s=Path('$ROOT/protocols/ble-gatt.yaml').read_text(); keys=['service:','uuid: 6e400001-a9e8-4b1b-9c39-6d6f8a3c0000','name: cmd','name: reply','name: status','name: video','name: net']; missing=[k for k in keys if k not in s]; assert not missing, missing; print('BLE protocol basic check: OK')"
if command -v swift >/dev/null 2>&1; then (cd "$ROOT/agent-core" && swift test); else echo "SKIP Swift tests: Swift not installed"; fi
echo "Starter kit checks complete; physical hardware not tested."
