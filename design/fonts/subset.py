"""Builds the app's Chinese font: Noto Serif SC cut down to the characters the book prints.

The full font is 25 MB; the subset is about 220 KB per weight. Run it again whenever an answer
or a Chinese interface string gains a character the font doesn't have yet (BookFontTests fails
and names the characters).

    pip install fonttools brotli
    curl -LO "https://raw.githubusercontent.com/google/fonts/main/ofl/notoserifsc/NotoSerifSC%5Bwght%5D.ttf"
    python3 design/fonts/subset.py NotoSerifSC[wght].ttf [extra-text-file ...]

Writes AnswerBook/Resources/Fonts/NotoSerifSC-{Medium,Bold}.ttf and, for the web page,
docs/assets/fonts/NotoSerifSC-{Medium,Bold}.woff2. Extra text files add their characters
(for example docs/index.html, so the web page has every character it shows).
"""
import json
import pathlib
import re
import sys

from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

repo = pathlib.Path(__file__).resolve().parents[2]
app = repo / "AnswerBook"

chars = set("".join(re.findall(r'zh: "([^"]*)"', (app / "Model/Answers.swift").read_text("utf-8"))))
catalog = json.loads((app / "Resources/Localizable.xcstrings").read_text("utf-8"))
for entry in catalog["strings"].values():
    for localization in entry.get("localizations", {}).values():
        chars |= set(localization["stringUnit"]["value"])
chars |= set("0123456789 %，。！？、：；“”‘’（）…—·《》「」")
for extra in sys.argv[2:]:
    chars |= {c for c in pathlib.Path(extra).read_text("utf-8") if ord(c) > 0x2E7F}
text = "".join(sorted(chars))
print(len(text), "characters")

for weight, style in [(500, "Medium"), (700, "Bold")]:
    for flavor, path in [
        (None, app / f"Resources/Fonts/NotoSerifSC-{style}.ttf"),
        ("woff2", repo / f"docs/assets/fonts/NotoSerifSC-{style}.woff2"),
    ]:
        font = instancer.instantiateVariableFont(TTFont(sys.argv[1]), {"wght": weight})
        for record in font["name"].names:
            if record.nameID in (1, 16):
                record.string = "Noto Serif SC"
            elif record.nameID in (2, 17):
                record.string = style
            elif record.nameID == 4:
                record.string = f"Noto Serif SC {style}"
            elif record.nameID == 6:
                record.string = f"NotoSerifSC-{style}"
            elif record.nameID == 3:
                record.string = f"NotoSerifSC-{style}-subset"
        font["OS/2"].usWeightClass = weight
        options = subset.Options()
        options.name_IDs = ["*"]
        options.layout_features = ["*"]
        subsetter = subset.Subsetter(options)
        subsetter.populate(text=text)
        subsetter.subset(font)
        font.flavor = flavor
        path.parent.mkdir(parents=True, exist_ok=True)
        font.save(path)
        print(path.relative_to(repo), path.stat().st_size // 1024, "KB")
