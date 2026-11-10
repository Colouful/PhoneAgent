# 11 — License review (required before redistribution)

PhoneAgent currently contains its own specifications, Action contract, protocol schema and starter interfaces. It does not vendor the upstream ESP32 iPhone Agent source.

The upstream repository README states:
- repository main portions are MIT;
- `hardware/hid_bridge/src/airplay/` contains code ported from UxPlay under GPL-3.0;
- a firmware binary linking that code is therefore distributed subject to GPL-3.0 obligations.

Before copying upstream code or distributing firmware:
1. Inspect root LICENSE and all nested license files at the exact pinned upstream commit.
2. Preserve copyright notices, attribution and NOTICE files.
3. Determine which license obligations apply to firmware binaries and corresponding source.
4. Track Arduino-ESP32, NimBLE-Arduino, TinyUSB, UxPlay-derived code, SDKs and prompt assets separately.
5. Do not mark the whole derivative project MIT without a file-level review.
6. Obtain legal review before commercial or closed-source distribution.

This is an engineering checklist, not legal advice.
