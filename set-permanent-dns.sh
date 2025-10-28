#!/bin/bash
echo "========================================="
echo "🔧 VPS DNS 永久设置工具"
echo "-----------------------------------------"
echo "1️⃣ 仅使用 IPv4 DNS (1.1.1.1 / 8.8.8.8)"
echo "2️⃣ 仅使用 IPv6 DNS (2001:4860:4860::8888 / 2001:4860:4860::8844)"
echo "3️⃣ 同时使用 IPv4 + IPv6 DNS (推荐)"
echo "-----------------------------------------"
read -p "请选择 [1-3]: " choice

case "$choice" in
  1)
    DNS_CONTENT="nameserver 1.1.1.1\nnameserver 8.8.8.8"
    ;;
  2)
    DNS_CONTENT="nameserver 2001:4860:4860::8888\nnameserver 2001:4860:4860::8844"
    ;;
  3)
    DNS_CONTENT="nameserver 1.1.1.1\nnameserver 8.8.8.8\nnameserver 2001:4860:4860::8888\nnameserver 2001:4860:4860::8844"
    ;;
  *)
    echo "❌ 无效选择，退出。"
    exit 1
    ;;
esac

echo -e "\n🛠️ 正在设置 DNS ..."
echo -e "$DNS_CONTENT" > /etc/resolv.conf

# 修改 DHCP 设置以防止覆盖
if [ -f /etc/dhcp/dhclient.conf ]; then
  echo "" >> /etc/dhcp/dhclient.conf
  echo "# Added by DNS script" >> /etc/dhcp/dhclient.conf
  echo "supersede domain-name-servers $(echo -e $DNS_CONTENT | awk '{printf "%s, ", $2}' | sed 's/, $//');" >> /etc/dhcp/dhclient.conf
fi

# 锁定 resolv.conf 防止系统还原
chattr +i /etc/resolv.conf 2>/dev/null

# 重启网络服务（兼容各种系统）
systemctl restart networking 2>/dev/null || service networking restart 2>/dev/null

echo "✅ DNS 已设置为："
echo -e "$DNS_CONTENT"
echo "🔒 /etc/resolv.conf 已锁定，重启后仍然生效。"
echo "-----------------------------------------"
echo "如需修改，请执行："
echo "  chattr -i /etc/resolv.conf"
echo "  nano /etc/resolv.conf"
echo "-----------------------------------------"
