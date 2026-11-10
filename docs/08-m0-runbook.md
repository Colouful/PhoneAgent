# 08 — M0 practical runbook

## Required equipment
Mac + Xcode, Git, XcodeGen, Arduino CLI; XIAO ESP32S3 standard 8MB PSRAM; iPhone iOS 18+; USB data cable; cellular connection; cloud vision API key (entered only into app Keychain).

## Record environment
Update docs/test-results/M0-baseline.md with board revision, iPhone model, iOS build, cable/adapter, macOS, Xcode, XcodeGen, Arduino CLI, exact ESP32 Core version, NimBLE version, upstream SHA, firmware/app build and model provider. Never write API keys.

## Pin upstream
```bash
git clone https://github.com/onehumanbeing/esp32-iphone-agent.git
cd esp32-iphone-agent
git rev-parse HEAD
git status --short
```
Record SHA; inspect README, BLE protocol, LICENSE/NOTICE, hardware/flash.sh and nimble_cfg.h.

## Install toolchain
```bash
arduino-cli version
arduino-cli core update-index
arduino-cli core search esp32
```
Install an exact compatible ESP32 Arduino Core 3.3.x patch and NimBLE-Arduino 2.5.1. Record:
```bash
arduino-cli core install esp32:esp32@<confirmed-version>
arduino-cli lib install "NimBLE-Arduino@2.5.1"
arduino-cli core list
arduino-cli lib list
```
Do not paste the angle-bracket placeholder literally.

## Build and flash
```bash
hardware/flash.sh --build-only
hardware/flash.sh
```
First check the pinned commit supports --build-only. Save build log and memory usage. Confirm the serial port before flashing; flash only the target XIAO. Use upstream script so nimble_cfg.h buffer overrides are included.

## Build iOS
```bash
cd ios
xcodegen
cp Config/Local.xcconfig.example Config/Local.xcconfig
open IPhoneAgent.xcodeproj
```
Set DEVELOPMENT_TEAM / IA_BUNDLE_ID locally. Do not commit Local.xcconfig. Select a real iPhone and record signing method.

## Device setup
1. Connect USB-C iPhone and ESP32.
2. Start app; pair BLE.
3. Read net characteristic for SoftAP SSID/password.
4. Join ESP32 hotspot.
5. Control Center → Screen Mirroring → ESP32 Agent.
6. User manually enables AssistiveTouch.
7. App calibrates pointer.
8. Configure image-input endpoint/model/key.
9. Verify model requests use cellular; do not assume SoftAP has Internet.

## M0 test checklist
See docs/test-results/M0-baseline.md. Every item needs reproducible evidence. Missing evidence remains BLOCKED_HARDWARE; do not start broad refactoring until M0 passes.
