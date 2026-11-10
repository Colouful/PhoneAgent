# M0 — Mac 软件准备清单（板子到货前可先做完）

**适用：** 板子预计 2026-11-12 左右到；Mac 在身边；iPhone 16 Pro Max / iOS 27.3。
**目标：** 板子一到，只剩插线、烧录、真机验证，不再现装工具链。
**固定版本：** 上游 `92b472fe0d46e0e8802c67915d20b236d145ab0e`，ESP32 Core **3.3.12**，NimBLE-Arduino **2.5.1**。

## 1. 先报版本号（发回给我，我写入 M0-baseline）

- [x] 2026-11-10 已确认：macOS 27.0.1（26A434）、Xcode 27.2（27B52），两条命令退出码均为 0，命令行工具路径正常。
- [ ] 待确认：XcodeGen、arduino-cli 版本。

在 Mac 终端跑：

```bash
xcodegen --version 2>/dev/null || echo "XcodeGen not installed"
arduino-cli version 2>/dev/null || echo "arduino-cli not installed"
```

## 2. Xcode + XcodeGen

- App Store 安装 Xcode（很大，先下着）。上游提到 Xcode 26.3 / 27 可构建，不要求最新，但要记录实际版本。
- 装好后：

```bash
brew install xcodegen
xcodegen --version
```

## 3. Arduino 工具链（固件用，和我这边的 Linux 编译同一套版本）

```bash
brew install arduino-cli
arduino-cli core update-index --additional-urls https://espressif.github.io/arduino-esp32/package_esp32_index.json
arduino-cli core install esp32:esp32@3.3.12 --additional-urls https://espressif.github.io/arduino-esp32/package_esp32_index.json
arduino-cli lib install "NimBLE-Arduino@2.5.1"
arduino-cli core list
arduino-cli lib list
```

## 4. 上游克隆 + 只编译不烧录（板子没到也能验证工具链）

```bash
git clone https://github.com/onehumanbeing/esp32-iphone-agent.git
cd esp32-iphone-agent
git rev-parse HEAD   # 应为 92b472fe0d46e0e8802c67915d20b236d145ab0e
hardware/flash.sh --build-only
```

PASS 标准：编译退出 0，输出里有 Flash/RAM 使用量。把完整日志发我，我记入 M0-baseline。
注意：没板子时**不要**跑不带 `--build-only` 的 `flash.sh`，它会找串口。

## 5. iOS App 装法（已定：B，自己用 Xcode 编译签名，2026-11-10）

```bash
cd esp32-iphone-agent/ios
xcodegen
cp Config/Local.xcconfig.example Config/Local.xcconfig
# 编辑 Local.xcconfig：填 DEVELOPMENT_TEAM 和唯一的 IA_BUNDLE_ID
open IPhoneAgent.xcodeproj
```

已核对（上游固定 commit `92b472f`）：
- `Config/Shared.xcconfig`：MARKETING_VERSION = 1.0.4，deploymentTarget iOS 18.0，CODE_SIGN_STYLE = Automatic。
- `Local.xcconfig` 默认不启用 entitlements（`IA_ENTITLEMENTS` 为空）。要启用“一键加入板子热点”，需在 Xcode 登录 Apple ID 后把 `IA_ENTITLEMENTS = IPhoneAgent/IPhoneAgent.entitlements` 和 `IA_WIDGET_ENTITLEMENTS = AgentActivity/AgentActivity.entitlements` 写进 `Local.xcconfig`；其中 Hotspot Configuration 能力需要付费开发者账号，没有的话 App 会直接显示热点密码、手动加入，一样能用。
- 免费 Apple ID 也能签，但每 7 天要重新签名一次；付费账号则无此限制。
- 上游文档称 App 用了私有 iOS API `suspend`、自签不等同于 App Store 合规。本轮在固定 commit 的 Swift 源码里 grep 只找到两处“suspended”的日志/注释，未定位到字面调用点——合规结论仍按文档警告处理，PA-006 真机构建时再以 Xcode 实际构建/告警为准，不提前宣称合规或不合规。

`Local.xcconfig`、证书、API Key 一律不提交、不发给我。TestFlight 仅作备选，不再作为主路线。

## 6. iPhone 侧现在就能准备的

- 确认蜂窝数据可用（模型走蜂窝，因为 Wi-Fi 会被 ESP32 热点占用，热点本身不提供上网）。
- 准备好云端视觉模型的 endpoint + Key（OpenAI 兼容、能收图片的接口即可）；Key 只在 App 里填进 Keychain，**不要发给我、不要写进任何文件**。
- AssistiveTouch、屏幕镜像、BLE 配对等板子到了再按 `docs/08-m0-runbook.md` 一步步做，现在不用提前开。

## 7. 板子到了当天的顺序

1. Mac 上 `hardware/flash.sh` 烧录（先确认串口是 XIAO 再刷）。
2. iPhone 装 App（TestFlight 或自签）。
3. 按 runbook 依次验证：USB HID → BLE 五个 characteristic → SoftAP → AirPlay 镜像 → H.264 → 模型调用 → 低风险点击 → Stop/断连。
4. 每项只记实测结果，PASS/FAIL/BLOCKED_HARDWARE 写进 `docs/test-results/M0-baseline.md`。
