from machine import Pin, SPI
import time
from square import draw_square
from ili9341_init import ili9341_init
from ili9341_clear import ili9341_clear


'''SDカード読み出し'''
def send_cmd(cmd, arg, crc):
    packet = bytearray(6)
    packet[0] = 0x40 | cmd
    packet[1] = (arg >> 24) & 0xFF
    packet[2] = (arg >> 16) & 0xFF
    packet[3] = (arg >> 8) & 0xFF
    packet[4] = arg & 0xFF
    packet[5] = crc
    spi.write(packet)
    for _ in range(100):
        r = spi.read(1)[0]
        if r & 0x80 == 0:
            return r
    return -1

def read_sector(sector):
    cs(1)
    spi.write(b'\xFF' * 8)
    time.sleep_us(200)
    cs(0)
    cmd = bytearray([
        0x51,
        (sector >> 24) & 0xFF,
        (sector >> 16) & 0xFF,
        (sector >> 8) & 0xFF,
        sector & 0xFF,
        0xFF
    ])
    spi.write(cmd)
    
    response_received = False
    for _ in range(8):
        r = spi.read(1)
        if r[0] != 0xFF:
            response_received = True
            break
    if not response_received:
        cs(1)
        raise RuntimeError("応答なし")
    response_received = False
    for _ in range(100000):
        token = spi.read(1)  # データトークン
        if token[0] == 0xFE:
            response_received = True
            break
    if not response_received:
        cs(1)
        raise RuntimeError("データトークンなし")
    data = spi.read(512)  # データブロック
    spi.read(2)  # CRC
    cs(1)
    return data

def normalize_fat_name(raw_name):
    name = raw_name[:8].decode('ascii', 'ignore').rstrip()
    extention  = raw_name[8:11].decode('ascii', 'ignore').rstrip()
    return f"{name}.{extention}".lower()


# 0 低速クロックでスタート
cs = Pin(21, Pin.OUT)  # SDカード
cs_2 = Pin(28, Pin.OUT, value=1)  # LCD
spi = SPI(0, baudrate=100000, sck=Pin(18), mosi=Pin(19), miso=Pin(16))
dc = Pin(22, Pin.OUT, value=0)
rst = Pin(27, Pin.OUT, value=1)

# 1 dummy clock
cs(1)
for _ in range(10):
    spi.write(b'\xFF')

# 2 CMD0
cs(0)
resp = send_cmd(0, 0, 0x95)
cs(1)
if resp != 0x01:
    raise Exception("CMD0 失敗")

# 3 CMD8 (必要)
cs(0)
resp = send_cmd(8, 0x1AA, 0x87)
r7 = spi.read(4)
cs(1)
if resp != 0x01:
    raise Exception("CMD8 失敗")

# 4 ACMD41（CMD55 + CMD41）
for _ in range(100):
    cs(0)
    send_cmd(55, 0, 0)
    resp = send_cmd(41, 0x40000000, 0)
    cs(1)
    if resp == 0x00:
        break
    time.sleep_ms(50)
else:
    raise Exception("ACMD41 失敗")

# 5 高速クロックに切り替え
spi.init(baudrate=13500000)
print("SDカード初期化完了")


# 6 基本情報の読み出し
mbr = read_sector(0)
PT_LbaOfs = int.from_bytes(mbr[0x1C6:0x1CA], 'little')
print("BPBの開始セクタ:", PT_LbaOfs)
bpb = read_sector(PT_LbaOfs)
BPB_SecPerClus = bpb[0x0D]
BPB_RsvdSecCnt = int.from_bytes(bpb[0x0E:0x10], 'little')
BPB_FATSz32 = int.from_bytes(bpb[0x24:0x28], 'little')
first_data_sector = PT_LbaOfs + BPB_RsvdSecCnt + 2 * BPB_FATSz32

BPB_RootClus = int.from_bytes(bpb[0x2C:0x30], 'little')  # 通常は2

found = False
for i in range(BPB_SecPerClus):
    sector = first_data_sector + (BPB_RootClus - 2) * BPB_SecPerClus + i
    print("探索中のセクタ番号:", sector)
    dir_sector = read_sector(sector)
    for j in range(0, 512, 32):
        if dir_sector[j] in (0x00, 0xE5): continue  # 先頭の1バイトは特殊な意味を持つ
        raw_name = dir_sector[j:j+11]
        full_name = normalize_fat_name(raw_name)
        print(f"検出: {full_name}")
        if full_name == "test.bin":
            cluster_low = int.from_bytes(dir_sector[j+26:j+28], 'little')
            cluster_high = int.from_bytes(dir_sector[j+20:j+22], 'little')
            first_cluster = (cluster_high << 16) | cluster_low
            size = int.from_bytes(dir_sector[j+28:j+32], 'little')
            print("ファイル名:", full_name)
            print("開始クラスタ:", first_cluster)
            print("サイズ:", size)
            found = True
            break
    if found: break

# 7 目標ファイルの読み出し
start_sector = first_data_sector + (first_cluster - 2) * BPB_SecPerClus
print("BPB_RootClus:", BPB_RootClus)
print("BPB_SecPerClus:", BPB_SecPerClus)
print("対象ファイルのクラスタ:", first_cluster)
print("BPB_RsvdSecCnt:", BPB_RsvdSecCnt)
print("BPB_FATSz32:", BPB_FATSz32)
print("対象ファイルの位置:", start_sector)
file_content = read_sector(start_sector)


# 8 確認
r = file_content[0]
g = file_content[1]
b = file_content[2]
print(file_content)
print(f"R={r:02X} G={g:02X} B={b:02X}")

rgb565 = ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3)



'''ili9341初期化'''
#　reset
rst(0)
time.sleep(.05)
rst(1)
time.sleep(.05)

# Send initialization commands
ili9341_init(spi, cs_2, dc)

# clear
ili9341_clear(spi, cs_2, dc)



'''正方形の描画'''
draw_square(spi, cs_2, dc, rgb565)














'''
MPY: soft reboot
SDカード初期化完了
BPBの開始セクタ: 8192
探索中のセクタ番号: 16384
検出: bootfs.
検出: b ...

探索中のセクタ番号: 16385
探索中のセクタ番号: 16386
検出: test.bin
ファイル名: test.bin
開始クラスタ: 6
サイズ: 3
BPB_RootClus: 2
BPB_SecPerClus: 4
対象ファイルのクラスタ: 6
BPB_RsvdSecCnt: 6174
BPB_FATSz32: 1009
対象ファイルの位置: 16400

R=00 G=FF B=00
'''
