#!/usr/bin/env sh

if [ "$(uname)" == "Darwin" ]; then
	echo "本驱动未适配Mac OS!"
	exit 0
fi

FOLDER=$(dirname $(realpath "$0"))
cd $FOLDER

# 安装PS3原生手柄依赖
sudo apt update
sudo apt install -y python3-pygame
sudo pip3 install pygame

# 配置手柄/蓝牙权限（必须）
sudo usermod -aG input pi
sudo usermod -aG bluetooth pi

# 安装项目本体
sudo python3 setup.py clean --all install

# 注册服务
for file in *.service; do
	[ -f "$file" ] || break
	sudo ln -sf $FOLDER/$file /lib/systemd/system/
done

sudo systemctl daemon-reload
