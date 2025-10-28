#!/bin/bash
echo "========================================="
echo "🌐 VPS 永久 DNS 设置工具"
echo "-----------------------------------------"
echo "请选择想使用的 DNS 服务:"
echo "1️⃣ Google (8.8.8.8 / 2001:4860:4860::8888)"
echo "2️⃣ Cloudflare (1.1.1.1 / 2606:4700:4700::1111)"
echo "3️⃣ Quad9 (9.9.9.9 / 2620:fe::fe)"
echo "4️⃣ AdGuard (94.140.14.14 / 2a10:50c0::ad1:ff)"
echo "5️⃣ 自定义 DNS"
echo "-----------------------------------------"
read -p "请选择 [1-5]: " dns_choice

# 定义常用 DNS
case "$dns_choice" in
  1)
    ipv4_list="8.8.8.8 8.8.4.4"
    ipv6_list="2001:4860:4860::8888 2001:4860:4860::8844"
    dns_name="Google"
    ;;
  2)
    ipv4_list="1.1.1.1 1.0.0.1"
    ipv6_list="2606:4700:4700::1111 2606:4700:4700::1001"
    dns_name="Cloudflare"
    ;;
  3)
    ipv4_list="9.9.9.9 149.112.112.112"
    ipv6_list="2620:fe::fe 2620:fe::9"
    dns_name="Quad9"
    ;;
  4)
    ipv4_list="94.140.14.14 94.140.15.15"
    ipv6_list="2a10:50c0::ad1:ff 2a10:50c0::ad2:ff"
    dns_name="AdGuard"
    ;;
  5)
    read -p "请输入自定义 IPv4 DNS（可留空，多项用空格分隔）: " ipv4_list
    read -p "请输入自定义 IPv6 DNS（可留空，多项用空格分隔）: " ipv6_list
    dns_name="自定义"
    ;;
  *)
    echo "❌ 无效选择，退出。"
    exit 1
    ;;
esac

echo "-----------------------------------------"
echo "你想使用哪些协议的 DNS？"
echo "1️⃣ 仅 IPv4"
echo "2️⃣ 仅 IPv6"
echo "3️⃣ IPv4 + IPv6（推荐）"
read -p "请选择 [1-3]: " proto_choice

case "$proto_choice" in
  1) final_list=$ipv4_list ;;
  2) final_list=$ipv6_list ;;
  3) final_list="$ipv4_list $ipv6_list" ;;
  *) echo "❌ 无效选择，退出。"; exit 1 ;;
esac

if [ -z "$final_list" ]; then
  echo "❌ 没有输入任何 DNS 地址，退出。"
  exit 1
fi

# 构建 resolv.conf 内容
DNS_CONTENT=""
for dns in $final_list; do
  DNS_CONTENT+="nameserver $dns\n"
done

echo -e "\n🛠️ 正在设置 $dns_name DNS ..."
echo -e "$DNS_CONTENT" > /etc/resolv.conf

# 禁止 DHCP 改写
if [ -f /etc/dhcp/dhclient.conf ]; then
  echo "" >> /etc/dhcp/dhclient.conf
  echo "# Added by DNS script" >> /etc/dhcp/dhclient.conf
  echo "supersede domain-name-servers $(echo $final_list | sed 's/ /, /g');" >> /etc/dhcp/dhclient.conf
fi

# 锁定文件
chattr +i /etc/resolv.conf 2>/dev/null

# 重启网络
systemctl restart networking 2>/dev/null || service networking restart 2>/dev/null

echo "✅ DNS 已成功设置为 $dns_name："
echo -e "$DNS_CONTENT"
echo "-----------------------------------------"
echo "🔒 /etc/resolv.conf 已锁定防修改，重启后仍生效。"
echo "如需修改，请执行："
echo "  chattr -i /etc/resolv.conf"
echo "  nano /etc/resolv.conf"
echo "-----------------------------------------"
