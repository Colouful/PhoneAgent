# AGENTS.md — PhoneAgent repository instructions

## Project goal
PhoneAgent is an iPhone-first AI phone-control project. The daily runtime target is an iPhone app plus an ESP32-S3 board; a Mac is only needed for initial firmware flashing, Xcode build/signing, and development. Android is a later independent bridge.

## Read first
1. README.md
2. PROMPT_FOR_OTHER_AI.zh-CN.md
3. docs/00-product-scope.md through docs/13-architecture-decisions.md
4. docs/11-license-review.md and docs/NOTICE-AND-LICENSE.md before copying or redistributing upstream code
5. backlog/issues.md

## Non-negotiable implementation order
- M0: reproduce and record the upstream baseline on real hardware before refactoring.
- M1: build the smallest safe observe → plan → validate → execute → verify loop.
- Later: Chinese input, landscape, stability work, then Android bridge.
- Reuse the upstream AirPlay receiver, H.264 BLE transport, NimBLE buffer tuning, and USB HID until a measured reason justifies a change.

## Safety requirements
- Fail closed on stale/missing screen frames, lost USB/BLE/AirPlay, model timeout, malformed output, invalid coordinates, duplicate action IDs, or emergency stop.
- On link loss or Stop: cancel queued work, release all HID keys/buttons, pause the task, and never replay stale actions automatically.
- High-impact actions (payment, purchase, transfer, message send, delete, publish, account/security change, permission grant) require user confirmation bound to the exact immutable action payload and visible consequence.
- Never bypass passwords, MFA, OS permissions, payment protections, or DRM.
- Store API keys in Keychain; never commit credentials, provisioning material, device Wi-Fi passwords, logs containing secrets, screenshots, or personal data.

## Engineering requirements
- Keep the platform-neutral PhoneAction contract aligned with schemas/phone-action.schema.json and protocols/ble-gatt.yaml; add contract tests for changes.
- Run `cd agent-core && swift test` and `./scripts/check-starter-kit.sh` for relevant changes.
- Use the upstream hardware/flash.sh path for firmware builds; it applies required NimBLE configuration.
- Hardware, Xcode signing, AirPlay, model API, and simulator tests must be reported separately. Never claim unrun tests.
- Record upstream commit SHA and exact toolchain/device versions in docs/test-results/M0-baseline.md.
- Use feature branches and PRs. Never force-push or rewrite shared history. Keep commits small and reversible.

## Repository state
Canonical remote: https://github.com/Colouful/PhoneAgent
Default branch: main
