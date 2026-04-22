#!/usr/bin/env sh
# PS3 Joystick 全自动安装脚本
# 集成: BlueZ六轴补丁 + 原生sixpair编译 + pygame + 系统服务
# 支持: Linux(树莓派) / macOS(跨平台)

# 原ds4drv限制已删除 → Pygame跨平台支持
if [ "$(uname)" == "Darwin" ]; then
	echo "✅ macOS 已支持！自动跳过Linux驱动编译，仅安装Python依赖"
    SKIP_DRIVER=1
fi

# 定位脚本目录
FOLDER=$(dirname $(realpath "$0"))
cd "$FOLDER"

echo "============================================="
echo "  PS3 蓝牙手柄 一键安装程序"
echo "============================================="

# ===================== 1. 安装通用依赖 =====================
echo "[1/7] 安装基础依赖..."
sudo apt update
sudo apt install -y build-essential libusb-dev libusb-1.0-0-dev python3-pip joystick

# ===================== 2. 编译安装 BlueZ (仅Linux) =====================
if [ -z "$SKIP_DRIVER" ]; then
echo "[2/7] 编译安装 PS3 专用 BlueZ 驱动..."
git clone https://github.com/luetzel/bluez.git
cd bluez
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-library --enable-sixaxis
make -j2
sudo make install
cd ..

# 重启蓝牙 + 锁定版本
sudo systemctl daemon-reload
sudo systemctl restart bluetooth
sudo apt-mark hold bluez bluez-tools
fi

# ===================== 3. 编译 sixpair (按你提供的源码生成) =====================
echo "[3/7] 编译 sixpair 配对工具..."
cd ~
wget http://www.pabr.org/sixlinux/sixpair.c
gcc -o sixpair sixpair.c -lusb
cd "$FOLDER"

# ===================== 4. 安装Pygame跨平台手柄库 =====================
echo "[4/7] 安装Pygame手柄驱动..."
sudo pip3 install pygame
sudo apt install -y python3-pygame

# ===================== 5. 系统权限配置 =====================
echo "[5/7] 配置硬件权限..."
sudo usermod -aG input pi
sudo usermod -aG bluetooth pi

# ===================== 6. 安装PS3Joystick库 =====================
echo "[6/7] 安装手柄Python模块..."
sudo python3 setup.py clean --all install

# ===================== 7. 部署系统服务 =====================
echo "[7/7] 注册开机自启服务..."
for file in *.service; do
	[ -f "$file" ] || break
	sudo ln -sf "$FOLDER/$file" /lib/systemd/system/
done
sudo systemctl daemon-reload

echo "============================================="
echo "✅ 安装完成！"
echo "============================================="
echo "【首次配对步骤】"
echo "1. USB连接手柄 → 运行 sudo ~/sixpair"
echo "2. 拔下USB → 按手柄PS键"
echo "3. sudo bluetoothctl 完成配对"
echo "   输入：agent on"
echo "   输入：default-agent"
echo "   输入：trust 你的手柄MAC"
echo "   输入：connect 你的手柄MAC"
echo "   输入：exit"
echo "4. 重启树莓派：sudo reboot"
echo "5. 测试手柄：jstest /dev/input/js0"
echo "============================================="
