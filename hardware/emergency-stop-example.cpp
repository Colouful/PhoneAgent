// Illustrative XIAO ESP32S3 emergency-stop input.
// D0 is GPIO1 on the standard XIAO ESP32S3 pin map.
// Integrate with a highest-priority task/event loop; do not block inside an ISR.
#include <Arduino.h>

constexpr int ESTOP_PIN = 1; // XIAO D0 / GPIO1
constexpr uint32_t DEBOUNCE_MS = 30;

void setupEmergencyStopInput() {
  pinMode(ESTOP_PIN, INPUT_PULLUP);
}

// Call from a fast polling task. The caller must latch the stopped state,
// cancel queued actions, release all HID keys/buttons, and require user restart.
bool emergencyStopRawPressed() {
  return digitalRead(ESTOP_PIN) == LOW;
}

bool emergencyStopDebounced() {
  static bool stable = false;
  static bool lastRaw = false;
  static uint32_t changedAt = 0;
  const bool raw = emergencyStopRawPressed();
  const uint32_t now = millis();
  if (raw != lastRaw) {
    lastRaw = raw;
    changedAt = now;
  }
  if ((now - changedAt) >= DEBOUNCE_MS) stable = raw;
  return stable;
}
