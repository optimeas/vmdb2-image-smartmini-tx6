# Modem Management

For network configuration / management the NetworkManager is used.

The modem on the smartMINI/smartRAIL is not switched on during booting. It can be switched on via GPIO.

A Python script exists for this purpose:

    sudo boardctl modem on
    sudo boardctl modem off

To control the power on of the modem at boot time you can enable or disable the systemd unit:

    sudo systemctl disable modem-power-on.service

The network connection of the modem is managed under the NetworkManager connection "con-modem". The connection is disabled per default but if you want to try to establish a connection use the command:

    sudo nmcli con up "con-modem"

The connection can be modified via the cli. For example to change the apn you can do the following:

    sudo nmcli con modify "con-modem" gsm.apn "web.vodafone.de"

If you want NetworkManager to try to activate the connection after NetworkManger has detected that a connection can be established (e.g. at boot time or after connection losses), set the autoconnect property of your connection to true:

    sudo nmcli c mod "con-modem" connection.autoconnect 1

To disable autoconnect simply replace the `1` with a `0` in the above command.

The modem status can be displayed via mmcli:

    sudo mmcli -m /org/freedesktop/ModemManager1/Modem/0 --location-get
    sudo mmcli -m /org/freedesktop/ModemManager1/Modem/0 --location-status
