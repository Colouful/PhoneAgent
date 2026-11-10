# 10 — Risk register

| Risk | Impact | Mitigation / gate |
|---|---|---|
| Wi-Fi/BLE radio coexistence | H.264 drops and latency | tune coex; measure MTU/FPS/drop; bound queues |
| Relative HID pointer drift | Wrong tap target | pointer calibration, re-home and visual correction |
| iOS background/suspend behavior | Agent pauses or app may be rejected | use visible supported lifecycle; remove private API before distribution |
| Protected screen or lock | No visual feedback | pause and request user interaction |
| Chinese IME | non-ASCII text incorrect | explicit POC; do not claim support before test |
| Landscape/rotation | coordinate mapping wrong | detect orientation, remap and verify on device |
| BLE security | Just Works lacks MITM | assess threat model; never treat pairing as authenticated identity |
| Cloud API outage | Agent cannot plan | timeout, bounded retry then pause |
| Sensitive screen data | privacy exposure | minimize capture, Keychain, local delete, redacted logs |
| GPL dependency in AirPlay code | distribution obligations | license review before redistributing firmware/source |

Every risk must have a test or acceptance gate; do not silently convert a risk into a support claim.
