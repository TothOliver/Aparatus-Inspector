from PIL import Image, ImageDraw

def draw_wifi_on():
    # 16x16 transparent image
    img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw 4 green vertical signal bars
    # Bar 1 (height 3)
    draw.rectangle([2, 12, 3, 14], fill=(0, 240, 0, 255))
    # Bar 2 (height 6)
    draw.rectangle([6, 9, 7, 14], fill=(0, 240, 0, 255))
    # Bar 3 (height 9)
    draw.rectangle([10, 6, 11, 14], fill=(0, 240, 0, 255))
    # Bar 4 (height 12)
    draw.rectangle([14, 3, 15, 14], fill=(0, 240, 0, 255))
    
    img.save("Sprites/wifi_on.png")
    print("Saved wifi_on.png")

def draw_wifi_off():
    # 16x16 transparent image
    img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw 4 gray vertical signal bars
    # Bar 1 (height 3)
    draw.rectangle([2, 12, 3, 14], fill=(120, 120, 120, 255))
    # Bar 2 (height 6)
    draw.rectangle([6, 9, 7, 14], fill=(120, 120, 120, 255))
    # Bar 3 (height 9)
    draw.rectangle([10, 6, 11, 14], fill=(120, 120, 120, 255))
    # Bar 4 (height 12)
    draw.rectangle([14, 3, 15, 14], fill=(120, 120, 120, 255))
    
    # Draw a red cross/slash over it
    # Diagonal line from top-left (0,0) to bottom-right (15,15)
    draw.line([1, 1, 14, 14], fill=(220, 0, 0, 255), width=2)
    
    img.save("Sprites/wifi_off.png")
    print("Saved wifi_off.png")

if __name__ == "__main__":
    draw_wifi_on()
    draw_wifi_off()
