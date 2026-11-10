# M0 Hardware Baseline — PA-001 Audit Done, Hardware Blocked

**Status: BLOCKED_HARDWARE** — 上游审计与版本固定已完成（PA-001），固件编译进行中；没有做过任何一次物理 XIAO ESP32S3 / iPhone 真机测试。

审计详情：`docs/test-results/PA-001-upstream-audit.md`（Issue #1）。

## Device and toolchain record
| Field | Value |
|---|---|
| Test date | 2026-11-10（审计）；真机测试日期待定 |
| XIAO board model/revision | 待到货确认 — 固定为标准 XIAO ESP32S3，8MB PSRAM（非 Sense/Plus）；预计 2026-11-12 左右到货 |
| iPhone model / connector | iPhone 16 Pro Max，USB-C（用户 2026-11-10 确认） |
| iOS version + build | iOS 27.3（用户 2026-11-10 确认；build 号待真机核对） |
| macOS version | **macOS 27.0.1（Build 26A434）**，用户 2026-11-10 实测 `sw_vers`，退出码 0；本执行机为 Ubuntu 24.04.5 LTS VM，无 macOS |
| Xcode version | **Xcode 27.2（Build 27B52）**，用户 2026-11-10 实测 `xcodebuild -version`，退出码 0；命令行工具路径正常，无需 `xcode-select --install` |
| XcodeGen version | **2.46.0**（Mac，2026-11-10 用户实测 `xcodegen --version`；`/Users/admin/.local/bin/xcodegen`，官方预编译包直装，无 Homebrew；最小 iOS 工程 `xcodegen generate` 冒烟测试通过） |
| Arduino CLI version | **1.5.1**（Commit 01f3d4f2b；Linux 执行机 `~/workspace/.local/bin/arduino-cli`，官方 install.sh 安装；Mac 侧同为 1.5.1，`/Users/admin/.local/bin/arduino-cli`，官方 macOS ARM64 tarball 直装，用户 2026-11-10 实测） |
| ESP32 Arduino Core exact version | **3.3.12**（上游 CI `.github/workflows/ci.yml` firmware job 固定值） |
| NimBLE-Arduino version | **2.5.1**（上游 README + CI） |
| Upstream commit SHA | **92b472fe0d46e0e8802c67915d20b236d145ab0e**（2026-11-09，`fix(ios): remove the saved key when the user clears the API key (#137)`；固件 FW 0.2.4） |
| Upstream tags for reference | v1.0.0 = d36296a（2026-11-03，固件 0.2.2，较旧，未采用）；v0.2.4 = 0b22d9a（2026-11-07） |
| PhoneAgent commit / branch | 464f0e70f6323941b5a7cee1933c4743a6ed15ee 起点；分支 `feat/pa-001-pin-upstream-m0-audit` |
| Model provider / model ID | Pending；never record API key |
| iOS App install method | 自编译签名（Xcode + XcodeGen，用户 2026-11-10 在了解 TestFlight 后最终确认；不用 TestFlight）。上游版本 1.0.4，deploymentTarget iOS 18.0，CODE_SIGN_STYLE Automatic；Apple ID 为免费账号（2026-11-10 确认），自签每 7 天重签，且 Hotspot Configuration 一键加热点不可用，改为手动输密码加入热点 |

## Firmware build (this VM, upstream CI-equivalent path)
| Field | Value |
|---|---|
| Build command | `hardware/flash.sh --build-only`（上游目录 `~/workspace/esp32-iphone-agent-upstream`，仅编译，不烧录） |
| FQBN | `esp32:esp32:esp32s3:USBMode=default,CDCOnBoot=cdc,FlashSize=8M,PSRAM=opi,PartitionScheme=default_8MB` |
| Build log | `docs/test-results/logs/upstream-build-2026-11-10.log`（已强制加入版本控制，见下注） |
| Flash / RAM usage | **Flash：1,502,407 bytes（44%），上限 3,342,336 bytes；RAM：117,316 bytes（35%），上限 327,680 bytes，剩余 210,364 bytes**（arduino-cli 默认输出原文，见日志） |
| Build result | **PASS（仅编译）** — 2026-11-10 14:48 CST，exit 0，编译约 3.5 分钟；产物 `hardware/build/hid_bridge.ino.bin`（1,502,560 bytes）、`hid_bridge.ino.merged.bin`（8,388,608 bytes）等已生成（产物在上游目录，不提交进本仓库） |

注：日志文件只有 210 字节、两行用量摘要，这是 arduino-cli 默认详细度下 `flash.sh --build-only` 成功时的全部 stdout，已如实保存；本仓库 `.gitignore:16` 有 `*.log` 规则，本次用 `git add -f` 把该日志加入 PR，以便评审直接看到原文。另：本次 VM 编译中途 `core update-index` 曾因出口网络 TLS 失败，修复方式是给 arduino-cli 配了本机出口代理（`~/.arduino15/arduino-cli.yaml`，无凭证）并用出口 CA 证书；这是本机环境配置，不在仓库内，Mac 上一般直连即可。

## Acceptance checklist
| ID | Check | Status | Evidence |
|---|---|---|---|
| M0-01 | USB HID enumerates; AssistiveTouch pointer visible/calibrated | BLOCKED_HARDWARE | |
| M0-02 | BLE pairing and service + five characteristics | BLOCKED_HARDWARE | |
| M0-03 | 100 ping/reply IDs match | BLOCKED_HARDWARE | |
| M0-04 | Status heartbeat updates | BLOCKED_HARDWARE | |
| M0-05 | Join ESP32 SoftAP | BLOCKED_HARDWARE | |
| M0-06 | AirPlay mirror starts | BLOCKED_HARDWARE | |
| M0-07 | H.264 CONFIG/IDR/sequence handling | BLOCKED_HARDWARE | |
| M0-08 | VideoToolbox decodes frames | BLOCKED_HARDWARE | |
| M0-09 | Cloud model request succeeds over cellular | BLOCKED_HARDWARE | |
| M0-10 | Low-risk tap followed by fresh-frame verification | BLOCKED_HARDWARE | |
| M0-11 | Stop/disconnect fail-closed behavior | BLOCKED_HARDWARE | |

注：BLE service UUID 与五个 characteristic 已在审计中与上游 `docs/ble-protocol.md` 逐项核对一致（见 PA-001 审计文件 §5），但这只是文档对照，不是真机发现——M0-02 仍为 BLOCKED_HARDWARE。

## Decision
- Build logs: 编译进行中，见上表
- Screenshots/videos: pending；redact private information before saving
- Heap/PSRAM/BLE/FPS/drop measurements: pending
- Known issues: 上游 AirPlay 代码为 GPL-3.0（UxPlay 移植），固件整体不得称为 MIT；上游 App 1.0.4 要求最新固件；上游视频除 BLE 外另有 Wi-Fi UDP 7200 / TCP 7201 通道，PA-005 需分别验证
- M0 decision: **NOT READY for M1 — 编译未回填、真机 11 项全部 BLOCKED_HARDWARE**
