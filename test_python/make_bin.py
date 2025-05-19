with open("test.bin", "wb") as f:
    #color_data = bytes([0xFF, 0xFF, 0xFF])  # RGB888: 白
    #color_data = bytes([0xFF, 0x00, 0x00])  # RGB888: 赤
    #color_data = bytes([0xFF, 0xFF, 0x00])  # RGB888: 黄
    color_data = bytes([0x00, 0xFF, 0x00])  # RGB888: 緑
    #color_data = bytes([0x00, 0x00, 0xFF])  # RGB888: 青
    for _ in range(1):
        f.write(color_data)
