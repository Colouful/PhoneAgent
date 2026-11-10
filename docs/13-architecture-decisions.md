# 13 — Architecture decisions

## ADR-001: Phone runs the Agent
**Decision:** Planner/Actor/Verifier run in the iPhone app; ESP32 is a transport/input accessory.
**Reason:** phone already has compute, screen, cellular data and app lifecycle; no permanent external computer needed.

## ADR-002: USB-C + BLE + Wi-Fi
**Decision:** USB HID for mouse/keyboard and power, BLE GATT for commands/status/H.264, Wi-Fi AirPlay for screen mirroring.
**Reason:** this matches the upstream hardware-proven topology.

## ADR-003: Reuse upstream first
**Decision:** pin and reproduce upstream before refactoring.
**Reason:** AirPlay receiver, video relay and BLE buffers are complex and hardware-sensitive.

## ADR-004: Platform-specific Bridge
**Decision:** Android will have independent capture/action adapters but share the platform-neutral Action schema and safety policy.
**Reason:** iOS and Android expose different screen and automation permissions.

## ADR-005: One action per model turn
**Decision:** after every action, capture a new frame and verify.
**Reason:** reduces error accumulation and prevents a stale plan from blindly continuing.

## ADR-006: Fail closed
**Decision:** stale frame, link loss, malformed action, timeout or stop pauses the task and clears queues.
**Reason:** incorrect phone actions can have real-world side effects.
