#!/usr/bin/env python3
"""add-title.py — 把封面标题合成到 AI 生成的底图上，输出成品封面。

用法:
  python3 scripts/add-title.py --image 底图.png --title "标题文字" --out 成品.png \
      [--ratio 3:4] [--line2 "第二行"] [--stroke "#E65A14"] [--fill "#FFFFFF"] \
      [--top 0.07] [--width 0.92] [--font "/path/to/Font.ttf"]

规则（与 SKILL.md 的 3:4 竖版排版规范一致，参数默认值即规范值）:
  - 标题外轮廓宽约画布 92%（--width 可调 0.85-0.93）
  - 顶部安全边约 7%（--top）
  - 描边与阴影最外缘计入安全边
  - 两行标题时每行按各自字数分配宽度，形成均衡的大标题块
  - 阴影右下偏移 = 描边宽度的约 0.8 倍
  - 描边色默认从画面无从判断时使用暖橙 #E65A14；固定品牌色由用户指定

依赖: Pillow (pip install pillow)。字体默认按平台自动探测中文字体，
探测失败时用 --font 显式指定。
"""
import argparse
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

FONT_CANDIDATES = [
    "/System/Library/Fonts/STHeiti Medium.ttc",       # macOS
    "/System/Library/Fonts/PingFang.ttc",             # macOS
    "/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc",  # Linux
    "/usr/share/fonts/truetype/wqy/wqy-microhei.ttc",       # Linux
    "C:/Windows/Fonts/msyhbd.ttc",                    # Windows
    "C:/Windows/Fonts/msyh.ttc",                      # Windows
]


def detect_font() -> str:
    for p in FONT_CANDIDATES:
        if Path(p).exists():
            return p
    raise SystemExit(
        "未找到中文字体，请用 --font 指定一个 .ttf/.ttc 中文字体文件路径"
    )


def fit_font(draw, text, font_path, target_w, stroke_w):
    """二分逼近：找到渲染宽度 ≤ target_w 的最大字号。"""
    lo, hi = 8, 512
    best = 8
    while lo <= hi:
        mid = (lo + hi) // 2
        f = ImageFont.truetype(font_path, mid)
        bbox = draw.textbbox((0, 0), text, font=f, stroke_width=stroke_w)
        if bbox[2] - bbox[0] <= target_w:
            best = mid
            lo = mid + 1
        else:
            hi = mid - 1
    return ImageFont.truetype(font_path, best)


def render(image_path, lines, out_path, ratio, fill, stroke, shadow,
           top, width_ratio, font_path):
    img = Image.open(image_path).convert("RGB")
    W, H = img.size

    # 竖版 3:4 底图不合规格时仍照常合成，但提醒比例差异
    if ratio == "3:4" and abs(W / H - 0.75) > 0.02:
        print(f"⚠️ 底图比例 {W}x{H} 不是 3:4，排版数值按当前画布计算", file=sys.stderr)

    draw = ImageDraw.Draw(img)
    stroke_w = max(6, int(W * 0.011))  # 描边宽度随画布缩放
    shadow_off = max(4, int(stroke_w * 0.8))

    # 每行按字数占比分配 92% 总宽：字多的行更宽，两行形成均衡标题块
    weights = [len(t) for t in lines]
    total = sum(weights)
    fonts = []
    for text, w in zip(lines, weights):
        target_w = int(W * width_ratio * w / total)
        fonts.append(fit_font(draw, text, font_path, target_w, stroke_w))

    y = int(H * top)
    for text, f in zip(lines, fonts):
        bbox = draw.textbbox((0, 0), text, font=f, stroke_width=stroke_w)
        x = (W - (bbox[2] - bbox[0])) // 2 - bbox[0]
        draw.text((x + shadow_off, y + shadow_off), text, font=f,
                  fill=shadow, stroke_width=stroke_w, stroke_fill=shadow)
        draw.text((x, y), text, font=f, fill=fill,
                  stroke_width=stroke_w, stroke_fill=stroke)
        y += (bbox[3] - bbox[1]) + int(H * 0.02)

    img.save(out_path)
    print(f"saved: {out_path} ({W}x{H}, {len(lines)} 行标题)")


def main():
    ap = argparse.ArgumentParser(description="把标题文字合成到封面底图上")
    ap.add_argument("--image", required=True, help="底图路径")
    ap.add_argument("--title", required=True, help="标题（多行用 | 分隔，或用 --line2）")
    ap.add_argument("--line2", default=None, help="可选第二行")
    ap.add_argument("--out", required=True, help="输出路径")
    ap.add_argument("--ratio", default="3:4", choices=["3:4", "16:9", "any"])
    ap.add_argument("--fill", default="#FFFFFF", help="标题填充色")
    ap.add_argument("--stroke", default="#E65A14", help="描边色")
    ap.add_argument("--shadow", default="#1E1E3C", help="阴影色")
    ap.add_argument("--top", type=float, default=0.07, help="顶部安全边（画布高度占比）")
    ap.add_argument("--width", type=float, default=0.92, help="标题块宽度占比")
    ap.add_argument("--font", default=None, help="中文字体路径（默认自动探测）")
    args = ap.parse_args()

    lines = [t.strip() for t in args.title.split("|") if t.strip()]
    if args.line2:
        lines.append(args.line2.strip())

    render(args.image, lines, args.out, args.ratio,
           args.fill, args.stroke, args.shadow,
           args.top, args.width, args.font or detect_font())


if __name__ == "__main__":
    main()
