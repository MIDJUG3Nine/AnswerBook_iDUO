# Artwork sources

The leather, paper, corner ornament, emblem and app icon are drawn in SVG and rendered to images with a browser.

- `textures.html`: leather (`#leatherTex`), paper (`#paperTex`), corner ornament (`#corner`) and emblem (`#emblem`)
- `icon.html`: the 1024 × 1024 app icon (`#icon`)

Open a file in Chrome or Safari and screenshot an element at its natural size, for example with Playwright:

```js
await (await page.$('#leatherTex')).screenshot({ path: 'leather.png' })
```

The rendered files live in `AnswerBook/Resources/Assets.xcassets`. Leather and paper are saved as JPEG; the corner and emblem keep their transparent background as PNG (@3x).
