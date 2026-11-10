# Security Policy

Report suspected vulnerabilities privately to the repository owner rather than posting secrets, exploit details, screenshots or personal data in public issues.

Security-sensitive areas include:
- unintended HID actions and stale command replay
- bypassed or incorrectly bound user confirmations
- BLE command spoofing, pairing and bonding assumptions
- API key leakage and sensitive screen data
- unsafe recovery after USB/BLE/AirPlay disconnects
- emergency-stop and watchdog behavior

Required safeguards:
- API keys in iOS Keychain, never in source or logs
- minimal, user-deletable screen/task data
- reject stale frames and malformed/out-of-range actions
- pause on link loss; release HID; clear queued actions
- exact-action confirmation for high-impact actions
- test only devices/accounts for which the tester is authorized
