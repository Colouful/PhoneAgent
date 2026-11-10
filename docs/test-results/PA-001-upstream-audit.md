# PA-001 — 上游版本固定与仓库审计（M0.1）

**Issue:** https://github.com/Colouful/PhoneAgent/issues/1
**日期：** 2026-11-10
**分支：** `feat/pa-001-pin-upstream-m0-audit`
**状态：** 审计完成；编译进行中（见下）；真机验证 BLOCKED_HARDWARE

## 1. 本仓库

- Remote: https://github.com/Colouful/PhoneAgent，默认分支 main
- 审计起点 commit：`464f0e70f6323941b5a7cee1933c4743a6ed15ee`（docs: add CI status badge）
- 审计前 `git status` 干净，无本地改动被覆盖；未做 reset / force-push。
- 本轮只新增文档、更新 `docs/test-results/M0-baseline.md`，未改固件、未改 agent-core、未改 schema/协议。

## 2. 上游固定版本（pinned）

- 上游：https://github.com/onehumanbeing/esp32-iphone-agent
- **固定 commit：`92b472fe0d46e0e8802c67915d20b236d145ab0e`**
- Commit 日期：2026-11-09 18:19:44 +0800
- Commit 内容：`fix(ios): remove the saved key when the user clears the API key (#137)`
- 克隆位置（独立目录，不 vendoring 进本仓库）：`~/workspace/esp32-iphone-agent-upstream`
- 克隆后 `git status --short` 为空，工作区干净。
- 固件版本（`hardware/hid_bridge/version.h`）：`FW_VERSION "0.2.4"`

### 为什么固定 HEAD 而不是打 tag

- `v1.0.0` tag = `d36296a`（2026-11-03），固件还是 0.2.2，比 HEAD 旧。
- `v0.2.4` tag = `0b22d9a`（2026-11-07），固件 0.2.4，但 HEAD 在此之后又多了修复：#122（CLI daemon 死锁）、#125（校准失败不再保留）、#132（wait_idr / snap）、#137（清除 API key）。
- 上游 App 1.0.4 要求最新固件。因此固定 HEAD SHA `92b472f`，而不是用旧 tag。HEAD 是移动中的 main，SHA 本身就是冻结点；后续如需升级，必须另开 PR 改 SHA 并重跑编译+真机。

## 3. 工具链固定版本

| 工具 | 固定版本 | 来源 |
|---|---|---|
| ESP32 Arduino Core | **3.3.12** | 上游 `.github/workflows/ci.yml` firmware job：`arduino-cli core install esp32:esp32@3.3.12` |
| NimBLE-Arduino | **2.5.1** | 上游 README + CI：`arduino-cli lib install "NimBLE-Arduino@2.5.1"` |
| arduino-cli | 待编译子任务回填（本机此前未安装） | `arduino-cli version` 实测值写入编译日志 |
| Xcode / XcodeGen | 本机无 macOS，无法安装/验证 | 见 §7 BLOCKED |

上游 README 只写 3.3.x / 2.5.x，精确 patch 3.3.12 以 CI 为准——CI 在 ubuntu-latest 上就是用这个版本跑 `hardware/flash.sh --build-only` 的。

## 4. 硬件固定

- 板子：**Seeed XIAO ESP32S3 标准版，8MB PSRAM**；不是 Sense、不是 Plus。
- 证据：上游 README 表格明确写 plain version, 8 MB PSRAM；`hardware/hid_bridge/hid_bridge.ino` 首行注释同款说明。
- `hardware/flash.sh` 的 FQBN 与之对应：
  `esp32:esp32:esp32s3:USBMode=default,CDCOnBoot=cdc,FlashSize=8M,PSRAM=opi,PartitionScheme=default_8MB`
- flash.sh 支持 `--build-only`（已逐行核对脚本，含 `--debug/--sta/--ap-tune` 参数），且强制 `-include hid_bridge/nimble_cfg.h`，即 NimBLE 缓冲区覆盖。禁止绕开 flash.sh 直接用 IDE 编译（上游说明：直接编译会在 static_assert 处失败）。

## 5. 协议对照（本仓库 vs 上游）

- 上游 BLE Service：`6e400001-a9e8-4b1b-9c39-6d6f8a3c0000`，与本仓库 `protocols/ble-gatt.yaml` 完全一致。
- 五个 characteristic 一致：cmd `...0001`（write）、reply `...0002`（notify）、status `...0003`（notify+read，1s 心跳 JSON）、video `...0004`（notify，H.264 分块）、net `...0005`（read+write，需加密链路）。
- 安全：LE Secure Connections bonding / Just Works；`net` 要求加密链路。Just Works 不提供 MITM 身份认证——已在 README 中注明，不作改动。
- iOS 工程：上游 `ios/project.yml`，deploymentTarget iOS 18.0，XcodeGen 生成，`Config/Local.xcconfig.example` 含 DEVELOPMENT_TEAM / IA_BUNDLE_ID，`Local.xcconfig` 不提交；竖屏 `UISupportedInterfaceOrientations: Portrait`。

## 6. License / NOTICE 审查

| 位置 | 许可证 |
|---|---|
| 上游根 `LICENSE` / `NOTICE` | MIT，Copyright (c) 2026 Henry Yuan；NOTICE 要求保留版权声明，公开项目/演示需可见致谢 |
| `hardware/hid_bridge/src/airplay/`（`LICENSE-GPL.md`） | **GPL-3.0**：UxPlay 移植的 AirPlay receiver，源自 RPiPlay / playfair |
| `hardware/hid_bridge/src/airplay/playfair/LICENSE.md` | GPL-3.0 |
| `skills/LICENSE` | MIT No Attribution，Copyright (c) 2026 Henry Yuan |

结论与本仓库 `docs/11-license-review.md`、`docs/NOTICE-AND-LICENSE.md` 一致：**不得把整个派生固件说成 MIT**。分发含 AirPlay 代码的固件二进制受 GPL-3.0 义务约束；正式发布前仍需按 checklist 做源码可获得性与声明对齐。本轮未复制、分发任何上游源码。

## 7. 本机环境与 BLOCKED 项（实测，非推测）

本次执行环境是 Linux VM（Ubuntu 24.04.5 LTS，x86_64），不是 Mac：

- `swift`：未安装，`./scripts/check-starter-kit.sh` 的 Swift 测试被跳过（脚本原文输出 `SKIP Swift tests: Swift not installed`）；schema JSON 与 BLE YAML 基础检查通过（`BLE protocol basic check: OK`）。
- `/dev/ttyUSB*`、`/dev/ttyACM*`：不存在；`lsusb` 未安装。**没有 XIAO 板子接在本机上。**
- macOS / Xcode / XcodeGen：本机没有，iOS 构建无法在本机执行。
- iPhone：未连接本机。

因此：
- **固件编译可以在本机做**：上游 CI 的 firmware job 本来就在 ubuntu-latest 上跑同一套命令（arduino-cli + core 3.3.12 + NimBLE 2.5.1 + `flash.sh --build-only`）。编译结果以 `docs/test-results/logs/upstream-build-2026-11-10.log` 为准，正在子任务中执行。
- **烧录、iOS 构建、M0-01…M0-11 全部真机项：BLOCKED_HARDWARE**。需要威哥在 Mac 上接 XIAO + iPhone 后按 `docs/08-m0-runbook.md` 执行，或把板子/iPhone 接到可执行环境。本轮不虚构任何一项 PASS。

## 8. 与上游的偏差（审计发现，留给 PA-002…PA-006 核对）

1. 上游已演进到 App 1.0.4 / 固件 0.2.4，含中文输入 crash 修复（#111）、Xcode 26.3/27 构建修复（#112）、CLI daemon（`esp32agent`）与 Wi-Fi 视频通道；本仓库 docs 仍按早期基线（约 480×1040、最高约 5 FPS、BLE 视频 300–500 kbps）描述，需在 PA-005 实测后更新数字，不要直接照抄旧数。
2. 上游视频除 BLE 外已有 Wi-Fi 通道：UDP 7200、TCP 7201（`hello <vtok>` + `ka` 心跳），`vtok` 仅在加密的 `net` 读取中出现。PA-005 验证时要区分 BLE video 与 Wi-Fi video 两条路径分别记录。
3. 上游 App 1.0.4 要求最新固件，旧固件会弹 Board Update Required——烧录后若 App 提示升级，先核对固件版本再处理，不要跳过。
4. 上游提到 iOS 27.3 / Xcode 27 相关修复，但 `project.yml` 的 deploymentTarget 仍是 iOS 18.0；目标机型仍按 iOS 18+，具体 iPhone 型号/iOS build 以真机实测记录为准。

## 9. 编译状态（已完成，实测）

- 命令与上游 CI 一致：`hardware/flash.sh --build-only`，上游目录 `~/workspace/esp32-iphone-agent-upstream`，仅编译，未烧录。
- **结果：PASS（仅编译），exit 0**，2026-11-10 14:48 CST，编译约 3.5 分钟。
- 工具链实测：arduino-cli **1.5.1**（Commit 01f3d4f2b）；ESP32 Core **3.3.12**；NimBLE-Arduino **2.5.1**（注：`lib list` 显示 2.5.2 已可获得，但本次按上游要求固定 2.5.1，未升级）。
- 用量原文：`Sketch uses 1502407 bytes (44%) of program storage space. Maximum is 3342336 bytes.` / `Global variables use 117316 bytes (35%) of dynamic memory, leaving 210364 bytes for local variables. Maximum is 327680 bytes.`
- 产物：`hardware/build/hid_bridge.ino.bin`（1,502,560 bytes）、`hid_bridge.ino.merged.bin`（8,388,608 bytes）、bootloader/partitions/elf/map，时间戳均为 14:48。
- 日志：`docs/test-results/logs/upstream-build-2026-11-10.log`（210 字节，两行摘要原文；已 `git add -f` 加入本 PR）。
- 编译前上游 `git status` 干净、编译后仍干净，HEAD 未变；本轮未改上游源码。
- 中途真实故障：首次 `core update-index` 因本机出口网络 TLS 失败（`tls: first record does not look like a TLS handshake`），原因是 arduino-cli 不读环境变量代理，需写 `~/.arduino15/arduino-cli.yaml` 配出口代理并用出口 CA 证书；修复后 core 安装约 9.5 分钟、lib 安装约 4 秒。这是本机环境问题，Mac 上一般直连即可。
- **Mac 侧编译（2026-11-10 17:39 CST，同样 PASS）：** 上游已克隆到 Mac `/Users/admin/esp32-iphone-agent`，detached HEAD 固定 `92b472f`；Core 3.3.12 与 NimBLE 2.5.1 在脚本运行前已装好，`core list` / `lib list` 核对无误；`hardware/flash.sh --build-only` exit 0，Flash 1,502,583 bytes（44%）、RAM 117,316 bytes（35%）。完整 47 行日志已从 Mac 的 `/Users/admin/phoneagent-mac-setup.log` 读回核对。Mac Flash 比 Linux VM 大 176 bytes（构建路径差异），RAM 相同。
- 在编译 PASS + 真机 BLOCKED 解除之前，**不进入 M1**。编译成功不等于 M0 验收通过。
