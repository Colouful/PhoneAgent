# 02 — Hardware

## V1 BOM
| Item | Qty | Requirement |
|---|---:|---|
| Seeed XIAO ESP32S3 standard | 1 | 8MB PSRAM; not Sense, not Plus |
| USB-C data cable | 1 | USB data capable; short cable preferred |
| iPhone | 1 | iOS 18+; USB-C model preferred |
| Lightning USB Camera Adapter | optional | Only for Lightning iPhones |
| Momentary normally-open button | optional | GPIO1/D0 emergency-stop prototype |
| Enclosure / status LED | optional | Productization after functional proof |

## Native interface
Do not add an external USB host controller. XIAO's native USB-C is used as a USB Device for HID. BLE and Wi-Fi are radio links; no soldering is required for the baseline setup.

## Emergency stop prototype
- GPIO: D0 / GPIO1.
- Button: normally open between GPIO1 and GND.
- Firmware: INPUT_PULLUP; pressed = LOW.
- Add hardware/software debounce and highest-priority event handling.
- On press: inhibit new HID reports, release all mouse/keyboard buttons, clear command queues, pause Agent. Releasing the button must not auto-resume.
- The example in hardware/emergency-stop-example.cpp is illustrative and must be integrated/tested on the actual board before use.

## Power and compatibility notes
The upstream setup reports that the iPhone powers the board over USB-C. Confirm current draw, phone USB host behavior, cable and adapter compatibility on the target iPhone. Lightning adapters vary; do not claim compatibility without tests.

## Official docs
https://wiki.seeedstudio.com/xiao_esp32s3_getting_started/
