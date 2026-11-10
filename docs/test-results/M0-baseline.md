# M0 Hardware Baseline — Pending Execution

**Status: BLOCKED_HARDWARE** — no physical XIAO ESP32S3 / iPhone test has been performed in this workspace.

## Device and toolchain record
| Field | Value |
|---|---|
| Test date | Pending |
| XIAO board model/revision | Pending — expected standard XIAO ESP32S3, 8MB PSRAM |
| iPhone model / connector | Pending |
| iOS version + build | Pending — minimum target iOS 18+ |
| macOS version | Pending |
| Xcode version | Pending |
| XcodeGen version | Pending |
| Arduino CLI version | Pending |
| ESP32 Arduino Core exact version | Pending — 3.3.x upstream baseline |
| NimBLE-Arduino version | Pending — 2.5.1 upstream baseline |
| Upstream commit SHA | Pending; record git rev-parse HEAD |
| Model provider / model ID | Pending; never record API key |

## Acceptance checklist
| ID | Check | Status | Evidence |
|---|---|---|---|
| M0-01 | USB HID enumerates; AssistiveTouch pointer visible/calibrated | BLOCKED_HARDWARE | |
| M0-02 | BLE pairing and service + five characteristics | BLOCKED_HARDWARE | |
| M0-03 | 100 ping/reply IDs match | BLOCKED_HARDWARE | |
| M0-04 | Status heartbeat updates | BLOCKED_HARDWARE | |
| M0-05 | Join ESP32 SoftAP | BLOCKED_HARDWARE | |
| M0-06 | AirPlay mirror starts | BLOCKED_HARDWARE | |
| M0-07 | H.264 CONFIG/IDR/sequence handling | BLOCKED_HARDWARE | |
| M0-08 | VideoToolbox decodes frames | BLOCKED_HARDWARE | |
| M0-09 | Cloud model request succeeds over cellular | BLOCKED_HARDWARE | |
| M0-10 | Low-risk tap followed by fresh-frame verification | BLOCKED_HARDWARE | |
| M0-11 | Stop/disconnect fail-closed behavior | BLOCKED_HARDWARE | |

## Decision
- Build logs: pending
- Screenshots/videos: pending; redact private information before saving
- Heap/PSRAM/BLE/FPS/drop measurements: pending
- Known issues: pending
- M0 decision: **NOT READY for broad refactoring until required checks have evidence**
