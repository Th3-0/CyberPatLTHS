#!/bin/sh

# Firewall

#for allowing ports
read -ap "List ports/programs to allow through fire wall, [port/program1 port/program2]" portPass

if ! dpkg -l | grep -q 'ufw'; then
    echo "ufw was not found...installing"
    sudo apt install ufw -yq
fi

if sudo ufw status | grep -q 'inactive'; then
    echo "ufw is inactive...enabling"
    sudo ufw enable
fi

echo "turning on logging"
sudo ufw logging on

echo "allowing ports"
# sudo ufw allow `echo $@ | sed 's/ /,/g'`
# work on this on thursday
#(Theo here, this might work)
for (( i=0; i<${portPass[@]}; i++ ));
do
    sudo ufw allow ${portPass[i]}
done

#echo "use sudo ufw allow <port> to allow a port, i'll add this later"

if ! grep -q ipv6.disable=1 /etc/default/grub; then
    echo "disabling ipv6"
    sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"[^ ]*/& ipv6.disable=1/" /etc/default/grub
    sudo update-grub
fi

echo "updating sysctl config"

if grep -q '#net.ipv4.conf.default.rp_filter.*=.*1' /etc/sysctl.conf; then
    sudo sed -i '/net.ipv4.conf.default.rp_filter.*=.*1/s/^#//g' /etc/sysctl.conf
elif ! grep -q 'net.ipv4.conf.default.rp_filter.*=.*1' /etc/sysctl.conf; then
    sudo echo "net.ipv4.conf.default.rp_filter=1" | sudo tee -a /etc/sysctl.conf > /dev/null
fi

if grep -q '#net.ipv4.conf.all.rp_filter.*=.*1' /etc/sysctl.conf; then
    sudo sed -i '/net.ipv4.conf.all.rp_filter.*=.*1/s/^#//g' /etc/sysctl.conf
elif ! grep -q 'net.ipv4.conf.all.rp_filter.*=.*1' /etc/sysctl.conf; then
    sudo echo "net.ipv4.conf.all.rp_filter=1" | sudo tee -a /etc/sysctl.conf > /dev/null
fi

if grep -q '#net.ipv4.conf.all.accept_redirects.*=.*0' /etc/sysctl.conf; then
    sudo sed -i '/net.ipv4.conf.all.accept_redirects.*=.*0/s/^#//g' /etc/sysctl.conf
elif ! grep -q 'net.ipv4.conf.all.accept_redirects.*=.*0' /etc/sysctl.conf; then
    echo "net.ipv4.conf.all.accept_redirects=0" | sudo tee -a /etc/sysctl.conf > /dev/null
fi

if grep -q '#net.ipv4.conf.all.send_redirects.*=.*0' /etc/sysctl.conf; then
    sudo sed -i '/net.ipv4.conf.all.send_redirects.*=.*0/s/^#//g' /etc/sysctl.conf
elif ! grep -q 'net.ipv4.conf.all.send_redirects.*=.*0' /etc/sysctl.conf; then
    sudo echo "net.ipv4.conf.all.send_redirects=0" | sudo tee -a /etc/sysctl.conf > /dev/null
fi

if grep -q '#net.ipv4.conf.all.accept_source_route.*=.*0' /etc/sysctl.conf; then
    sudo sed -i '/net.ipv4.conf.all.accept_source_route.*=.*0/s/^#//g' /etc/sysctl.conf
elif ! grep -q 'net.ipv4.conf.all.accept_source_route.*=.*0' /etc/sysctl.conf; then
    sudo echo "net.ipv4.conf.all.accept_source_route=0" | sudo tee -a /etc/sysctl.conf > /dev/null
fi

if grep -q '#net.ipv4.conf.all.log_martians.*=.*1' /etc/sysctl.conf; then
    sudo sed -i '/net.ipv4.conf.all.log_martians.*=.*1/s/^#//g' /etc/sysctl.conf
elif ! grep -q 'net.ipv4.conf.all.log_martians.*=.*1' /etc/sysctl.conf; then
    sudo echo "net.ipv4.conf.all.log_martians=1" | sudo tee -a /etc/sysctl.conf  > /dev/null
fi

if grep -q -x '.*net.ipv4.ip_forward.*=.*0' /etc/sysctl.conf; then
    sudo sed -i '/.*net.ipv4.ip_forward.*=.*0/s/^/#/g' /etc/sysctl.conf
elif ! grep -q '.*net.ipv4.ip_forward.*=.*0' /etc/sysctl.conf; then
    sudo echo "net.ipv4.ip_forward=0" | sudo tee -a /etc/sysctl.conf  > /dev/null
fi

if grep -q '#net.ipv4.tcp_syncookies.*=.*1' /etc/sysctl.conf; then
    sudo sed -i '/net.ipv4.tcp_syncookies.*=.*1/s/^#//g' /etc/sysctl.conf
elif ! grep -q 'net.ipv4.tcp_syncookies.*=.*1' /etc/sysctl.conf; then
    sudo echo "net.ipv4.tcp_syncookies=1" | sudo tee -a /etc/sysctl.conf > /dev/null
fi

if grep -q 'net.ipv6.conf.all.disable_ipv6.*=.*1' /etc/sysctl.conf; then
    sudo sed -i '/net.ipv6.conf.all.disable_ipv6.*=.*1/s/^#//g' /etc/sysctl.conf
elif ! grep -q 'net.ipv6.conf.all.disable_ipv6.*=.*1' /etc/sysctl.conf; then
    sudo echo "net.ipv6.conf.all.disable_ipv6=1" | sudo tee -a /etc/sysctl.conf > /dev/null
fi

sudo sysctl -p > /dev/null


#do this on thursday
echo "Check /etc/hosts for suspicious lines"
