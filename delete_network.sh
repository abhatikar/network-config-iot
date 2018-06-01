SSID_TO_DELETE=$1
SSID_PSK=$2
    sed -n "1 !H
       1 h
       $ {
         x
         s/[[:space:]]*network={\n[[:space:]]*ssid=\"${SSID_TO_DELETE}\"[^}]*}//g
         p
         }" wpa_supplicant.conf > wpa_supplicant.conf.1

wpa_passphrase $SSID_TO_DELETE $SSID_PSK >> wpa_supplicant.conf.1

mv wpa_supplicant.conf.1 wpa_supplicant.conf
