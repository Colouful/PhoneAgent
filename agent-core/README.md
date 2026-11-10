# PhoneAgentCore (Swift Package)

这是可单独运行单元测试的基础核心，不包含 CoreBluetooth、VideoToolbox、SwiftUI 或真实 HID transport。它先固定跨平台 Action contract、BLE UUID 和动作发送前的安全校验。

```bash
cd agent-core
swift test
```

将来集成进 iOS Xcode 工程时，把 PhoneAgentCore 作为本地 Swift Package dependency。实际 BLE 命令、指针定位与视频解码应复用上游 ios/ 现有实现，不能只凭本包替代完整设备驱动。
