For network configuration / management the NetworkManager is used.

On the command line nmcli can be used for configuration: https://developer.gnome.org/NetworkManager/stable/nmcli.html
Below are a few examples:

### DHCP

    sudo nmcli con mod "con-eth0" ipv4.addresses "" ipv4.gateway "" ipv4.dns "" ipv4.dns-search "" ipv4.method "auto"
    sudo nmcli con up "con-eth0"

### Static IP with gateway

    sudo nmcli con mod "con-eth0" ipv4.addresses "192.168.101.160/24" ipv4.gateway "192.168.101.200" ipv4.dns "192.168.101.200" ipv4.dns-search "" ipv4.method "manual"
    sudo nmcli con up "con-eth0"

### Static IP without gateway

    sudo nmcli con mod "con-eth0" ipv4.addresses "192.168.101.160/24" ipv4.gateway "" ipv4.dns "" ipv4.dns-search "" ipv4.method "manual"
    sudo nmcli con up "con-eth0"

