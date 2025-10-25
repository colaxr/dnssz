#!/bin/bash
echo "正在设置永久DNS为 8.8.8.8 ..."

# 禁止DHCP改DNS
if [ -f /etc/dhcp/dhclient.conf ]; then
  grep -q "supersede domain-name-servers" /etc/dhcp/dhclient.conf || \
  echo "supersede domain-name-servers 8.8.8.8;" >> /etc/dhcp/dhclient.conf
fi

# 写入 resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# 锁定文件防止被覆盖
chattr +i /etc/resolv.conf

# 重启网络服务
systemctl restart networking 2>/dev/null || service networking restart 2>/dev/null

echo "✅ 已完成设置，重启后仍然生效。"
