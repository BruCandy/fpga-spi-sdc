# clear
width = 240
height = 320
SET_COLUMN = const(0x2A)  # Column address set
SET_PAGE = const(0x2B)  # Page address set
WRITE_RAM = const(0x2C)  # Memory write


def ili9341_clear(spi, cs, dc):
    line = bytearray(width * 2 * 8)
    y = 0
    while y < height:
        dc(0)
        cs(0)
        spi.write(bytearray([SET_COLUMN]))
        cs(1)

        dc(1)
        cs(0)
        spi.write(bytearray([0 >> 8, 0 & 0xff, width-1 >> 8, width-1 & 0xff]))
        cs(1)


        dc(0)
        cs(0)
        spi.write(bytearray([SET_PAGE]))
        cs(1)

        dc(1)
        cs(0)
        spi.write(bytearray([y >> 8, y & 0xff, y+7 >> 8, y+7 & 0xff]))
        cs(1)   


        dc(0)
        cs(0)
        spi.write(bytearray([WRITE_RAM]))
        cs(1)


        dc(1)
        cs(0)
        spi.write(bytearray(line))
        cs(1)   


        y += 8