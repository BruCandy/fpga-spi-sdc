'''正方形の描画'''
SET_COLUMN = const(0x2A)  # Column address set
SET_PAGE = const(0x2B)  # Page address set
WRITE_RAM = const(0x2C)  # Memory write


def draw_square(spi, cs, dc, rgb565):
    x1, x2 = 70, 170
    y1, y2 = 110, 210
    square_data = rgb565.to_bytes(2, 'big') * (x2 - x1 + 1)

    for y in range(y1, y2 + 1):
        # X範囲の設定
        dc(0)
        cs(0)
        spi.write(bytearray([SET_COLUMN]))
        cs(1)

        dc(1)
        cs(0)
        spi.write(bytearray([x1 >> 8, x1 & 0xff, x2 >> 8, x2 & 0xff]))
        cs(1)

        # Y範囲の設定
        dc(0)
        cs(0)
        spi.write(bytearray([SET_PAGE]))
        cs(1)

        dc(1)
        cs(0)
        spi.write(bytearray([y >> 8, y & 0xff, y >> 8, y & 0xff]))
        cs(1)

        # ピクセルデータを書き込む
        dc(0)
        cs(0)
        spi.write(bytearray([WRITE_RAM]))
        cs(1)

        dc(1)
        cs(0)
        spi.write(bytearray(square_data))
        cs(1)