# 05 — Test plan

## Host checks
- `python3 -m json.tool schemas/phone-action.schema.json`
- BLE YAML structural/contract check.
- `cd agent-core && swift test`.
- Shell syntax: `bash -n scripts/check-starter-kit.sh scripts/publish-to-github.sh`.
- CI on pull request for Swift and schema checks.

## Hardware checks (M0)
1. USB HID enumeration and AssistiveTouch pointer.
2. BLE pairing; five characteristics discovered.
3. 100 ping/reply request IDs matched.
4. Status heartbeat observed.
5. Join ESP32 SoftAP.
6. Start AirPlay screen mirror.
7. Receive CONFIG/IDR and valid H.264 Annex-B.
8. VideoToolbox renders frames; test sequence gap and IDR recovery.
9. Cloud model call succeeds over cellular data.
10. Low-risk tap followed by fresh frame verification.
11. Stop/disconnect releases HID and pauses without replay.

## Performance targets (initial targets, not claims)
- Portrait stream: 480×1040, up to 5 FPS.
- BLE throughput target: 300–500 kbps when RF conditions allow.
- Heartbeat: about 1 Hz.
- Soak: 30 minutes without unrecoverable failure.
Record actual values and conditions.

## Agent safety tests
- stale screen rejected
- malformed JSON rejected
- coordinates outside 0...1 rejected
- unsupported action rejected
- duplicate action ID rejected
- exact high-risk action confirmation accepted; modified action confirmation rejected
- local policy can require confirmation even if model says low risk
- emergency stop blocks all execution
- transport loss cancels pending queue and releases HID
- model/API timeout pauses safely

## Reporting
Each test must be PASS / FAIL / BLOCKED_HARDWARE with evidence path, device/tool versions and repro steps. A passing host test is not hardware validation.
