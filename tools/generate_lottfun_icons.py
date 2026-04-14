from pathlib import Path
from math import cos, pi, sin

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont


SIZE = 1024
PURPLE = "#6A1B9A"
PURPLE_DARK = "#3E0E5C"
PURPLE_LIGHT = "#8E35C8"
GOLD = "#FFC107"
GOLD_LIGHT = "#FFD95A"
GOLD_DARK = "#D39A00"
RED = "#E53935"
WHITE = "#FFF9F1"


def rgba(hex_color, alpha=255):
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i : i + 2], 16) for i in (0, 2, 4)) + (alpha,)


def load_font(size):
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Supplemental/Helvetica.ttc",
        "/System/Library/Fonts/SFNS.ttf",
    ]
    for path in candidates:
        try:
            return ImageFont.truetype(path, size=size)
        except OSError:
            continue
    return ImageFont.load_default()


def rounded_mask(size=SIZE, radius=232):
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size, size), radius=radius, fill=255)
    return mask


def vertical_gradient(top, bottom, size=SIZE):
    img = Image.new("RGBA", (size, size))
    px = img.load()
    for y in range(size):
        t = y / (size - 1)
        color = tuple(int(top[i] * (1 - t) + bottom[i] * t) for i in range(4))
        for x in range(size):
            px[x, y] = color
    return img


def radial_glow(size, center, radius, color, strength=1.0):
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px = layer.load()
    cx, cy = center
    rr = radius * radius
    for y in range(size):
        for x in range(size):
            dx = x - cx
            dy = y - cy
            d2 = dx * dx + dy * dy
            if d2 > rr:
                continue
            distance = (d2 ** 0.5) / radius
            alpha = int((1 - distance) ** 2 * 255 * strength)
            px[x, y] = color[:3] + (alpha,)
    return layer.filter(ImageFilter.GaussianBlur(radius=40))


def make_base():
    bg = vertical_gradient(rgba(PURPLE_LIGHT), rgba(PURPLE_DARK))
    glow1 = radial_glow(SIZE, (230, 220), 360, rgba(GOLD, 180), 0.55)
    glow2 = radial_glow(SIZE, (820, 820), 420, rgba("#BA68C8", 160), 0.45)
    bg = Image.alpha_composite(bg, glow1)
    bg = Image.alpha_composite(bg, glow2)

    vignette = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(vignette)
    draw.rounded_rectangle((18, 18, SIZE - 18, SIZE - 18), radius=220, outline=(255, 255, 255, 45), width=4)
    bg = Image.alpha_composite(bg, vignette)
    return bg


def add_shadow(base, alpha_layer, blur=36, offset=(0, 20), alpha=110):
    shadow = Image.new("RGBA", base.size, (0, 0, 0, 0))
    shifted = ImageChops.offset(alpha_layer, offset[0], offset[1])
    blurred = shifted.filter(ImageFilter.GaussianBlur(blur))
    shadow.putalpha(blurred.split()[-1].point(lambda a: min(255, int(a * alpha / 255))))
    return Image.alpha_composite(base, shadow)


def text_center(draw, xy, text, font, fill):
    bbox = draw.textbbox((0, 0), text, font=font)
    w = bbox[2] - bbox[0]
    h = bbox[3] - bbox[1]
    draw.text((xy[0] - w / 2, xy[1] - h / 2 - 8), text, font=font, fill=fill)


def gold_ball(size, number, highlight=False, bonus=False):
    ball = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(ball)
    ring = rgba(RED if bonus else GOLD, 255)
    inner = rgba(GOLD_LIGHT if highlight else WHITE, 255)
    draw.ellipse((0, 0, size - 1, size - 1), fill=ring)
    inset = int(size * 0.08)
    draw.ellipse((inset, inset, size - inset, size - inset), fill=inner)
    if highlight:
        warm_core = radial_glow(size, (int(size * 0.42), int(size * 0.36)), int(size * 0.62), rgba("#FFF1B8", 220), 0.9)
        inner_mask = Image.new("L", (size, size), 0)
        ImageDraw.Draw(inner_mask).ellipse((inset, inset, size - inset, size - inset), fill=255)
        warm_core.putalpha(ImageChops.multiply(warm_core.split()[-1], inner_mask))
        ball = Image.alpha_composite(ball, warm_core)
        draw = ImageDraw.Draw(ball)
        draw.ellipse((inset, inset, size - inset, size - inset), outline=rgba("#FFE082", 115), width=max(4, int(size * 0.018)))
    draw.ellipse(
        (size * 0.18, size * 0.13, size * 0.5, size * 0.38),
        fill=(255, 255, 255, 120),
    )
    draw.ellipse(
        (size * 0.24, size * 0.2, size * 0.78, size * 0.82),
        outline=(255, 255, 255, 36),
        width=max(3, int(size * 0.012)),
    )
    font = load_font(int(size * 0.34))
    text_center(draw, (size / 2, size / 2), str(number), font, rgba(PURPLE_DARK if not bonus else "#7A0A0A"))
    return ball


def icon_lottery_balls():
    icon = make_base()
    alpha = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    balls = [
        (gold_ball(270, 8), (160, 430)),
        (gold_ball(320, 21, highlight=True), (355, 300)),
        (gold_ball(250, 42, bonus=True), (590, 470)),
    ]
    for ball, pos in balls:
        alpha.alpha_composite(ball, pos)
    icon = add_shadow(icon, alpha, blur=34, offset=(0, 20), alpha=130)
    return Image.alpha_composite(icon, alpha)


def icon_glowing_ball():
    icon = make_base()
    symbol = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    halo = radial_glow(SIZE, (512, 498), 250, rgba(GOLD, 150), 0.42)
    symbol = Image.alpha_composite(symbol, halo)
    ball = gold_ball(408, 7, highlight=True)
    symbol.alpha_composite(ball, (308, 308))
    icon = add_shadow(icon, symbol, blur=44, offset=(0, 28), alpha=150)
    return Image.alpha_composite(icon, symbol)


def icon_dice_hybrid():
    icon = make_base()
    symbol = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(symbol)
    cube = [(260, 322), (604, 248), (776, 390), (438, 478)]
    side = [(438, 478), (776, 390), (772, 698), (440, 784)]
    front = [(260, 322), (438, 478), (440, 784), (256, 628)]
    draw.polygon(cube, fill=rgba(GOLD, 255))
    draw.polygon(side, fill=rgba(GOLD_DARK, 255))
    draw.polygon(front, fill=rgba(GOLD_LIGHT, 255))
    for x, y, r in [(414, 410, 34), (540, 382, 34), (666, 354, 34), (382, 610, 34), (520, 566, 34)]:
        draw.ellipse((x - r, y - r, x + r, y + r), fill=rgba(PURPLE_DARK, 255))
    for x, y, r in [(336, 482, 30), (336, 646, 30), (424, 562, 30)]:
        draw.ellipse((x - r, y - r, x + r, y + r), fill=rgba(PURPLE_DARK, 255))
    ball = gold_ball(210, 9, highlight=True)
    symbol.alpha_composite(ball, (625, 585))
    icon = add_shadow(icon, symbol, blur=36, offset=(0, 26), alpha=150)
    return Image.alpha_composite(icon, symbol)


def icon_probability():
    icon = make_base()
    symbol = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(symbol)
    center = (512, 512)
    radii = [318, 240, 164]
    for idx, radius in enumerate(radii):
        box = (center[0] - radius, center[1] - radius, center[0] + radius, center[1] + radius)
        color = rgba(GOLD if idx == 0 else WHITE, 235 if idx == 0 else 120)
        draw.arc(box, start=196, end=34, fill=color, width=34 if idx == 0 else 22)
    node_positions = []
    for angle_deg, radius in [(204, 318), (346, 318), (298, 240), (30, 164), (146, 164)]:
        angle = angle_deg * pi / 180
        x = center[0] + cos(angle) * radius
        y = center[1] + sin(angle) * radius
        node_positions.append((x, y))
    for x, y in node_positions:
        draw.ellipse((x - 28, y - 28, x + 28, y + 28), fill=rgba(WHITE, 255))
    draw.ellipse((center[0] - 84, center[1] - 84, center[0] + 84, center[1] + 84), fill=rgba(GOLD, 255))
    draw.ellipse((center[0] - 28, center[1] - 28, center[0] + 28, center[1] + 28), fill=rgba(PURPLE_DARK, 255))
    icon = add_shadow(icon, symbol, blur=42, offset=(0, 24), alpha=140)
    return Image.alpha_composite(icon, symbol)


def icon_number_circle():
    icon = make_base()
    symbol = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(symbol)
    outer = (222, 222, 802, 802)
    inner = (270, 270, 754, 754)
    draw.ellipse(outer, fill=rgba(GOLD, 255))
    draw.ellipse(inner, fill=rgba(PURPLE_DARK, 255))
    draw.ellipse((314, 306, 610, 458), fill=rgba("#FFFFFF", 60))
    font = load_font(330)
    text_center(draw, (512, 533), "7", font, rgba(WHITE, 255))
    draw.ellipse((700, 296, 802, 398), fill=rgba(RED, 255))
    font_small = load_font(58)
    text_center(draw, (751, 345), "+", font_small, rgba(WHITE, 255))
    icon = add_shadow(icon, symbol, blur=40, offset=(0, 24), alpha=150)
    return Image.alpha_composite(icon, symbol)


def preview_sheet(images):
    cols = 3
    card = 420
    gap = 40
    rows = 2
    width = cols * card + (cols + 1) * gap
    height = rows * (card + 56) + (rows + 1) * gap
    sheet = Image.new("RGBA", (width, height), rgba("#16061F"))
    draw = ImageDraw.Draw(sheet)
    font = load_font(28)
    for i, (name, img) in enumerate(images):
        row = i // cols
        col = i % cols
        x = gap + col * (card + gap)
        y = gap + row * (card + 56 + gap)
        thumb = img.resize((card, card), Image.LANCZOS)
        draw.rounded_rectangle((x - 4, y - 4, x + card + 4, y + card + 4), radius=56, fill=rgba("#2A113A"))
        sheet.alpha_composite(thumb, (x, y))
        draw.text((x + 8, y + card + 14), name.replace("_", " "), font=font, fill=rgba(WHITE))
    return sheet


def main():
    out_dir = Path("assets/app_icon_concepts")
    out_dir.mkdir(parents=True, exist_ok=True)

    images = [
        ("01_golden_lottery_balls", icon_lottery_balls()),
        ("02_glowing_lucky_ball", icon_glowing_ball()),
        ("03_dice_lottery_hybrid", icon_dice_hybrid()),
        ("04_abstract_probability", icon_probability()),
        ("05_bold_number_circle", icon_number_circle()),
    ]

    for name, img in images:
        img.convert("RGB").save(out_dir / f"{name}.png")

    sheet = preview_sheet(images)
    sheet.convert("RGB").save(out_dir / "lottfun_icon_preview.png")


if __name__ == "__main__":
    main()
