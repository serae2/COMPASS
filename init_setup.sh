sudo ip link set dev aerial00 mtu 9216
sudo ethtool -G aerial00 rx 8192 tx 8192 # increase rx/tx queue size

# make vlan interface
sudo ip link add link aerial00 name aerial00.3 type vlan id 3 # make it permenant, not needed to be re-created after reboot
sudo ip link set dev aerial00.3 mtu 9216
sudo ip link set dev aerial00.3 up

echo "Setup internet connection"
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -s 10.45.0.0/16 -o enx00e04c2f24b8 -j MASQUERADE
sudo iptables -A FORWARD -i ogstun -o enx00e04c2f24b8 -j ACCEPT
sudo iptables -A FORWARD -i enx00e04c2f24b8 -o ogstun -m state --state RELATED,ESTABLISHED -j ACCEPT

# setup iptables for DPU to access internet
EXT_IF=enx00e04c2f24b8

sudo iptables -t nat -A POSTROUTING -s 192.168.100.2/32 -o "$EXT_IF" -j MASQUERADE
sudo iptables -A FORWARD -i tmfifo_net0 -o "$EXT_IF" -j ACCEPT
sudo iptables -A FORWARD -i "$EXT_IF" -o tmfifo_net0 -m state --state RELATED,ESTABLISHED -j ACCEPT
# In addition....at DPU side, add 8.8.8.8 for DNS server, as like...
# sudo bash -c 'cat > /etc/resolv.conf <<EOF
# nameserver 8.8.8.8
# nameserver 1.1.1.1
# EOF'