#!/usr/bin/env python3
"""Generates every icon file (macOS 1024px PNG + Windows multi-res .ico) from a
single high-res source, so every size is resized down from real pixels (never
upscaled -> no blocky pixelation) and gets a size-aware contrast boost plus a
thin brand-colored outline (so it still reads at 16px tray size instead of
washing out, without changing how it looks at large sizes where the original
colors already have enough contrast on their own).

Usage: python3 make-icon.py <source.png> [--outline-color RRGGBB]

<source.png> should be the artwork cropped tight to its content, ideally at
a decently high native resolution (the current Figma export is ~460x340,
which is already what this script is built around).
"""
import argparse
import sys
from pathlib import Path

from PIL import Image, ImageEnhance, ImageFilter, ImageOps

HERE = Path(__file__).resolve().parent
MACOS_ICON = HERE / "Assets" / "AppIcon-1024.png"
WINDOWS_ICON = HERE.parent / "windows-widget" / "Assets" / "AppIcon.ico"

# Below this rendered size, pastel gradients and thin strokes stop reading -
# add an outline and punch up contrast/saturation so the silhouette still
# reads on both light and dark trays.
SMALL_SIZE_THRESHOLD = 64
ICO_SIZES = [16, 24, 32, 48, 64, 128, 256]
MACOS_SIZE = 1024


def pad_to_square(im: Image.Image, margin_ratio: float = 0.14) -> Image.Image:
    w, h = im.size
    side = max(w, h)
    canvas_size = int(side / (1 - 2 * margin_ratio))
    canvas = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    canvas.paste(im, ((canvas_size - w) // 2, (canvas_size - h) // 2), im)
    return canvas


def add_outline(im: Image.Image, color: tuple, px: int) -> Image.Image:
    """Draws a solid-color silhouette `px` pixels larger than the artwork's
    alpha mask behind it, like a stroke - this is what keeps the icon
    legible at small sizes instead of just thin pastel lines on nothing."""
    if px <= 0:
        return im
    alpha = im.split()[-1]
    dilated = alpha.filter(ImageFilter.MaxFilter(px * 2 + 1))
    outline_layer = Image.new("RGBA", im.size, color + (255,))
    outline_layer.putalpha(dilated)
    out = Image.alpha_composite(outline_layer, im)
    return out


def render_at(source: Image.Image, size: int, outline_color: tuple) -> Image.Image:
    resized = source.resize((size, size), Image.LANCZOS)

    if size <= SMALL_SIZE_THRESHOLD:
        # Scale outline/contrast strength down smoothly as size grows, so
        # 16px gets a visible stroke + punchy color and 64px gets barely any.
        strength = 1.0 - (size - 16) / (SMALL_SIZE_THRESHOLD - 16)
        strength = max(0.0, min(1.0, strength))
        outline_px = max(1, round(1 + strength * 1.5))

        boosted = ImageEnhance.Color(resized).enhance(1.0 + 0.9 * strength)
        boosted = ImageEnhance.Contrast(boosted).enhance(1.0 + 0.5 * strength)
        return add_outline(boosted, outline_color, outline_px)

    return resized


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="high-res source PNG, transparent background")
    parser.add_argument(
        "--outline-color",
        default="c07b82",  # matches the site's --c-focus-strong accent
        help="hex RRGGBB outline color used at small sizes (default: c07b82)",
    )
    args = parser.parse_args()

    if not args.source.exists():
        sys.exit(f"source not found: {args.source}")

    outline_color = tuple(int(args.outline_color[i : i + 2], 16) for i in (0, 2, 4))

    raw = Image.open(args.source).convert("RGBA")
    bbox = raw.getbbox()
    if bbox:
        raw = raw.crop(bbox)
    squared = pad_to_square(raw)

    # macOS: one big PNG, resized down from the squared source - no upscaling.
    macos_png = squared.resize((MACOS_SIZE, MACOS_SIZE), Image.LANCZOS)
    MACOS_ICON.parent.mkdir(parents=True, exist_ok=True)
    macos_png.save(MACOS_ICON)
    print(f"wrote {MACOS_ICON} ({MACOS_SIZE}x{MACOS_SIZE})")

    # Windows: render each size natively (down from the squared source, never
    # upscaled from a smaller frame) with the small-size contrast/outline pass.
    sized_frames = {size: render_at(squared, size, outline_color) for size in ICO_SIZES}
    largest = sized_frames[max(ICO_SIZES)]
    WINDOWS_ICON.parent.mkdir(parents=True, exist_ok=True)
    largest.save(
        WINDOWS_ICON,
        sizes=[(s, s) for s in ICO_SIZES],
        append_images=[sized_frames[s] for s in ICO_SIZES if s != max(ICO_SIZES)],
    )
    print(f"wrote {WINDOWS_ICON} ({', '.join(str(s) for s in ICO_SIZES)})")


if __name__ == "__main__":
    main()
