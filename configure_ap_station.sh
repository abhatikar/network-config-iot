#!/bin/sh
MAC_ADDRESS="$(cat /sys/class/net/wlan0/address)"
CLIENT_SSID="${1}"
CLIENT_PASSPHRASE="${2}"
AP_SSID="${3}"
AP_PASSPHRASE="${4}"
COUNTRY=GB

# Install dependencies
sudo apt -y update
sudo apt -y upgrade
sudo apt -y install dnsmasq  hostapd

# Populate `/etc/udev/rules.d/70-persistent-net.rules`
sudo bash -c 'cat > /etc/udev/rules.d/90-wireless.rules' << EOF
ACTION=="add", SUBSYSTEM=="ieee80211", KERNEL=="phy0", \
	    RUN+="/sbin/iw phy %k interface add uap0 type __ap"ACTION=="add", SUBSYSTEM=="ieee8021
EOF
#sudo /sbin/iw phy phy0 interface add uap0 type __ap

# Populate `/etc/wpa_supplicant/wpa_supplicant.conf`
sudo bash -c 'cat > /etc/wpa_supplicant/wpa_supplicant.conf' << EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
country=${COUNTRY}
update_config=1

network={
    ssid="${CLIENT_SSID}"
    psk="${CLIENT_PASSPHRASE}"
    id_str="AP1"
    key_mgmt=WPA-PSK
    scan_ssid=1
}
EOF

# Populate `/etc/dnsmasq.conf`
sudo bash -c 'cat > /etc/dnsmasq.conf' << EOF
interface=lo,uap0
no-dhcp-interface=lo,wlan0
bind-interfaces
server=8.8.8.8
dhcp-range=10.3.141.50,10.3.141.255,12h
EOF

# Populate `/etc/hostapd/hostapd.conf`
sudo bash -c 'cat > /etc/hostapd/hostapd.conf' << EOF
interface=uap0
ssid=${AP_SSID}
hw_mode=g
channel=6
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=${AP_PASSPHRASE}
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

# Populate `/etc/default/hostapd`
sudo bash -c 'cat > /etc/default/hostapd' << EOF
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOF

# Populate `/etc/network/interfaces`
sudo bash -c 'cat > /etc/network/interfaces' << EOF
source-directory /etc/network/interfaces.d

auto lo
iface lo inet loopback

iface eth0 inet manual

allow-hotplug wlan0
iface wlan0 inet manual
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf

allow-hotplug uap0
auto uap0
iface uap0 inet static
    address 10.3.141.1
    netmask 255.255.255.0
EOF

# Populate `/bin/start_wifi.sh`
sudo bash -c 'cat > /bin/start_wifi.sh' << EOF
#echo 'Starting Wifi AP and client...'
#sleep 30
sudo pkill wpa_supplicant
sleep 5
sudo pkill dhclient
sleep 5
sudo /sbin/wpa_supplicant  -i wlan0 -D nl80211,wext -c /etc/wpa_supplicant/wpa_supplicant.conf -B 
sleep 5
sudo dhclient wlan0
sleep 5

#sudo sysctl -w net.ipv4.ip_forward=1
#sudo iptables -t nat -A POSTROUTING -s 192.168.10.0/24 ! -d 192.168.10.0/24 -j MASQUERADE
#sudo systemctl restart dnsmasq
EOF
sudo chmod +x /bin/start_wifi.sh
crontab -l | { cat; echo "@reboot /bin/start_wifi.sh"; } | crontab -
echo "Wifi configuration is finished! Please reboot your Raspberry Pi to apply changes..."
