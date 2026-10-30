# Answer Book

[English](README.md) | 简体中文

**合上手机，它就是一本书；打开它，随机翻到写着答案的一页。**

Answer Book（中文名「答案之书」）是一个为 iPhone Duo 做的小型开源 iOS App，样子是一本黑色皮面、烫金封面、纸页泛黄的旧书。心里想一个问题，像翻书一样打开手机，读一读你翻到的那一页。把手机快速半合再打开，就能翻到下一页；合上，一切重新开始。

在没有铰链的 iPhone 和 iPad 上，点一下封面打开书，点书页翻页，向下滑合上。

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

- 黑色皮面精装书：烫金封面配四角花饰和徽章，答案印在泛黄的纸页上。在 iPhone Duo 的内屏上，打开的书会显示成左右两页。
- 文字是印在书里的，不是浮在上面。答案用思源宋体（Noto Serif SC）和 IM FELL English（复刻 17 世纪英国铅字）排版，像油墨一样渗进纸里；书名是压进皮革的烫金。
- 每次打开 App，先出现「答案之书」，再提示你「想一个问题吧」，然后才翻开书。
- 365 条原创答案，一年每天一条，有英文和简体中文，按读者的系统语言显示。
- 答案像洗过的牌一样发：每一页都读过之前不会重复，也绝不会连续两次是同一页。
- 支持 VoiceOver 标签、动态字体和减弱动态效果。书在浅色和深色模式下看起来一样，就像一件真实的物品。
- 不需要账号，不联网，不追踪。所有内容都只留在手机上。

## 构建

1. 安装 [XcodeGen](https://github.com/yonaskolb/XcodeGen) 和 Xcode 27.1 或更高版本。
2. 运行 `xcodegen generate`，然后打开 `AnswerBook.xcodeproj`。Xcode 会通过 Swift Package Manager 从 GitHub 拉取 [HingeKit](https://github.com/MIDJUG3Nine/HingeKit)。
3. 在 Signing & Capabilities 里设置你自己的开发团队。

Run scheme 设置了 `HINGE_SIMULATOR=1`，Debug 构建里会显示 HingeKit 的铰链模拟面板，这样在任何模拟器上都能试折叠手势。

## 美术素材

皮面、纸张、四角花饰、徽章和 App 图标都是用 SVG 画的，源文件在 [`design/`](design/) 里，里面写了怎么渲染成 `Assets.xcassets` 里的图片；油墨和烫金的纹理、以及把中文字体裁到只剩书里用到的字的脚本也在那里。

## 测试

```sh
xcodebuild test -scheme AnswerBook -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Star 趋势

<a href="https://www.star-history.com/#MIDJUG3Nine/AnswerBook_iDUO&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=midjug3nine%2fanswerbook_iduo&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=midjug3nine%2fanswerbook_iduo&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=midjug3nine%2fanswerbook_iduo&type=Date" />
  </picture>
</a>

## 许可

代码和答案文本都以 MIT 许可证发布。

`AnswerBook/Resources/Fonts` 里的字体（只保留书中用到的字的思源宋体 Noto Serif SC，以及 IM FELL English）使用 SIL Open Font License 1.1，许可文件就放在字体旁边。

Answer Book 这个名字和 App 图标不在许可范围内。如果你要发布自己的构建版本，请换成你自己的名字和图标。

这些答案是为本项目原创的，并非摘自任何一本书。本项目与 Apple 无关。iPhone 是 Apple Inc. 的商标。
