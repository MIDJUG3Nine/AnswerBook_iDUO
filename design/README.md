# Artwork sources

The leather, paper, corner ornament, emblem and app icon are drawn in SVG and rendered to images with a browser.

- `textures.html`: leather (`#leatherTex`), paper for phones (`#paperTall`) and for the open iPhone Duo (`#paperWide`), corner ornament (`#corner`) and emblem (`#emblem`)
- `icon.html`: the 1024 × 1024 app icon (`#icon`)

Open a file in Chrome or Safari and screenshot an element at its natural size, for example with Playwright:

```js
await (await page.$('#leatherTex')).screenshot({ path: 'leather.png' })
```

The rendered files live in `AnswerBook/Resources/Assets.xcassets`. Leather and paper are saved as JPEG; the corner and emblem keep their transparent background as PNG (@3x).

## Ink and foil

The answers should look printed into the page and the title stamped into the leather, not laid on top. Two tiling masks do that (`Theme.swift`, `printedInk()` and `foilStamped()`):

- `ink-and-foil.py` draws `InkGrain` (ink thinner where the paper fibres didn't take it) and `FoilWear` (foil rubbed away in the leather grain), for the app and for the web page in `docs/`.

## Fonts

- Chinese: Noto Serif SC, Medium for the pages and Bold for the cover. The full font is 25 MB, so `fonts/subset.py` keeps only the characters the book prints (about 250 KB per weight). Run it again when an answer or a Chinese string gains a new character; `BookFontTests` fails and names the characters.
- Everything else: IM FELL English, a revival of 17th-century English type that keeps the uneven edges of letterpress (Roman for the pages, SC for the cover).

Both are under the SIL Open Font License 1.1. The license files are in `AnswerBook/Resources/Fonts`.
