#!/bin/bash
echo "========================================="
echo "🔧 VPS 永久自定义 DNS 设置工具"
echo "-----------------------------------------"
echo "1️⃣ 设置 IPv4 DNS"
echo "2️⃣ 设置 IPv6 DNS"
echo "3️⃣ 同时设置 IPv4 + IPv6 DNS"
echo "-----------------------------------------"
read -p "请选择 [1-3]: " mode

# 用户输入部分
case "$mode" in
  1)
    echo "请输入要使用的 IPv4 DNS（用空格分隔多个，例如: 1.1.1.1 8.8.8.8）"
    read -p "IPv4 DNS: " ipv4_dns
    ;;
  2)
    echo "请输入要使用的 IPv6 DNS（用空格分隔多个，例如: 2001:4860:4860::8888 2001:4860:4860::8844）"
    read -p "IPv6 DNS: " ipv6_dns
    ;;
  3)
    echo "请输入要使用的 IPv4 DNS（例如: 1.1.1.1 8.8.8.8）"
    read -p "IPv4 DNS: " ipv4_dns
    echo "请输入要使用的 IPv6 DNS（例如: 2001:4860:4860::8888 2001:4860:4860::8844）"
    read -p "IPv6 DNS: " ipv6_dns
    ;;
  *)
    echo "❌ 无效选择，退出。"
    exit 1
    ;;
esac

# 构建 resolv.conf 内容
DNS_CONTENT=""
for dns in $ipv4_dns $ipv6_dns; do
  DNS_CONTENT+="nameserver $dns\n"
done

if [ -z "$DNS_CONTENT" ]; then
  echo "❌ 未输入任何 DNS，退出。"
  exit 1
fi

# 写入 resolv.conf
echo -e "\n🛠️ 正在设置 DNS ..."
echo -e "$DNS_CONTENT" > /etc/resolv.conf

# 修改 DHCP 设置以防止覆盖
if [ -f /etc/dhcp/dhclient.conf ]; then
  echo "" >> /etc/dhcp/dhclient.conf
  echo "# Added by DNS script" >> /etc/dhcp/dhclient.conf
  echo "supersede domain-name-servers $(echo -e $DNS_CONTENT | awk '{printf "%s, ", $2}' | sed 's/, $//');" >> /etc/dhcp/dhclient.conf
fi

# 锁定 resolv.conf 防止被覆盖
chattr +i /etc/resolv.conf 2>/dev/null

# 重启网络服务
systemctl restart networking 2>/dev/null || service networking restart 2>/dev/null

echo "✅ DNS 已成功设置为："
echo -e "$DNS_CONTENT"
echo "-----------------------------------------"
echo "🔒 /etc/resolv.conf 已锁定防修改，重启后仍生效。"
echo "如需修改，请执行："
echo "  chattr -i /etc/resolv.conf"
echo "  nano /etc/resolv.conf"
echo "-----------------------------------------"
