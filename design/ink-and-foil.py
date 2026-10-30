"""Draws the two masks that make the type look printed rather than laid on top.

- InkGrain: ink is a little thinner where the paper fibres didn't take it, with tiny gaps.
- FoilWear: gold foil is rubbed away where the leather grain is deep.

Both are 512 × 512 alpha masks that tile seamlessly (the noise is filtered in the frequency
domain, so it wraps around). They are used at @3x, which repeats them every 170 points.

    pip install numpy pillow
    python3 design/ink-and-foil.py
"""
import pathlib

import numpy as np
from PIL import Image

repo = pathlib.Path(__file__).resolve().parents[1]
rng = np.random.default_rng(7)
n = 512


def periodic_noise(sigma):
    """Seamless noise: white noise low-passed in the frequency domain, scaled to unit variance."""
    spectrum = np.fft.fft2(rng.standard_normal((n, n)))
    k = np.fft.fftfreq(n)
    kx, ky = np.meshgrid(k, k)
    spectrum *= np.exp(-(kx**2 + ky**2) * (2 * np.pi * sigma) ** 2 / 2)
    a = np.real(np.fft.ifft2(spectrum))
    return (a - a.mean()) / a.std()


def save(alpha, name, folder):
    a = (np.clip(alpha, 0, 1) * 255).astype(np.uint8)
    path = repo / folder / name
    path.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(np.dstack([np.zeros_like(a)] * 3 + [a]), "RGBA").save(path)
    print(path.relative_to(repo))


ink = 0.86 + 0.07 * periodic_noise(0.8) + 0.06 * periodic_noise(3.0) + 0.05 * periodic_noise(14.0)
ink = np.where(periodic_noise(1.2) > 2.3, ink * 0.45, ink)
ink = np.clip(ink, 0.35, 1.0)

grain = periodic_noise(1.4) + 0.5 * periodic_noise(4.0)
foil = 1.0 - np.clip((grain - 1.6) * 0.9, 0, 1)
foil *= 0.9 + 0.1 * np.clip(periodic_noise(20.0), -1, 1)
foil = np.clip(foil, 0.15, 1.0)

assets = "AnswerBook/Resources/Assets.xcassets"
save(ink, "inkgrain@3x.png", f"{assets}/InkGrain.imageset")
save(foil, "foilwear@3x.png", f"{assets}/FoilWear.imageset")
save(ink, "inkgrain.png", "docs/assets")
save(foil, "foilwear.png", "docs/assets")
