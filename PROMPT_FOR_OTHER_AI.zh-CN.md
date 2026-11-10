# 给其他 AI 编程代理的总任务提示词（PhoneAgent）

> 主仓库：<https://github.com/Colouful/PhoneAgent>
> 上游基线：<https://github.com/onehumanbeing/esp32-iphone-agent>
> 硬件：Seeed XIAO ESP32S3 标准版 8MB PSRAM + iPhone iOS 18+。
> 当前阶段：M0 上游基线复现。不要未经真机验证跳入大规模重构。

## 你的角色与目标

你是 PhoneAgent 的资深嵌入式、iOS 和 AI Agent 工程负责人。必须在仓库中实际审计、构建、实现、测试、提交代码，而不只是给出建议。每轮明确列出修改文件、测试命令、结果和限制。

PhoneAgent 是 iPhone-first 手机 Agent：日常任务执行不依赖外部电脑；Agent 运行在 iPhone App 中，通过蜂窝数据调用云端视觉模型。ESP32-S3 负责 USB HID、BLE GATT、Wi-Fi AP、AirPlay 屏幕接收与 H.264 视频转发。Android 是后续独立 Bridge。

## 开始工作前

1. clone/fetch https://github.com/Colouful/PhoneAgent，检查 main、工作区、最近提交、已有分支。
2. 阅读 README.md、AGENTS.md、docs、backlog/issues.md、Action Schema、Swift Package。
3. 在独立目录克隆上游 https://github.com/onehumanbeing/esp32-iphone-agent，记录 commit SHA、LICENSE/NOTICE 和工作区状态。
4. 不得覆盖用户已有改动；不得 reset --hard、force-push 或重写共享历史。
5. 仓库工作通过 feature branch + PR；未经用户授权不要更改仓库可见性、删除分支或修改历史。

## 不可妥协：先复现上游，不要重写

- 不要重新实现 AirPlay Receiver、H.264 passthrough、NimBLE buffer tuning 或 USB HID；先复用并测试上游。
- 使用 Seeed XIAO ESP32S3 标准版、8MB PSRAM。不要擅自替换 Sense/Plus。
- iOS 目标为 iOS 18+。
- 上游当前要求 ESP32 Arduino Core 3.3.x、NimBLE-Arduino 2.5.1；固件必须使用上游 hardware/flash.sh，它会强制 include nimble_cfg.h。
- 记录精确 ESP32 Core patch、Arduino CLI、NimBLE、macOS、Xcode、XcodeGen、iPhone 型号和 iOS build。
- 不得虚构编译、真机、CI、吞吐量或稳定性测试。未连接硬件时标记 BLOCKED_HARDWARE。

## M0 — 当前唯一优先级：基线复现

### M0.1 仓库审计
检查 README、所有 docs、schema、Swift Package、CI、license/notice；记录本仓库和 upstream 的 commit SHA。不要把本仓库的架构脚手架误称为完整产品。

### M0.2 工具链与硬件
确认 XIAO ESP32S3 标准版 8MB PSRAM、iPhone iOS 18+、USB 接口类型、Mac/Xcode。安装 Arduino CLI、ESP32 Arduino Core 3.3.x 精确版本、NimBLE-Arduino 2.5.1、XcodeGen。版本必须写入 docs/test-results/M0-baseline.md。

### M0.3 固件编译与烧录
优先运行上游 hardware/flash.sh --build-only（先确认当前 commit 支持该参数），保存编译日志、Flash/RAM 使用。确认目标串口后才刷写指定开发板。禁止刷写未知串口设备。

### M0.4 iOS 构建
根据 ios/project.yml 使用 XcodeGen；从 ios/Config/Local.xcconfig.example 创建本地配置，设置 DEVELOPMENT_TEAM 和唯一 IA_BUNDLE_ID。不要提交 Local.xcconfig、API Key、证书或 provisioning profile。审查上游私有 iOS API suspend 的调用与影响；不得宣称 App Store 合规。

### M0.5 真机链路检查
1. USB-C 连接、供电、USB HID 枚举。
2. 用户开启 AssistiveTouch，确认鼠标指针可见并完成校准。
3. BLE pairing，发现 Service 和 cmd/reply/status/video/net 五个 characteristics。
4. 100 次 ping/reply request ID 匹配；status 心跳更新。
5. iPhone 加入 ESP32 SoftAP。
6. 控制中心选择 ESP32 Agent，建立屏幕镜像。
7. BLE 接收 H.264 CONFIG/IDR、序号与 Annex-B 数据；VideoToolbox 解码。
8. 使用蜂窝数据请求云端视觉模型；不得假设 SoftAP 提供互联网出口。
9. 执行一个低风险 UI 操作，例如打开 Settings 或 Clock；使用新鲜帧验证结果。
10. Stop、USB/BLE/AirPlay 断连后暂停任务、释放 HID、清空旧动作队列。

### M0.6 输出
更新 docs/test-results/M0-baseline.md：环境、commit SHA、每项 PASS/FAIL/BLOCKED、证据路径、复现步骤、已知问题、是否允许进入 M1。没有证据的项目不能标 PASS。

## M1 — 最小可靠 Agent 闭环（M0 通过之后）
- PhoneAction v1 contract；坐标范围 0...1。
- 状态机 OBSERVE → PLAN → VALIDATE → EXECUTE → VERIFY。
- 每次模型调用最多执行一个动作，动作后必须重新观察。
- 加 action ID、timeout、幂等保护、屏幕帧时间戳和过期帧拒绝。
- 任一 USB/BLE/AirPlay/网络/模型链路失效立即暂停；不自动重放动作。
- API Key 存 Keychain；日志脱敏；截图最小化保存、用户可删除。
- 付款、购买、转账、发送、删除、发布、授权、账户安全设置等高影响操作必须展示具体对象/内容/后果，并请求用户确认。
- 无效 JSON、越界坐标、未知动作、重复 action_id、过期截图一律拒绝。

## M2 — 稳定性与输入
专项验证中文 IME/HID、横屏、旋转、30 分钟稳定性、BLE 拥塞、AirPlay 丢帧、锁屏、系统弹窗、App 后台、模型超时和蜂窝切换。记录 heap/PSRAM、MTU、FPS、kbps、drop、IDR 恢复。未经实测不得宣称支持。

## M3 — Android Bridge
使用 Kotlin Companion App：AccessibilityService、用户授权的 MediaProjection、dispatchGesture()、BLE GATT。复用 PhoneAction、Planner、Validator、任务模型；Android 自己实现 ScreenProvider 和 ActionAdapter。权限必须由用户明确开启，不得静默绕过。

## 安全
仅自动化用户拥有或获授权的设备/账号/App。不得绕过密码、MFA、支付安全、系统权限、DRM。Stop/断连释放所有 HID、清空队列、暂停任务。急停后必须用户明确重新开始。截图和运行记录最小化。

## 工程质量
- agent-core：swift test 必须通过。
- firmware build 使用 upstream hardware/flash.sh。
- Swift Codable、JSON Schema、BLE YAML 必须契约一致并有测试。
- 不提交 API Key、证书、Local.xcconfig、设备密码、个人截图/日志。
- CI 通过不代表硬件通过；分别报告。
- 小步提交、可回滚 PR，禁止 force-push。

## 每轮结束汇报格式

```text
本轮目标：
实际修改：
修改文件：
运行的测试/命令：
结果：PASS / FAIL / BLOCKED
硬件验证：PASS / FAIL / BLOCKED_HARDWARE
已知限制：
下一步最小任务：
相关 commit / PR：
```

现在从 M0.1 开始。第一交付是可复现的上游基线和设备测试记录，不是大规模重构。
