#!/bin/bash
RED='\033[0;31m'
NC='\033[0m' # No Color
(( EUID != 0 )) && exec sudo -- "$0" "$@"
read -r -p "This will install SoftEther to your server. Are you sure you want to continue? [y/N] " response
case $response in
[yY][eE][sS]|[yY])
echo "Updating the system first..."
sudo apt update && apt upgrade -y && apt install checkinstall build-essential -y
echo "Downloading last stable release: 4.27"
sleep 2
sudo wget  -O softether-vpn-4.27.tar.gz http://www.softether-download.com/files/softether/v4.27-9668-beta-2018.05.29-tree/Linux/SoftEther_VPN_Server/64bit_-_Intel_x64_or_AMD64/softether-vpnserver-v4.27-9668-beta-2018.05.29-linux-x64-64bit.tar.gz
sleep 12
sudo tar -xzf softether-vpn-4.27.tar.gz
sleep 2
sudo cd vpnserver
echo -e "${RED}Please press 1 for all the following questions.${NC}"
sleep 2
make
cd ..
sudo mv vpnserver /usr/local/
sudo chmod 600 /usr/local/vpnserver/*
sudo chmod 700 /usr/local/vpnserver/vpncmd
sudo chmod 700 /usr/local/vpnserver/vpnserver
echo '#!/bin/sh
# description: SoftEther VPN Server
### BEGIN INIT INFO
# Provides:          vpnserver
# Required-Start:    $local_fs $network
# Required-Stop:     $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: softether vpnserver
# Description:       softether vpnserver daemon
### END INIT INFO
DAEMON=/usr/local/vpnserver/vpnserver
LOCK=/var/lock/subsys/vpnserver
test -x $DAEMON || exit 0
case "$1" in
start)
$DAEMON start
touch $LOCK
;;
stop)
$DAEMON stop
rm $LOCK
;;
restart)
$DAEMON stop
sleep 3
$DAEMON start
;;
*)
echo "Usage: $0 {start|stop|restart}"
exit 1
esac
exit 0' > /etc/init.d/vpnserver
echo "System daemon created. Registering changes..."
sleep 2
sudo chmod 755 /etc/init.d/vpnserver
sudo /etc/init.d/vpnserver start
sudo update-rc.d vpnserver defaults
sleep 1
echo -e "${RED}SoftEther VPN Server should now start as a system service from now on. To check status type 'systemctl status vpnserver'${NC}"
systemctl start vpnserver
esac
