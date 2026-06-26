from PIL import Image, ImageDraw

# Create a 48x48 transparent image
img = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Colors
BLACK = (0, 0, 0, 255)
WHITE = (255, 255, 255, 255)
DARK_GRAY = (128, 128, 128, 255)
LIGHT_GRAY = (192, 192, 192, 255)
BLUE = (0, 0, 128, 255)
LIGHT_BLUE = (0, 0, 255, 255)
YELLOW = (255, 255, 0, 255)
DARK_YELLOW = (128, 128, 0, 255)

# Let's draw a retro gear in the background/center
# Center at (22, 26) so it doesn't overlap the wrench too much
cx, cy = 22, 26
r_outer = 12
r_inner = 5

# Draw teeth (8 teeth)
import math
for i in range(8):
    angle = i * (math.pi / 4)
    # Tooth center line
    tx = cx + 15 * math.cos(angle)
    ty = cy + 15 * math.sin(angle)
    # Draw a small tooth block
    # Orthogonal vector to angle
    ox = -math.sin(angle) * 3
    oy = math.cos(angle) * 3
    
    # 4 points for the tooth polygon
    p1 = (cx + 10 * math.cos(angle) + ox, cy + 10 * math.sin(angle) + oy)
    p2 = (cx + 16 * math.cos(angle) + ox * 0.7, cy + 16 * math.sin(angle) + oy * 0.7)
    p3 = (cx + 16 * math.cos(angle) - ox * 0.7, cy + 16 * math.sin(angle) - oy * 0.7)
    p4 = (cx + 10 * math.cos(angle) - ox, cy + 10 * math.sin(angle) - oy)
    
    draw.polygon([p1, p2, p3, p4], fill=LIGHT_GRAY, outline=BLACK)

# Draw outer circle of gear body
draw.ellipse([cx - r_outer, cy - r_outer, cx + r_outer, cy + r_outer], fill=LIGHT_GRAY, outline=BLACK)
# Draw center hole
draw.ellipse([cx - r_inner, cy - r_inner, cx + r_inner, cy + r_inner], fill=DARK_GRAY, outline=BLACK)

# Draw a diagonal screwdriver/wrench
# Let's make it a screwdriver: red handle in bottom-left, silver shaft and tip in top-right
# Handle: from (8, 40) to (20, 28)
# Shaft: from (20, 28) to (36, 12)
# Tip: (36, 12) to (40, 8)

# Red screwdriver handle
HANDLE_COLOR = (192, 0, 0, 255)
HANDLE_LIGHT = (255, 64, 64, 255)
HANDLE_DARK = (128, 0, 0, 255)

# Handle border
draw.polygon([(6, 42), (10, 44), (24, 30), (20, 26)], fill=BLACK)
draw.polygon([(7, 41), (9, 43), (23, 29), (21, 27)], fill=HANDLE_COLOR)
# Highlights on handle
draw.line([(8, 42), (22, 28)], fill=HANDLE_LIGHT, width=1)
draw.line([(9, 43), (23, 29)], fill=HANDLE_DARK, width=1)

# Screwdriver metal shaft
SHAFT_COLOR = (220, 220, 220, 255)
SHAFT_BORDER = BLACK
# Shaft outline and fill
draw.line([(22, 28), (38, 12)], fill=SHAFT_BORDER, width=4)
draw.line([(22, 28), (38, 12)], fill=SHAFT_COLOR, width=2)

# Tip
draw.polygon([(36, 14), (40, 10), (42, 12), (38, 16)], fill=DARK_GRAY, outline=BLACK)

# Save the image
img.save("Sprites/icon_settings.png")
print("Saved Sprites/icon_settings.png successfully!")
