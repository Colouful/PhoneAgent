# 04 — Development plan

## Milestones
| Milestone | Goal | Exit criteria |
|---|---|---|
| M0 | Reproduce upstream | Firmware build/flash, iOS install, USB/BLE/AP/AirPlay/H.264/model path evidenced on target hardware |
| M1 | Minimal reliable Agent | One-action observe/plan/validate/execute/verify loop; fail-closed safety; unit/contract tests |
| M2 | Reliability and inputs | Disconnect recovery, 30-minute soak, Chinese input feasibility, landscape feasibility |
| M3 | iPhone V1 candidate | UX, run logs, privacy controls, licensing and private API review, regression tests |
| M4 | Release hardening | Device matrix, installation guide, support notes, release checklist |
| M5 | Android Bridge | Kotlin service/capture/action adapter with same Action contract |

## M0 tasks
PA-001 audit and pin upstream; PA-002 compile/flash; PA-003 USB HID; PA-004 BLE GATT; PA-005 AirPlay/H.264/VideoToolbox; PA-006 iOS build and cloud API.

## M1 tasks
PA-007 Action schema contract; PA-008 Agent state machine; PA-009 exact-action confirmation and Stop; PA-010 Keychain/log redaction/data deletion.

## M2+ tasks
PA-011 30-minute soak/fault injection; PA-012 Chinese IME feasibility; PA-013 landscape coordinate mapping; PA-014 GPIO1 emergency stop; PA-015 Android capture/permission POC; PA-016 Android Action Adapter.

## Working rule
Do not begin large refactoring until M0 acceptance has evidence. Keep hardware outcomes separate from host tests and CI.
