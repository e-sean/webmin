
#!/bin/bash

any_key() {
    local PROMPT="$1"
    read -r -p "$(printf "${Green}${PROMPT}${Color_Off}")" -n1 -s
    echo
}

clear
echo "+----------------------------------------------------------------+"
echo "| This script will install Webmin Panel on your Ubuntu Server    |"
echo "|                                                                |"
echo "| ####################### e-sean - 2017 #######################  |"
echo "+----------------------------------------------------------------+"
any_key "Press any key to start the script..."

mkdir webmin_tmp
cd webmin_tmp

sudo apt-get update -y  > /dev/null
sudo apt-get install wget -y > /dev/null
wget -q --show-progress https://raw.githubusercontent.com/e-sean/webmin/master/spinner.sh

source "$(pwd)/spinner.sh"


start_spinner 'Pulling dependencies'
sudo apt-get install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python apt-transport-https -y > /dev/null
stop_spinner $?

start_spinner 'Fetching latest Webmin'
wget -q --show-progress https://prdownloads.sourceforge.net/webadmin/webmin_1.881_all.deb
stop_spinner $?

##adding keys##
start_spinner 'Adding PGP keys'
wget -q --show-progress http://www.webmin.com/jcameron-key.asc
apt-key add jcameron-key.asc
rm -rf jcameron*
stop_spinner $?


##Installing webmin##
start_spinner 'Installing Webmin'
dpkg --install webmin_1.881_all.deb > /dev/null
rm -rf webmin_1.881_all.deb
stop_spinner $?

start_spinner 'Starting services'
systemctl enable webmin
systemctl start webmin
stop_spinner $?

start_spinner 'Configuring firewall'
ufw allow 10000
ufw reload
stop_spinner $?


start_spinner 'Cleaning up'
cd ..
rm -rf webmin_tmp
stop_spinner $?

##Finale##
OS=`uname`
IO="" # store IP
case $OS in
   Linux) IP=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`;;
   *) IP="Unknown";;
esac

echo "-Webmin install complete. You can now login to https://$IP:10000/ as root with your root password, or as any user who can use sudo to run commands as root."







