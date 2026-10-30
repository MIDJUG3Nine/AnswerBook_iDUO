# Answer Book

[English](README.md) | 简体中文

**合上手机，它就是一本书；打开它，随机翻到写着答案的一页。**

Answer Book（中文名「答案书」）是一个为 iPhone Duo 做的小型开源 iOS App。心里想一个问题，像翻书一样打开手机，读一读你翻到的那一页。把手机快速半合再打开，就能翻到下一页；合上，一切重新开始。

在没有铰链的 iPhone 和 iPad 上，点一下封面就能打开书，用按钮或左右滑动来翻页。

## 截图

<!-- screenshots: cover (closed), a page (open), half open -->

iPhone Duo 模拟器上的截图稍后补上。

## 怎么用到铰链

这个 App 基于 [HingeKit](https://github.com/MIDJUG3Nine/HingeKit)，它把 iOS 27.1 的铰链 API 变成几个简单的事件：

| 你的动作 | HingeKit 事件 | 书的反应 |
| --- | --- | --- |
| 打开手机 | `.opened` | 随机翻到一页 |
| 快速半合再打开 | `.pageTurn` | 翻到另一页 |
| 合上手机 | `.closed` | 回到封面 |

具体见 `AnswerBook/Views/BookView.swift`，整个铰链逻辑大约十行。

## 功能

- 120 条原创答案，有英文和简体中文，按读者的系统语言显示。
- 答案像洗过的牌一样发：每一页都读过之前不会重复，也绝不会连续两次是同一页。
- 支持 VoiceOver 标签、动态字体、减弱动态效果和深色模式。
- 不需要账号，不联网，不追踪。所有内容都只留在手机上。

## 构建

1. 安装 [XcodeGen](https://github.com/yonaskolb/XcodeGen) 和 Xcode 27.1 或更高版本。
2. 运行 `xcodegen generate`，然后打开 `AnswerBook.xcodeproj`。Xcode 会通过 Swift Package Manager 从 GitHub 拉取 [HingeKit](https://github.com/MIDJUG3Nine/HingeKit)。
3. 在 Signing & Capabilities 里设置你自己的开发团队。

Run scheme 设置了 `HINGE_SIMULATOR=1`，Debug 构建里会显示 HingeKit 的铰链模拟面板，这样在任何模拟器上都能试折叠手势。

## 测试

```sh
xcodebuild test -scheme AnswerBook -destination 'platform=iOS Simulator,name=iPhone 17'
```

## 许可

代码和答案文本都以 MIT 许可证发布。

Answer Book 这个名字和 App 图标不在许可范围内。如果你要发布自己的构建版本，请换成你自己的名字和图标。

这些答案是为本项目原创的，并非摘自任何一本书。本项目与 Apple 无关。iPhone 是 Apple Inc. 的商标。
