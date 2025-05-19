import time


# Send initialization commands
SWRESET = const(0x01)  # Software reset
SLPOUT = const(0x11)  # Exit sleep mode
DISPLAY_ON = const(0x29)  # Display on
MADCTL = const(0x36)  # Memory access control
PIXFMT = const(0x3A)  # COLMOD: Pixel format set
PWCTR1 = const(0xC0)  # Power control 1
PWCTR2 = const(0xC1)  # Power control 2
VMCTR1 = const(0xC5)  # VCOM control 1
VMCTR2 = const(0xC7)  # VCOM control 2


def ili9341_init(spi, cs, dc):
    # Software reset
    dc(0)
    cs(0)
    spi.write(bytearray([SWRESET]))
    cs(1)
    time.sleep(.1)


    # Pwr ctrl 1
    dc(0)
    cs(0)
    spi.write(bytearray([PWCTR1]))
    cs(1)

    dc(1)
    cs(0)
    spi.write(bytearray([0x23]))
    cs(1)


    # Pwr ctrl 2
    dc(0)
    cs(0)
    spi.write(bytearray([PWCTR2]))
    cs(1)

    dc(1)
    cs(0)
    spi.write(bytearray([0x10]))
    cs(1)


    # VCOM ctrl 1
    dc(0)
    cs(0)
    spi.write(bytearray([VMCTR1]))
    cs(1)

    dc(1)
    cs(0)
    spi.write(bytearray((0x3E, 0x28)))
    cs(1)


    # VCOM ctrl 2
    dc(0)
    cs(0)
    spi.write(bytearray([VMCTR2]))
    cs(1)

    dc(1)
    cs(0)
    spi.write(bytearray([0x86]))
    cs(1)


    # Memory access ctrl
    dc(0)
    cs(0)
    spi.write(bytearray([MADCTL]))
    cs(1)

    dc(1)
    cs(0)
    spi.write(bytearray([0x88]))
    cs(1)


    # COLMOD: Pixel format
    dc(0)
    cs(0)
    spi.write(bytearray([PIXFMT]))
    cs(1)

    dc(1)
    cs(0)
    spi.write(bytearray([0x55]))
    cs(1)


    # Exit sleep
    dc(0)
    cs(0)
    spi.write(bytearray([SLPOUT]))
    cs(1)
    time.sleep(.1)


    # Display on
    dc(0)
    cs(0)
    spi.write(bytearray([DISPLAY_ON]))
    cs(1)
    time.sleep(.1)