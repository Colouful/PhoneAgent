# 07 — Android roadmap

Android is a later milestone and must use a platform-specific Bridge, not the iOS AirPlay path.

## Proposed stack
- Kotlin + Jetpack Compose.
- AccessibilityService for UI tree and gestures.
- User-authorized MediaProjection for screen capture.
- BluetoothGatt for ESP32 BLE, optional USB HID input.
- Same PhoneAction schema, Planner, Validator, task/log concepts.
- Android-specific ScreenProvider and ActionAdapter.

## Permission boundaries
The user must explicitly enable Accessibility Service and grant screen-capture permission. Do not silently enable services, bypass permission dialogs, root the device, or circumvent app/system security.

## POC order
1. Display a user-authorized screenshot.
2. Inspect Accessibility Tree.
3. Execute one low-risk tap via dispatchGesture().
4. Execute an ESP32 BLE action using the same contract.
5. Verify with a new frame.
6. Only then connect to cloud vision model.

## Compatibility
Android API versions, OEM restrictions, foreground service rules and background capture lifecycle need real-device testing. Do not claim all apps are accessible.
