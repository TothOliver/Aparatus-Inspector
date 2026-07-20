from PIL import Image, ImageDraw

def create_strike_icon():
    # 32x32 RGBA image
    size = 32
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Red card/badge outline and fill
    # Box from (2, 2) to (29, 29)
    # Outer dark border
    draw.rectangle([2, 2, 29, 29], outline=(40, 40, 40, 255), fill=(210, 45, 45, 255))
    # Top/left highlight border
    draw.line([(3, 3), (28, 3)], fill=(240, 90, 90, 255))
    draw.line([(3, 3), (3, 28)], fill=(240, 90, 90, 255))
    # Bottom/right shadow border
    draw.line([(3, 28), (28, 28)], fill=(140, 25, 25, 255))
    draw.line([(28, 3), (28, 28)], fill=(140, 25, 25, 255))
    
    # Draw Thumbs Down icon inside (White with dark border)
    # Hand cuff on left (x: 8..11, y: 10..18)
    draw.rectangle([8, 10, 11, 18], fill=(220, 220, 220, 255), outline=(30, 30, 30, 255))
    draw.rectangle([9, 11, 10, 17], fill=(255, 255, 255, 255))
    
    # Fist / main hand (x: 12..21, y: 10..18)
    draw.rectangle([12, 10, 21, 18], fill=(255, 255, 255, 255), outline=(30, 30, 30, 255))
    # Knuckle details (horizontal lines)
    draw.line([(12, 12), (18, 12)], fill=(180, 180, 180, 255))
    draw.line([(12, 14), (18, 14)], fill=(180, 180, 180, 255))
    draw.line([(12, 16), (18, 16)], fill=(180, 180, 180, 255))
    
    # Thumb pointing down (x: 16..20, y: 19..24)
    draw.polygon([(16, 18), (22, 18), (20, 24), (16, 24)], fill=(255, 255, 255, 255), outline=(30, 30, 30, 255))

    img.save("Sprites/icon_error_strike.png")
    print("Created Sprites/icon_error_strike.png")

if __name__ == "__main__":
    create_strike_icon()
