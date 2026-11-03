"""Compose store artwork from the original, unmodified simulator captures.

Run with Python 3 and Pillow on macOS, or supply licensed local fonts using
--regular-font and --bold-font. No fonts or third-party mockups are bundled.
"""

import argparse
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parent
DEVICES = {
    "iphone-6.9in-1320x2868": (1320, 2868),
    "ipad-13in-2064x2752": (2064, 2752),
}
SLIDES = [
    (
        "1-welcome",
        "A LITTLE MATH. A LOT OF FUN.",
        ("Little minds.", "Big discoveries."),
        ("Meet MathMunch, a playful math adventure", "for little learners aged 3-6."),
        "#E76532",
        "#FFF1E3",
    ),
    (
        "2-worlds",
        "CHOOSE YOUR ADVENTURE",
        ("Pick a world.", "Start exploring."),
        ("Begin at Apple Farm and discover more", "themed worlds as you progress."),
        "#25877F",
        "#E7F5EE",
    ),
    (
        "3-levels",
        "ONE LITTLE STEP AT A TIME",
        ("Small steps.", "New challenges."),
        ("Start with counting. Unlock the next level", "as you make your way through the world."),
        "#8062AA",
        "#F1ECFA",
    ),
    (
        "4-question",
        "SEE. COUNT. TAP.",
        ("Count the apples.", "Pick your answer."),
        ("Explore numbers with visual questions", "and big, easy-to-tap answer choices."),
        "#25877F",
        "#E8F6F4",
    ),
    (
        "5-answer",
        "LET'S TRY THE NEXT ONE",
        ("Keep counting.", "Keep discovering."),
        ("Practice one question at a time", "with short, playful counting levels."),
        "#E76532",
        "#FFF1E3",
    ),
]


class Artwork:
    def __init__(self, size, regular_font, bold_font):
        self.width, self.height = size
        self.scale = self.width / 1320
        self.logical_height = self.height / self.scale
        self.image = Image.new("RGB", size, "#FFF9F0")
        self.draw = ImageDraw.Draw(self.image)
        self.regular_font = regular_font
        self.bold_font = bold_font

    def px(self, value):
        return round(value * self.scale)

    def box(self, values):
        return tuple(self.px(v) for v in values)

    def font(self, size, bold=False):
        return ImageFont.truetype(
            str(self.bold_font if bold else self.regular_font), self.px(size)
        )

    def centered_text(self, text, y, size, color, bold=False):
        font = self.font(size, bold)
        bounds = self.draw.textbbox((0, 0), text, font=font)
        text_width = bounds[2] - bounds[0]
        if text_width > self.width - self.px(100):
            raise ValueError(f"Headline or caption is too wide: {text}")
        self.draw.text(
            ((self.width - text_width) / 2, self.px(y) - bounds[1]),
            text,
            font=font,
            fill=color,
        )

    def background(self, tint, accent):
        h = self.logical_height
        # Soft original geometric decorations, not borrowed from the references.
        layer = Image.new("RGB", self.image.size, tint)
        mask = Image.new("L", self.image.size)
        draw = ImageDraw.Draw(mask)
        draw.ellipse(self.box((-350, h * 0.48, 540, h * 0.95)), fill=255)
        draw.ellipse(self.box((860, h * 0.29, 1700, h * 0.70)), fill=255)
        mask = mask.filter(ImageFilter.GaussianBlur(self.px(50)))
        self.image.paste(layer, (0, 0), mask)
        self.draw = ImageDraw.Draw(self.image)
        for x, y, r, color in [
            (102, 190, 30, "#FFE4B1"),
            (1190, 280, 19, "#BFE4DE"),
            (90, h * 0.64, 15, "#F6C9B8"),
            (1210, h * 0.82, 28, "#FFE4B1"),
        ]:
            self.draw.ellipse(self.box((x - r, y - r, x + r, y + r)), fill=color)
        for x, y, size in [(1190, 130, 18), (112, h * 0.84, 24)]:
            points = []
            for i in range(8):
                angle = i * math.pi / 4
                radius = size if i % 2 == 0 else size * 0.28
                points.append(
                    (self.px(x + math.cos(angle) * radius),
                     self.px(y + math.sin(angle) * radius))
                )
            self.draw.polygon(points, fill=accent)

    def header(self, eyebrow, title, subtitle, accent):
        tablet = self.logical_height < 2000
        top = 65 if tablet else 115
        # Compact original brand mark.
        self.draw.rounded_rectangle(
            self.box((508, top, 812, top + 58)), self.px(29), fill="#FFFFFF"
        )
        self.centered_text("MathMunch", top + 13, 31, "#163F3E", bold=True)
        self.centered_text(eyebrow, top + 95, 23, accent, bold=True)
        title_y = top + 144
        title_size = 77 if tablet else 88
        line_spacing = 91 if tablet else 104
        self.centered_text(title[0], title_y, title_size, "#163F3E", bold=True)
        self.centered_text(
            title[1], title_y + line_spacing, title_size, accent, bold=True
        )
        subtitle_y = title_y + line_spacing + title_size + 30
        for index, line in enumerate(subtitle):
            self.centered_text(line, subtitle_y + index * 43, 31, "#58716D")
        return subtitle_y + 100

    def system_chrome(self, source, tablet, light):
        """Add illustrative system chrome only within captured safe-area margins."""
        capture = source.copy()
        draw = ImageDraw.Draw(capture)
        scale = capture.width / (2064 if tablet else 1320)
        foreground = "#FFFFFF" if light else "#171B1C"

        def box(values):
            return tuple(round(v * scale) for v in values)

        def rounded(values, radius, **kwargs):
            draw.rounded_rectangle(box(values), round(radius * scale), **kwargs)

        font_size = 25 if tablet else 48
        font = ImageFont.truetype(str(self.regular_font), round(font_size * scale))
        if tablet:
            draw.text(box((75, 15)), "9:41", font=font, fill=foreground)
            center_y = 32
            right = 1960
            # iPad has no Dynamic Island. The camera sits in the illustrated bezel.
        else:
            draw.text(box((105, 62)), "9:41", font=font, fill=foreground)
            center_y = 89
            right = 1202
            rounded((482, 40, 838, 142), 51, fill="#050607")
            draw.ellipse(box((782, 77, 809, 104)), fill="#10141A")
            draw.ellipse(box((790, 83, 801, 94)), fill="#182433")

        factor = 0.55 if tablet else 1

        def icon_box(values):
            x0, y0, x1, y1 = values
            return box((
                right + x0 * factor, center_y + y0 * factor,
                right + x1 * factor, center_y + y1 * factor,
            ))

        # Full cellular signal, Wi-Fi, and battery with consistent demo state.
        for i in range(4):
            draw.rounded_rectangle(
                icon_box((-163 + i * 15, 13 - i * 8, -153 + i * 15, 20)),
                max(1, round(2 * scale * factor)),
                fill=foreground,
            )
        for radius in (30, 21, 12):
            draw.arc(
                icon_box((-65 - radius, 14 - radius, -65 + radius, 14 + radius)),
                220, 320, fill=foreground,
                width=max(1, round(6 * scale * factor)),
            )
        draw.ellipse(icon_box((-69, 9, -61, 17)), fill=foreground)
        draw.rounded_rectangle(
            icon_box((-28, -14, 33, 17)),
            max(1, round(6 * scale * factor)),
            outline=foreground,
            width=max(1, round(3 * scale * factor)),
        )
        draw.rounded_rectangle(
            icon_box((-22, -8, 27, 11)),
            max(1, round(2 * scale * factor)),
            fill=foreground,
        )
        draw.rounded_rectangle(
            icon_box((37, -5, 42, 8)),
            max(1, round(2 * scale * factor)),
            fill=foreground,
        )
        indicator_width = 440 if not tablet else 360
        indicator_height = 14 if not tablet else 9
        cx = capture.width / 2
        bottom = capture.height - round((25 if not tablet else 15) * scale)
        width = round(indicator_width * scale)
        height = round(indicator_height * scale)
        draw.rounded_rectangle(
            (round(cx - width / 2), bottom - height, round(cx + width / 2), bottom),
            height // 2,
            fill=foreground,
        )
        return capture

    def device(self, source, min_y, light_chrome=False):
        h = self.logical_height
        tablet = h < 2000
        bezel = 19 if tablet else 24
        top = max(min_y + 40, h * (0.285 if tablet else 0.285))
        bottom = h - (90 if tablet else 150)
        max_width = 1130 if tablet else 925
        ratio = source.width / source.height
        screen_height = min(bottom - top - bezel * 2, (max_width - bezel * 2) / ratio)
        screen_width = screen_height * ratio
        outer_width = screen_width + bezel * 2
        outer_height = screen_height + bezel * 2
        x = (1320 - outer_width) / 2
        y = top
        radius = 52 if tablet else 105
        outer = self.box((x, y, x + outer_width, y + outer_height))

        shadow = Image.new("RGBA", self.image.size)
        sd = ImageDraw.Draw(shadow)
        sd.rounded_rectangle(
            self.box((x + 8, y + 24, x + outer_width + 8, y + outer_height + 24)),
            self.px(radius),
            fill=(16, 42, 40, 64),
        )
        shadow = shadow.filter(ImageFilter.GaussianBlur(self.px(23)))
        self.image.paste(shadow, (0, 0), shadow)
        self.draw = ImageDraw.Draw(self.image)
        # Illustrated hardware surrounds the real, proportionally scaled app UI.
        self.draw.rounded_rectangle(outer, self.px(radius), fill="#8A9290")
        self.draw.rounded_rectangle(
            self.box((x + 3, y + 3, x + outer_width - 3, y + outer_height - 3)),
            self.px(radius - 3),
            fill="#292F30",
        )
        self.draw.rounded_rectangle(
            self.box((x + 8, y + 8, x + outer_width - 8, y + outer_height - 8)),
            self.px(radius - 8),
            outline="#4C5655",
            width=self.px(2),
        )
        screen_size = (self.px(screen_width), self.px(screen_height))
        capture = self.system_chrome(source, tablet, light_chrome).resize(
            screen_size, Image.Resampling.LANCZOS
        )
        mask = Image.new("L", screen_size)
        ImageDraw.Draw(mask).rounded_rectangle(
            (0, 0, screen_size[0] - 1, screen_size[1] - 1),
            self.px(radius - bezel),
            fill=255,
        )
        self.image.paste(capture, (self.px(x + bezel), self.px(y + bezel)), mask)
        # Side buttons remain outside the captured interface.
        for offset, length in [(170, 50), (246, 100), (366, 100)]:
            self.draw.rounded_rectangle(
                self.box((x - 5, y + offset, x + 1, y + offset + length)),
                self.px(3),
                fill="#626D6C",
            )
        if tablet:
            camera_x = self.px(x + outer_width - bezel / 2)
            camera_y = self.px(y + outer_height / 2)
            r = self.px(4)
            self.draw.ellipse(
                (camera_x - r, camera_y - r, camera_x + r, camera_y + r),
                fill="#10141A",
            )
        self.centered_text("PLAYFUL MATH. LITTLE BY LITTLE.", h - 58, 20, "#6B8580")

    def save(self, path):
        self.image.save(path, optimize=True)


def generate(regular_font, bold_font):
    for folder, dimensions in DEVICES.items():
        destination = ROOT / "promotional-screenshots" / folder
        destination.mkdir(parents=True, exist_ok=True)
        for name, eyebrow, title, subtitle, accent, tint in SLIDES:
            source_path = ROOT / "screenshots" / folder / f"{name}.png"
            with Image.open(source_path) as original:
                if original.size != dimensions:
                    raise ValueError(f"Unexpected capture size: {source_path}")
                artwork = Artwork(dimensions, regular_font, bold_font)
                artwork.background(tint, accent)
                header_bottom = artwork.header(eyebrow, title, subtitle, accent)
                artwork.device(
                    original.convert("RGB"), header_bottom, light_chrome=name == "1-welcome"
                )
                artwork.save(destination / f"{name}.png")
        print(f"Created 5 promotional screenshots: {destination}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    fonts = Path("/System/Library/Fonts/Supplemental")
    parser.add_argument("--regular-font", type=Path, default=fonts / "Arial.ttf")
    parser.add_argument(
        "--bold-font", type=Path, default=fonts / "Arial Rounded Bold.ttf"
    )
    args = parser.parse_args()
    for font_path in (args.regular_font, args.bold_font):
        if not font_path.is_file():
            parser.error(f"Font not found: {font_path}; supply a local font path.")
    generate(args.regular_font, args.bold_font)
