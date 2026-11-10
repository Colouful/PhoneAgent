# 01 — Architecture

## Components
- **iOS Agent App:** setup, CoreBluetooth Central, H.264 reassembly, VideoToolbox decode, screenshots, Planner/Actor/Verifier, Keychain, run history and Stop UI.
- **ESP32-S3:** USB HID Device, NimBLE GATT Peripheral, Wi-Fi SoftAP, AirPlay H.264 receiver/relay, NVS settings, watchdog and HID release on disconnect.
- **Cloud Vision API:** image-capable OpenAI-compatible endpoint called from the phone over cellular data.
- **Future Android Bridge:** Kotlin Companion App using user-authorized MediaProjection and AccessibilityService; it shares the Action contract but not the iOS screen-capture implementation.

## Links
1. USB-C: ESP32 USB HID mouse/keyboard → iPhone.
2. BLE: iPhone Central ↔ ESP32 Peripheral; command, reply, status, video, net.
3. Wi-Fi: iPhone Screen Mirroring → ESP32 SoftAP AirPlay Receiver.
4. Cellular: iPhone → cloud model endpoint.

## Execution state machine
IDLE → OBSERVE → PLAN → VALIDATE → EXECUTE → VERIFY → (OBSERVE | DONE | PAUSED | NEEDS_USER).
Only one action may execute per model call. Verification must use a frame captured after the action. Do not reuse a stale frame.

## Failure behavior
On USB/BLE/AirPlay/model/network loss, timeout, malformed output, invalid coordinates, duplicate action ID, emergency stop or ambiguous screen: cancel queued work, release HID buttons/keys, pause, and require explicit user resumption. Never replay stale actions after reconnect.

## Performance baseline
Start at upstream defaults: portrait 480×1040, max 5 FPS. BLE video throughput is expected to be constrained; prefer fresh IDR frames over an unbounded stale queue.

## Sources
- Upstream: https://github.com/onehumanbeing/esp32-iphone-agent
- BLE protocol: https://github.com/onehumanbeing/esp32-iphone-agent/blob/main/docs/ble-protocol.md
