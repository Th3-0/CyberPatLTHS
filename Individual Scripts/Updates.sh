#!/bin/bash
#UPDATES

updateType=("focal" "focal-updates" "focal-security" "focal-backports")
debType=("deb" "deb-src")
for (( i=0; i<${#updateType[@]}; i++ ));
do
    if grep -iq "deb http://us.archive.ubuntu.com/ubuntu/ ${updateType[i]}" /etc/apt/sources.list
    then
        sudo sed -i "/deb http:\/\/us.archive.ubuntu.com\/ubuntu\/ ${updateType[i]}/c\deb http:\/\/archive.ubuntu.com\/ubuntu\/ ${updateType[i]} main restricted universe" /etc/apt/sources.list
    else
        echo "deb http://us.archive.ubuntu.com/ubuntu/ ${updateType[i]} main restricted universe" >> /etc/apt/sources.list
    fi
done
for (( i=0; i<${#debType[@]}; i++ ));
do
    if grep -iq "${debType[i]} http://archive.canonical.com/ubuntu focal" /etc/apt/sources.list
    then
        sudo sed -i "/${debType[i]} http:\/\/archive.canonical.com\/ubuntu focal/c\ ${debType[i]} http:\/\/archive.canonical.com\/ubuntu focal partner" /etc/apt/sources.list
    else
        echo "${debType[i]} http://archive.canonical.com/ubuntu focal partner" >> /etc/apt/sources.list
    fi
done








#focal
if grep -iq "deb http://us.archive.ubuntu.com/ubuntu/ focal" /etc/apt/sources.list
then
    sudo sed -i '/deb http:\/\/us.archive.ubuntu.com\/ubuntu\/ focal/c\deb http:\/\/archive.ubuntu.com\/ubuntu\/ focal main restricted universe' /etc/apt/sources.list
else
    echo "deb http://us.archive.ubuntu.com/ubuntu/ focal main restricted universe" >> /etc/apt/sources.list
fi

#focal-updates
if grep -iq "deb http://us.archive.ubuntu.com/ubuntu/ focal-updates" /etc/apt/sources.list
then
    sudo sed -i '/deb http:\/\/us.archive.ubuntu.com\/ubuntu\/ focal-updates/c\deb http:\/\/archive.ubuntu.com\/ubuntu\/ focal-updates main restricted universe' /etc/apt/sources.list
else
    echo "deb http://us.archive.ubuntu.com/ubuntu/ focal-updates main restricted universe" >> /etc/apt/sources.list
fi

#focal-security
if grep -iq "deb http://us.archive.ubuntu.com/ubuntu focal-security" /etc/apt/sources.list
then
    sudo sed -i '/deb http:\/\/us.archive.ubuntu.com\/ubuntu focal-security/c\deb http:\/\/archive.ubuntu.com\/ubuntu focal-security main restricted universe' /etc/apt/sources.list
else
    echo "deb http://us.archive.ubuntu.com/ubuntu focal-security main restricted universe" >> /etc/apt/sources.list
fi

#focal-backports
if grep -iq "deb http://us.archive.ubuntu.com/ubuntu/ focal-backports" /etc/apt/sources.list
then
    sudo sed -i '/deb http:\/\/us.archive.ubuntu.com\/ubuntu\/ focal-backports/c\deb http:\/\/archive.ubuntu.com\/ubuntu\/ focal-backports main restricted universe' /etc/apt/sources.list
else
    echo "deb http://us.archive.ubuntu.com/ubuntu/ focal-backports main restricted universe" >> /etc/apt/sources.list
fi


#canonical Partner
if grep -iq "deb http://archive.canonical.com/ubuntu focal" /etc/apt/sources.list
then
    sudo sed -i '/deb http:\/\/archive.canonical.com\/ubuntu focal/c\deb http:\/\/archive.canonical.com\/ubuntu focal partner' /etc/apt/sources.list
else
    echo "deb http://archive.canonical.com/ubuntu focal partner" >> /etc/apt/sources.list
fi

if grep -iq "deb-src http://archive.canonical.com/ubuntu focal" /etc/apt/sources.list
then
    sudo sed -i '/deb-src http:\/\/archive.canonical.com\/ubuntu focal/c\deb-src http:\/\/archive.canonical.com\/ubuntu focal partner' /etc/apt/sources.list
else
    echo "deb-src http://archive.canonical.com/ubuntu focal partner" >> /etc/apt/sources.list
fi

sudo sed -i '/Prompt/c\Prompt=lts' /etc/update-manager/release-upgrades
sudo sed -i '/APT::Periodic::Update-Package-Lists/c\APT::Periodic::Update-Package-Lists "1";' /etc/apt/apt.conf.d/*auto-upgrades /etc/apt/apt.conf.d/*periodic
sudo sed -i '/APT::Periodic::Download-Upgradeable-Packages/c\APT::Periodic::Download-Upgradeable-Packages "1";' /etc/apt/apt.conf.d/*auto-upgrades /etc/apt/apt.conf.d/*periodic
sudo sed -i '/APT::Periodic::AutocleanInterval/c\APT::Periodic::AutocleanInterval "14";' /etc/apt/apt.conf.d/*auto-upgrades /etc/apt/apt.conf.d/*periodic
sudo sed -i '/APT::Periodic::Unattended-Upgrade/c\APT::Periodic::Unattended-Upgrade "1";' /etc/apt/apt.conf.d/*auto-upgrades /etc/apt/apt.conf.d/*periodic




sudo apt-get install unattended-upgrades -yq
sudo systemctl start unattended-upgrades -yq
sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq 
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq 
sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -yq 