# 00 — Product scope

## Product
PhoneAgent is a phone-resident AI agent that operates a real iPhone through a compact ESP32-S3 accessory. Day-to-day tasks run on the iPhone app; no external computer is required after flashing/installing. The app uses iPhone cellular data for a cloud vision model.

## V1 target
- Hardware: Seeed XIAO ESP32S3 standard board, 8MB PSRAM.
- Phone: iPhone, iOS 18+.
- Inputs: USB-C HID mouse/keyboard plus BLE GATT command/status/video.
- Screen capture: iPhone Screen Mirroring/AirPlay to ESP32 SoftAP receiver.
- Agent: observe → plan → validate → execute → verify, one action per model turn.
- Model: configurable cloud vision API, API key stored in Keychain.

## V1 acceptance
Complete simple, low-risk tasks in accessible, unlocked apps; verify each action from a new screen frame; pause safely on uncertainty or transport loss; allow user Stop and explicit approval for high-impact actions.

## Not in scope
- Bypassing iOS security, passcodes, MFA, permissions, DRM or payment confirmation.
- Guaranteed control of every system screen or every third-party app.
- Unattended payment, transfer, purchase, message send, delete, publish or permission grant.
- App Store acceptance while the upstream private iOS API remains.
- Fully working Chinese IME and all landscape layouts before dedicated device validation.
- Android in V1; Android uses a separate Bridge in a later milestone.

## Runtime topology
The phone connects to ESP32 over USB-C (HID + board power), BLE (commands/status/H.264 chunks), and Wi-Fi AirPlay (screen mirror). Because the ESP32 SoftAP does not provide Internet in the baseline design, cloud model calls use iPhone cellular data.
