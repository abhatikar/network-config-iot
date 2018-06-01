#!/bin/sh
AP_SSID="${3}"
AP_PASSPHRASE="${4}"

# Install dependencies
sudo apt -y update
sudo apt -y upgrade
sudo apt -y install dnsmasq  hostapd iw

sudo systemctl disable hostapd
sudo systemctl disable dnsmasq

# Populate `/etc/wpa_supplicant/wpa_supplicant.conf`
sudo bash -c 'cat > /etc/systemd/system/autohotspot.service' << EOF
[Unit]
Description=Automatically generates an internet Hotspot when a valid ssid is not in range
After=multi-user.target
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/autohotspot
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable autohotspot.service

sudo cp autohotspot /usr/bin/autohotspot

sudo chmod +x /usr/bin/autohotspot


# Populate `/etc/dnsmasq.conf`
sudo bash -c 'cat > /etc/dnsmasq.conf' << EOF
#AutoHotspot Config
#stop DNSmasq from using resolv.conf
no-resolv
#Interface to use
interface=wlan0
bind-interfaces
dhcp-range=10.0.0.50,10.0.0.150,12h
EOF

# Populate `/etc/hostapd/hostapd.conf`
sudo bash -c 'cat > /etc/hostapd/hostapd.conf' << EOF
#2.4GHz setup wifi 80211 b,g,n
interface=wlan0
driver=nl80211
ssid=${AP_SSID}
hw_mode=g
channel=8
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=${AP_PASSPHRASE}
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP TKIP
rsn_pairwise=CCMP

#80211n - Change GB to your WiFi country code
country_code=GB
ieee80211n=1
ieee80211d=1
EOF

# Populate `/etc/default/hostapd`
sudo bash -c 'cat > /etc/default/hostapd' << EOF
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOF

# Populate `/etc/network/interfaces`
sudo bash -c 'cat > /etc/network/interfaces' << EOF
# interfaces(5) file used by ifup(8) and ifdown(8) 
# Please note that this file is written to be used with dhcpcd 
# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf' 
# Include files from /etc/network/interfaces.d: 
source-directory /etc/network/interfaces.d 
EOF

echo "Wifi AP configuration is finished! Please reboot your Raspberry Pi to apply changes..."
