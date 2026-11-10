# PhoneAgent — iPhone-first AI Phone Controller

[![Agent Core CI](https://github.com/Colouful/PhoneAgent/actions/workflows/agent-core.yml/badge.svg)](https://github.com/Colouful/PhoneAgent/actions/workflows/agent-core.yml)


> 状态：工程交接包已发布到 GitHub / M0 待执行。不是已完成的手机控制产品；真实硬件、Xcode 签名、AirPlay 和端到端 Agent 验收必须在设备上完成。

- **GitHub 仓库**：https://github.com/Colouful/PhoneAgent
- **上游基线**：https://github.com/onehumanbeing/esp32-iphone-agent
- **目标**：XIAO ESP32S3 + iPhone；日常任务执行不依赖电脑，Agent 在 iPhone App 中运行并调用云端视觉模型。
- **首发平台**：iPhone / iOS 18+；Android 作为 V1.5/V2 独立 Bridge。

## 实际数据链路

```text
                       iPhone cellular data
                    +----------------------------> Cloud Vision / LLM API
                    |
+-------------------+--------------------------+
| iPhone                                       |
| iOS Agent App: H.264 decode / observe / plan |
| validate / actor / verify / task history     |
+----------+-----------------------+-----------+
           | USB-C                 | BLE GATT
           | USB HID               | commands / status / H.264 chunks
           v                       v
+----------+-----------------------+-----------+
| XIAO ESP32-S3                               |
| USB HID mouse/keyboard · BLE Peripheral     |
| Wi-Fi SoftAP · AirPlay Receiver · H.264 relay|
+---------------------------+-----------------+
                            ^
                            | Wi-Fi Screen Mirroring / AirPlay
                            +---------------- iPhone
```

1. **USB-C**：ESP32 作为 USB HID Device，向 iPhone 提供鼠标/键盘输入；上游实测配置中由 iPhone 为板子供电。
2. **BLE**：iPhone App 是 Central，ESP32 是 Peripheral；传输命令、回复、状态、网络配置及 H.264 分块。
3. **Wi-Fi**：ESP32 创建 SoftAP 并运行 AirPlay Receiver；iPhone 镜像到板子。默认 SoftAP 不提供互联网出口，云端模型通过 iPhone 蜂窝数据访问。

## 上游已知基线（开始工作前重新核对）

- 测试板：**Seeed XIAO ESP32S3 标准版、8MB PSRAM**，不要擅自换 Sense/Plus。
- iOS 18+；USB-C iPhone 可直连；Lightning 机型需要兼容的 Lightning to USB Camera Adapter。
- 上游 README 当前要求 ESP32 Arduino Core 3.3.x 与 NimBLE-Arduino 2.5.1；必须用 `hardware/flash.sh`，因为脚本强制 include `nimble_cfg.h`。
- 上游实测目标约 480×1040、最高约 5 FPS；BLE 视频吞吐约 300–500 kbps。
- 需要用户开启 AssistiveTouch；锁屏、密码输入、Apple Pay、DRM 等受保护界面不可见。
- 当前上游已知限制包含 ASCII 文本输入、竖屏坐标假设和私有 iOS API `suspend`。自签名个人开发不代表 App Store 合规。
- BLE `net` characteristic 要求加密链路；协议使用 LE Secure Connections bonding / Just Works。Just Works 不提供 MITM 身份认证。

## 上游链接

- README：<https://github.com/onehumanbeing/esp32-iphone-agent>
- BLE 协议：<https://github.com/onehumanbeing/esp32-iphone-agent/blob/main/docs/ble-protocol.md>
- 固件脚本：<https://github.com/onehumanbeing/esp32-iphone-agent/blob/main/hardware/flash.sh>
- NimBLE 配置：<https://github.com/onehumanbeing/esp32-iphone-agent/blob/main/hardware/hid_bridge/nimble_cfg.h>
- iOS 工程配置：<https://github.com/onehumanbeing/esp32-iphone-agent/blob/main/ios/project.yml>
- XIAO 硬件文档：<https://wiki.seeedstudio.com/xiao_esp32s3_getting_started/>

上游 `main` 会变化。每个阶段必须记录实际上游 commit SHA、工具链精确版本和设备测试结果。

## 目录

```text
README.md
AGENTS.md
PROMPT_FOR_OTHER_AI.zh-CN.md
REPOSITORY_STATUS.md
CONTRIBUTING.md
SECURITY.md
docs/00-product-scope.md ... docs/13-architecture-decisions.md
agent-core/                  # 平台无关 Action Contract 与校验 Swift Package
schemas/                      # JSON Schema
protocols/                    # BLE GATT YAML
hardware/                     # 急停 GPIO 示例，非完整固件
backlog/                      # GitHub Issue 草案
scripts/                      # 检查与 GitHub 发布脚本
.github/                      # CI / issue / PR 模板
```

## 第一阶段：M0 基线复现

不要先重写固件、AirPlay 或 iOS App。按 `docs/08-m0-runbook.md` 在真实设备把上游原版跑通：记录板卡与 iPhone 信息、固定上游 commit、编译/烧录固件、Xcode 真机安装、逐项验证 USB HID、BLE GATT、Wi-Fi AP、AirPlay、H.264 BLE、VideoToolbox、云端模型和一次低风险 UI 点击。结果写入 `docs/test-results/M0-baseline.md`。

## M0 上游快速启动（macOS）

Mac 只用于首次构建、签名和烧录；日常任务不依赖 Mac。

```bash
git clone https://github.com/onehumanbeing/esp32-iphone-agent.git
cd esp32-iphone-agent
arduino-cli core list
arduino-cli lib install "NimBLE-Arduino@2.5.1"
hardware/flash.sh
cd ios
xcodegen
cp Config/Local.xcconfig.example Config/Local.xcconfig
# 编辑 Local.xcconfig，设置 DEVELOPMENT_TEAM 与 IA_BUNDLE_ID
open IPhoneAgent.xcodeproj
```

先根据上游 README 安装并记录精确 ESP32 Arduino Core 3.3.x patch 版本。不要提交 `Local.xcconfig`、API Key 或签名材料。

## 本仓库 Swift Core 测试

```bash
cd agent-core && swift test
```

`agent-core/` 不等于完整 iOS App，也不表示 ESP32 已完成集成。


## GitHub 工作项

M0 / M1 / 后续里程碑已拆为 16 个可执行 Issues：
- [PA-001 上游版本固定与审计](https://github.com/Colouful/PhoneAgent/issues/1)
- [PA-002 ESP32 固件编译与烧录](https://github.com/Colouful/PhoneAgent/issues/2)
- [PA-003 iPhone USB HID](https://github.com/Colouful/PhoneAgent/issues/3)
- [PA-004 BLE GATT](https://github.com/Colouful/PhoneAgent/issues/4)
- [PA-005 AirPlay / H.264 / VideoToolbox](https://github.com/Colouful/PhoneAgent/issues/5)
- [PA-006 iOS 真机安装与云模型](https://github.com/Colouful/PhoneAgent/issues/6)
- [PA-007 Action Contract](https://github.com/Colouful/PhoneAgent/issues/7)
- [PA-008 Agent 单动作闭环](https://github.com/Colouful/PhoneAgent/issues/8)
- [PA-009 安全确认与 Stop](https://github.com/Colouful/PhoneAgent/issues/9)
- [PA-010 Keychain 与数据保护](https://github.com/Colouful/PhoneAgent/issues/10)
- [PA-011 稳定性与故障注入](https://github.com/Colouful/PhoneAgent/issues/11)
- [PA-012 中文输入](https://github.com/Colouful/PhoneAgent/issues/12)
- [PA-013 横屏坐标](https://github.com/Colouful/PhoneAgent/issues/13)
- [PA-014 实体急停](https://github.com/Colouful/PhoneAgent/issues/14)
- [PA-015 Android 屏幕捕获 POC](https://github.com/Colouful/PhoneAgent/issues/15)
- [PA-016 Android Action Adapter](https://github.com/Colouful/PhoneAgent/issues/16)

其他 AI 编程代理先读 `AGENTS.md` 和 `PROMPT_FOR_OTHER_AI.zh-CN.md`，然后从 PA-001 / M0 开始。未通过 M0 不要重构上游底层模块。

## GitHub 工作流

主仓库已创建：<https://github.com/Colouful/PhoneAgent>。当前交付内容由维护者提交至 `main`。日后本地克隆后按 `CONTRIBUTING.md` 创建功能分支、运行测试并提交 PR。禁止强推覆盖远端历史。

## V1 验收边界

V1 目标是在用户授权、设备解锁、AirPlay 可见、蜂窝网络可用时，对可访问 App 完成低风险任务，并能观察、验证、停止。每次模型调用最多执行一个动作；无效 JSON、超时、断连、过期画面或越界坐标时 fail closed。付款、发送、删除、发布、购买、授权等高影响动作必须人工确认。API Key 用 Keychain；截图最小化采集并支持用户删除。

## 不在 V1 范围

- 任意 iOS 系统界面/受保护页面均可操作。
- 绕过系统权限、密码、验证码或 DRM。
- 未经确认的转账、购买、发送、删除、发布或授权。
- App Store 上架保证；私有 API 必须专项清理。
- 完整中文输入和横屏全覆盖（作为专项验证）。
- Android 与 iOS 共用同一屏幕采集实现；Android 使用自己的 Bridge。

## 许可证

本交付包未 vendoring 上游源码。上游 README 说明仓库主体 MIT，但 `hardware/hid_bridge/src/airplay/` 包含从 UxPlay 移植的 GPL-3.0 代码，组合分发固件受相应 GPL 义务影响。正式发布前阅读 `docs/11-license-review.md`，不要声称整个派生项目均为 MIT。
