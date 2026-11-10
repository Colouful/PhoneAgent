# 03 — BLE GATT protocol

**Compatibility source:** https://github.com/onehumanbeing/esp32-iphone-agent/blob/main/docs/ble-protocol.md

## Roles and Service
- ESP32: BLE Peripheral, advertised as `ESP32 Agent XXXX`.
- iOS app: BLE Central.
- Service: `6e400001-a9e8-4b1b-9c39-6d6f8a3c0000`.

| Characteristic | UUID suffix | Properties | Purpose |
|---|---|---|---|
| cmd | 0001 | Write, Write Without Response | command line |
| reply | 0002 | Notify | request result |
| status | 0003 | Notify, Read | heartbeat JSON |
| video | 0004 | Notify | H.264 chunks |
| net | 0005 | Read, Write (encrypted) | SoftAP/station config |

Append suffix to the service UUID prefix for each full characteristic UUID.

## Command framing
UTF-8 line: `<decimal_request_id> <command>`. The reply echoes the request ID, for example `101 ping` → `101 ok`; failures: `101 err <reason>`.

Baseline commands:
- `ping`, `home`, `move DX DY`, `press`, `release`, `click`, `scroll A B`, `type TEXT`, `key COMBO`
- `stream on|off`, `snap`, `res W H`, `fps N`, `bench KB`, `unpair`, `coex [bt|balance|wifi]`

## Video packet
Each notify is `[seq u16 LE][flags u8][payload]`. Flags: bit0 START AU, bit1 END AU, bit2 IDR, bit3 CONFIG (SPS/PPS), bit4 BENCH, bit5 SNAP. Payload is Annex-B H.264. START packet prepends a u32 LE board timestamp before Annex-B bytes. Respect negotiated MTU and chunk limits.

## Status
Heartbeat normally every second. Fields include uptime/reset reason, heap/PSRAM, USB, Wi-Fi/AP/stream, resolution/FPS/bitrate, BLE MTU/PHY/kbps/drop counts. Reduced JSON may be sent for small MTU; status READ can return the full object.

## Security and recovery
- `net` requires an encrypted BLE link; bonding is expected. Baseline Just Works does not provide MITM identity protection.
- On sequence gaps, discard incomplete access units and wait for next CONFIG/IDR before decode.
- On BLE disconnect, release every HID key/button, pause Agent and clear queued actions.
- Replies/status have priority over video; never build an unbounded video queue.

Keep this document synchronized with protocols/ble-gatt.yaml and upstream protocol changes.
