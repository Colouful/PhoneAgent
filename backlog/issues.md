# PhoneAgent — GitHub Issue Backlog

Repository: https://github.com/Colouful/PhoneAgent
These 16 scoped tasks can be created as GitHub Issues after checking for duplicates.

## Sprint 0 / M0 — upstream baseline
### PA-001 — Pin upstream and audit
**P0.** Record upstream URL, commit SHA, LICENSE/NOTICE, board, iPhone/iOS build, exact Arduino Core, NimBLE, Xcode/XcodeGen; preserve all local changes.

### PA-002 — Firmware build and flash
**P0.** Use upstream hardware/flash.sh (includes nimble_cfg.h); preserve logs and Flash/RAM usage; confirm serial port before flashing.

### PA-003 — USB HID test
**P0.** iPhone detects mouse; AssistiveTouch pointer visible; repeat move/click/release 100 times without stuck key/button.

### PA-004 — BLE GATT test
**P0.** Discover service and five characteristics; 100 ping/reply request IDs match; status heartbeat updates.

### PA-005 — AirPlay/H.264/VideoToolbox
**P0.** Receive CONFIG/IDR and Annex-B data; decode frames; test sequence gap and recovery; record MTU/FPS/kbps/drop.

### PA-006 — iOS build and cloud model
**P0.** Build/sign/install on target iPhone; confirm SoftAP/cellular route; API key in Keychain.

## Sprint 1 / M1 — safe Agent loop
### PA-007 — Action Contract / schema tests
**P0.** Swift Codable matches JSON Schema; required action params and 0…1 coordinates validated; unknown action rejected.

### PA-008 — One-action Agent loop
**P0.** Observe → Plan → Validate → Execute → Verify; one action per model call; capture a fresh frame after execution.

### PA-009 — Exact-action confirmation and Stop
**P0.** High-impact confirmation binds exact immutable payload; Stop/disconnect cancels queue, releases HID, never replays stale action.

### PA-010 — Keychain, redaction and data deletion
**P0.** API key absent from logs/crash reports/plaintext config; run screenshots are minimal and user-deletable.

## Sprint 2 / M2 — reliability
### PA-011 — 30-minute soak and fault injection
**P1.** Record heap/PSRAM/BLE drops/AirPlay FPS; link loss, lock, timeout pause without replay.

### PA-012 — Chinese input feasibility
**P1.** Document keyboard layout/IME/candidate behavior and a tested non-ASCII input path; otherwise disclose limitation.

### PA-013 — Landscape and pointer calibration
**P2.** Detect orientation and map coordinates; validate real-device task set or retain portrait-only boundary.

### PA-014 — GPIO1 emergency stop
**P2.** D0/GPIO1 normally-open button immediately releases HID and cancels queue; release does not auto-resume.

## Sprint 3 / M5 — Android Bridge
### PA-015 — Android permission/capture POC
**P2.** Kotlin app uses user-authorized MediaProjection and AccessibilityService to display screenshot and UI tree.

### PA-016 — Android Action Adapter
**P2.** Reuse PhoneAction contract tests; dispatchGesture for touch; BLE/USB path validated on real device.
