# 09 — Roadmap and estimates

These are planning estimates, not delivery commitments. Actual work depends on hardware, signing, iOS lifecycle behavior and upstream compatibility.

| Phase | Scope | Planning estimate |
|---|---|---|
| M0 | Upstream build, flash, iOS install, link verification | 2–5 focused engineering days plus device troubleshooting |
| M1 | Agent loop, Action contract, safe dispatch, tests | 4–8 engineering days |
| M2 | soak/fault injection, pointer and input improvements | 4–10 engineering days |
| M3 | UX polish, privacy, license/private API review | 5–10 engineering days |
| M5 | Android Kotlin Bridge POC and adapter | 1–3 weeks for initial POC; broader compatibility later |

## Suggested sequence
1. Make a reproducible iPhone/ESP32 lab baseline.
2. Build one low-risk tap loop.
3. Add robust safety/recovery before expanding action types.
4. Test Chinese input and landscape independently.
5. Stabilize iPhone V1 before Android work.
