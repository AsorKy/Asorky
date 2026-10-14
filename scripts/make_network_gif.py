"""
Generate an animated GitHub-profile header GIF: a moving complex-network
of nodes/edges on a white background, with "Hi there! I'm Asorky" text
and a waving emoji overlay, styled like the reference screenshot.
"""
import numpy as np
from PIL import Image, ImageDraw, ImageFont
import imageio.v2 as imageio
import os

W, H = 1200, 300
N_FRAMES = 40
N_NODES = 34
RNG = np.random.default_rng(7)

# Network nodes with velocity, confined to full width (text area included —
# nodes drift behind the text, like the reference image)
nodes = RNG.uniform([20, 20], [W - 20, H - 20], size=(N_NODES, 2)).astype(float)
vel = RNG.uniform(-0.6, 0.6, size=(N_NODES, 2))

# Build a stable neighbor graph (each node connects to its k nearest at frame 0)
def neighbor_edges(pts, k=3, max_dist=260):
    edges = []
    for i in range(len(pts)):
        d = np.linalg.norm(pts - pts[i], axis=1)
        d[i] = np.inf
        idx = np.argsort(d)[:k]
        for j in idx:
            if d[j] < max_dist:
                edges.append((i, int(j)))
    # dedupe
    seen = set()
    uniq = []
    for a, b in edges:
        key = (min(a, b), max(a, b))
        if key not in seen:
            seen.add(key)
            uniq.append(key)
    return uniq

edges = neighbor_edges(nodes)

# Fonts
font_path_candidates = [
    "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
]
font = None
for p in font_path_candidates:
    if os.path.exists(p):
        font = ImageFont.truetype(p, 56)
        break
if font is None:
    font = ImageFont.load_default()

emoji_font = None
for p in ["/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf"]:
    if os.path.exists(p):
        try:
            emoji_font = ImageFont.truetype(p, 109)
        except Exception:
            emoji_font = None

frames = []
text = "Hi there! I'm Asorky"

for f in range(N_FRAMES):
    img = Image.new("RGB", (W, H), (255, 255, 255))
    draw = ImageDraw.Draw(img)

    # advance node positions with gentle bounce
    nodes[:, 0] += vel[:, 0]
    nodes[:, 1] += vel[:, 1]
    for d in range(2):
        hi = W if d == 0 else H
        out_lo = nodes[:, d] < 10
        out_hi = nodes[:, d] > hi - 10
        vel[out_lo | out_hi, d] *= -1
        nodes[:, d] = np.clip(nodes[:, d], 10, hi - 10)

    # edges (light gray)
    for a, b in edges:
        x1, y1 = nodes[a]
        x2, y2 = nodes[b]
        draw.line([(x1, y1), (x2, y2)], fill=(200, 200, 200), width=1)

    # nodes (dark gray dots, slightly varying size for depth)
    for i, (x, y) in enumerate(nodes):
        r = 3 if i % 3 else 4.5
        draw.ellipse([x - r, y - r, x + r, y + r], fill=(90, 90, 90))

    # translucent white panel behind text for readability (like the ref image)
    overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    odraw = ImageDraw.Draw(overlay)
    bbox = draw.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    pad_x, pad_y = 40, 30
    cx, cy = W // 2 + 20, H // 2
    panel = [cx - tw // 2 - pad_x - 30, cy - th // 2 - pad_y,
             cx + tw // 2 + pad_x, cy + th // 2 + pad_y]
    odraw.rectangle(panel, fill=(255, 255, 255, 235))
    img = Image.alpha_composite(img.convert("RGBA"), overlay).convert("RGB")
    draw = ImageDraw.Draw(img)

    # waving hand emoji text fallback (simple yellow circle+text if no color emoji font)
    wave_x = cx - tw // 2 - 70
    wave_y = cy
    # small rotating wave effect via offset
    wobble = 4 * np.sin(f / N_FRAMES * 2 * np.pi * 3)
    if emoji_font:
        draw.text((wave_x, wave_y - 30 + wobble), "👋", font=emoji_font, embedded_color=True)
    else:
        draw.ellipse([wave_x - 22, wave_y - 22 + wobble, wave_x + 22, wave_y + 22 + wobble], fill=(255, 205, 0))

    # main text, typewriter-reveal for first ~18 frames, then steady with cursor blink
    reveal_frames = 18
    if f < reveal_frames:
        n_chars = max(1, int(len(text) * (f + 1) / reveal_frames))
        shown = text[:n_chars]
        cursor = "|" if f % 2 == 0 else ""
    else:
        shown = text
        cursor = "|" if (f // 3) % 2 == 0 else ""
    draw.text((cx - tw // 2, cy - th // 2 - bbox[1]), shown + cursor, font=font, fill=(20, 20, 20))

    frames.append(np.array(img))

out_path = "/tmp/claude-0/-home-claude/12634f69-da0a-5016-a941-fbb4a8f06e68/scratchpad/network_header.gif"
imageio.mimsave(out_path, frames, duration=0.07, loop=0)
print("Saved", out_path, "size:", os.path.getsize(out_path))
