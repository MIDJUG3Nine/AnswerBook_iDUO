# Answer Book

**Close your phone and it is a book. Open it and you land on a random page with an answer.**

Answer Book is a small open-source iOS app made for the iPhone Duo. Think of a question, open the phone like a book, and read the page you landed on. Flick the phone half shut and open it again to turn the page. Close it to start over.

On iPhones and iPads without a hinge, tap the cover to open the book and use the buttons or swipe to turn pages.

## How it uses the hinge

The app is built on [HingeKit](https://github.com/MIDJUG3Nine/HingeKit), which turns the iOS 27.1 hinge API into simple events:

| What you do | HingeKit event | What the book does |
| --- | --- | --- |
| Open the phone | `.opened` | Opens on a random page |
| Flick it half shut and back | `.pageTurn` | Turns to another page |
| Close the phone | `.closed` | Shows the cover again |

See `AnswerBook/Views/BookView.swift`; the whole hinge logic is about ten lines.

## Features

- 120 original answers in English and Simplified Chinese, shown in the reader's language.
- Answers are dealt like shuffled cards: no repeats until every page has been read, never the same page twice in a row.
- VoiceOver labels, Dynamic Type, Reduce Motion and Dark Mode are supported.
- No account, no network, no tracking. Nothing leaves the phone.

## Build

1. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen) and Xcode 27.1 or later.
2. Run `xcodegen generate` and open `AnswerBook.xcodeproj`. Xcode fetches [HingeKit](https://github.com/MIDJUG3Nine/HingeKit) from GitHub with Swift Package Manager.
3. Set your own team under Signing & Capabilities.

The Run scheme sets `HINGE_SIMULATOR=1`, which shows HingeKit's hinge simulator panel in Debug builds so you can try the fold gestures on any simulator.

## Tests

```sh
xcodebuild test -scheme AnswerBook -destination 'platform=iOS Simulator,name=iPhone 17'
```

## License

The code and the answer texts are released under the MIT License.

The Answer Book name and app icon are not covered by the license. If you publish your own build, please use your own name and icon.

The answers are written for this project and are not taken from any book. This project is not affiliated with Apple. iPhone is a trademark of Apple Inc.
