#!/bin/bash
# 一键选择并永久设置 DNS（支持 IPv4 / IPv6）
# 适用于 Debian / Ubuntu 系统

CONFIG_FILE="/etc/systemd/resolved.conf"
RESOLV_FILE="/etc/resolv.conf"

echo "====================================="
echo "🛰  DNS 设置工具（支持 IPv4 / IPv6）"
echo "====================================="
echo "1️⃣ 使用 IPv4: 8.8.8.8 (Google)"
echo "2️⃣ 使用 IPv4: 1.1.1.1 (Cloudflare)"
echo "3️⃣ 使用 IPv6: 2001:4860:4860::8888 (Google)"
echo "4️⃣ 使用 IPv6: 2606:4700:4700::1111 (Cloudflare)"
echo "5️⃣ 使用双栈: 8.8.8.8 + 2001:4860:4860::8888 (Google)"
echo "6️⃣ 使用双栈: 1.1.1.1 + 2606:4700:4700::1111 (Cloudflare)"
echo "7️⃣ 使用完整双栈: 1.1.1.1 + 8.8.8.8 + 2606:4700:4700::1111 + 2001:4860:4860::8888"
echo "8️⃣ 使用完整双栈（反向顺序）: 8.8.8.8 + 1.1.1.1 + 2001:4860:4860::8888 + 2606:4700:4700::1111"
echo "-------------------------------------"
read -p "请输入选项 (1-8): " choice

case $choice in
  1)
    DNS="8.8.8.8"
    ;;
  2)
    DNS="1.1.1.1"
    ;;
  3)
    DNS="2001:4860:4860::8888"
    ;;
  4)
    DNS="2606:4700:4700::1111"
    ;;
  5)
    DNS="8.8.8.8 2001:4860:4860::8888"
    ;;
  6)
    DNS="1.1.1.1 2606:4700:4700::1111"
    ;;
  7)
    DNS="1.1.1.1 8.8.8.8 2606:4700:4700::1111 2001:4860:4860::8888"
    ;;
  8)
    DNS="8.8.8.8 1.1.1.1 2001:4860:4860::8888 2606:4700:4700::1111"
    ;;
  *)
    echo "❌ 无效输入，退出。"
    exit 1
    ;;
esac

echo "🔧 正在设置 DNS 为: $DNS"

# 禁用 systemd-resolved，防止自动改写
if systemctl list-units | grep -q systemd-resolved.service; then
  sudo systemctl stop systemd-resolved.service
  sudo systemctl disable systemd-resolved.service
fi

# 备份旧配置
sudo cp -f /etc/resolv.conf /etc/resolv.conf.bak 2>/dev/null

# 写入新DNS
sudo bash -c "cat > /etc/resolv.conf <<EOF
# 自定义DNS设置
$(for i in $DNS; do echo "nameserver $i"; done)
EOF"

# 锁定文件防止被覆盖
sudo chattr +i /etc/resolv.conf

echo "✅ DNS 已修改并锁定。"
echo "🧩 当前 DNS 设置如下："
cat /etc/resolv.conf
echo "-------------------------------------"
echo "如需修改，可先解锁:"
echo "sudo chattr -i /etc/resolv.conf"
echo "再重新运行本脚本修改。"
echo "-------------------------------------"
