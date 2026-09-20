#!/usr/bin/env python3
import os
import subprocess
from PIL import Image, ImageDraw, ImageFont, ImageFilter

def create_dmg_background(scale=1, output_path="assets/dmg_background.png"):
    width = 660 * scale
    height = 400 * scale

    # High quality base image with true sRGB color space
    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Smooth modern macOS background gradient (top-left to bottom-right)
    # Subtle clean macOS window gradient (#FBFBFC -> #EBEDF2)
    for y in range(height):
        ratio = y / height
        r = int(251 - ratio * 16)
        g = int(251 - ratio * 14)
        b = int(252 - ratio * 11)
        draw.line([(0, y), (width, y)], fill=(r, g, b, 255))

    # Center coordinates for icons
    # Left icon (Gox.app) at (180, 185)
    # Right icon (Applications) at (480, 185)
    left_cx = 180 * scale
    right_cx = 480 * scale
    icon_cy = 185 * scale

    # Arrow geometry
    arrow_start_x = 265 * scale
    arrow_end_x = 395 * scale
    arrow_y = icon_cy

    # Arrow shadow layer for depth
    shadow_img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow_img)

    line_thickness = int(7 * scale)
    head_len = int(18 * scale)
    head_half_w = int(14 * scale)

    # Draw arrow shadow
    s_offset_y = 3 * scale
    sdraw.line([(arrow_start_x, arrow_y + s_offset_y), (arrow_end_x, arrow_y + s_offset_y)], fill=(0, 0, 0, 45), width=line_thickness)
    sdraw.polygon([
        (arrow_end_x + head_len * 0.7, arrow_y + s_offset_y),
        (arrow_end_x - head_len * 0.5, arrow_y - head_half_w + s_offset_y),
        (arrow_end_x - head_len * 0.5, arrow_y + head_half_w + s_offset_y)
    ], fill=(0, 0, 0, 45))

    shadow_blur = shadow_img.filter(ImageFilter.GaussianBlur(3 * scale))
    img = Image.alpha_composite(img, shadow_blur)
    draw = ImageDraw.Draw(img)

    # Draw arrow body with gradient from Gox magenta to orange
    steps = int(arrow_end_x - arrow_start_x)
    for i in range(steps):
        t = i / steps
        # Magenta (224, 54, 114) -> Orange (255, 122, 0)
        r = int(224 + t * (255 - 224))
        g = int(54 + t * (122 - 54))
        b = int(114 + t * (0 - 114))
        cur_x = arrow_start_x + i
        draw.line([(cur_x, arrow_y - line_thickness / 2), (cur_x, arrow_y + line_thickness / 2)], fill=(r, g, b, 255))

    # Rounded start cap for arrow
    cap_r = line_thickness / 2
    draw.ellipse([arrow_start_x - cap_r, arrow_y - cap_r, arrow_start_x + cap_r, arrow_y + cap_r], fill=(224, 54, 114, 255))

    # Arrow head (triangle)
    head_tip = (arrow_end_x + head_len * 0.7, arrow_y)
    head_top = (arrow_end_x - head_len * 0.5, arrow_y - head_half_w)
    head_bottom = (arrow_end_x - head_len * 0.5, arrow_y + head_half_w)
    draw.polygon([head_tip, head_top, head_bottom], fill=(255, 122, 0, 255))

    # Typography fonts - prefer San Francisco (SFNS.ttf) for native macOS sharpness
    font_candidates = [
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/Supplemental/Arial.ttf"
    ]
    font_path = next((p for p in font_candidates if os.path.exists(p)), None)

    title_size = int(18 * scale)
    badge_title_size = int(13.5 * scale)
    badge_sub_size = int(11.5 * scale)

    try:
        font_title = ImageFont.truetype(font_path, title_size)
        font_badge1 = ImageFont.truetype(font_path, badge_title_size)
        font_badge2 = ImageFont.truetype(font_path, badge_sub_size)
    except Exception:
        font_title = ImageFont.load_default()
        font_badge1 = ImageFont.load_default()
        font_badge2 = ImageFont.load_default()

    # Top Title
    header_text = "Cài đặt Gox cho macOS"
    h_bbox = draw.textbbox((0, 0), header_text, font=font_title)
    h_w = h_bbox[2] - h_bbox[0]
    draw.text(((width - h_w) / 2, 34 * scale), header_text, fill=(30, 35, 45, 255), font=font_title)

    # Bottom Pill Badge
    t1 = "Kéo biểu tượng Gox vào thư mục Applications để cài đặt"
    t2 = "Drag the Gox icon into the Applications folder"

    badge_w = 440 * scale
    badge_h = 50 * scale
    badge_x = (width - badge_w) / 2
    badge_y = 312 * scale
    badge_r = 14 * scale

    # Badge soft shadow
    b_shadow = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    bs_draw = ImageDraw.Draw(b_shadow)
    bs_draw.rounded_rectangle([badge_x, badge_y + 2*scale, badge_x + badge_w, badge_y + badge_h + 2*scale], radius=badge_r, fill=(0, 0, 0, 20))
    b_shadow_blur = b_shadow.filter(ImageFilter.GaussianBlur(3 * scale))
    img = Image.alpha_composite(img, b_shadow_blur)
    draw = ImageDraw.Draw(img)

    # Badge container
    draw.rounded_rectangle([badge_x, badge_y, badge_x + badge_w, badge_y + badge_h], radius=badge_r, fill=(255, 255, 255, 230), outline=(215, 220, 228, 220), width=1*scale)

    # Badge text with high contrast
    t1_bbox = draw.textbbox((0, 0), t1, font=font_badge1)
    t1_w = t1_bbox[2] - t1_bbox[0]
    draw.text(((width - t1_w) / 2, badge_y + 8 * scale), t1, fill=(30, 35, 45, 255), font=font_badge1)

    t2_bbox = draw.textbbox((0, 0), t2, font=font_badge2)
    t2_w = t2_bbox[2] - t2_bbox[0]
    draw.text(((width - t2_w) / 2, badge_y + 28 * scale), t2, fill=(110, 116, 128, 240), font=font_badge2)

    # Subtle inner window border
    draw.rectangle([0, 0, width - 1, height - 1], outline=(218, 221, 226, 255), width=1 * scale)

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    # Save PNG with DPI metadata (72 DPI for 1x, 144 DPI for 2x)
    dpi_val = 72 * scale
    img.save(output_path, "PNG", dpi=(dpi_val, dpi_val))
    print(f"✔ Generated: {output_path} ({width}x{height} @ {dpi_val} DPI)")

def main():
    p1 = "assets/dmg_background.png"
    p2 = "assets/dmg_background@2x.png"
    ptiff = "assets/dmg_background.tiff"

    create_dmg_background(scale=1, output_path=p1)
    create_dmg_background(scale=2, output_path=p2)

    # Create multi-representation HiDPI TIFF using macOS native tiffutil
    cmd = ["tiffutil", "-cathidpicheck", p1, p2, "-out", ptiff]
    subprocess.run(cmd, check=True)
    print(f"✔ Generated HiDPI Multi-Rep TIFF: {ptiff}")

if __name__ == "__main__":
    main()
