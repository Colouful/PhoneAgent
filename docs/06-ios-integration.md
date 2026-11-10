# 06 — iOS integration

## Baseline
Reuse upstream SwiftUI app and its CoreBluetooth, H.264 and VideoToolbox integration:
https://github.com/onehumanbeing/esp32-iphone-agent/tree/main/ios

Upstream project deployment target: iOS 18.0. The app setup covers USB board connection, BLE pairing, joining the ESP32 hotspot, Control Center Screen Mirroring, AssistiveTouch pointer setup, and model endpoint/key configuration.

## Integration boundaries
- BLE Central: reconnect, characteristic discovery/subscription, request ID correlation.
- Video: chunk sequence validation, CONFIG/IDR recovery, VideoToolbox decoder.
- Agent: one action per model call; new frame after execution.
- Security: Keychain API key; redact logs.
- Storage: minimal, user-deletable task traces/screenshots.
- UI: visible running state and reachable Stop.

## Known upstream limitations to test
- Some protected screens are not mirrored; locking stops mirroring.
- Portrait coordinate assumptions; landscape not supported in baseline.
- ASCII-only text input; non-ASCII/Chinese needs a separate IME experiment.
- The current upstream app uses private iOS API `suspend`; personal self-build does not imply App Store compliance.
- Background execution depends on iOS lifecycle and capabilities; verify on target OS.

Do not add private APIs. Before any distribution, review and replace private API usage with supported behavior or explicitly keep the build out of App Store distribution.
