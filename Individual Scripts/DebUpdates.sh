#!/bin/bash
#UPDATES
sudo apt-get install unattended-upgrades -yq
sudo systemctl start unattended-upgrades
sudo systemctl enable unattended-upgrades

debType=("deb" "deb-src")
configType=('Update-Package-Lists "1"' 'Download-Upgradeable-Packages "1"' 'AutocleanInterval "14"' 'Unattended-Upgrade "1"' 'Verbose "1"')
for (( i=0; i<${#debType[@]}; i++ ));
do
    if grep -iq "${debType[i]} http://deb.debian.org/debian/ bullseye " /etc/apt/sources.list
    then
        sudo sed -i "/${debType[i]} http:\/\/deb.debian.org\/debian\/ bullseye /c${debType[i]} http:\/\/deb.debian.org\/debian\/ bullseye main" /etc/apt/sources.list
    else
        echo "${debType[i]} http://deb.debian.org/debian/ bullseye main" >> /etc/apt/sources.list
    fi

    if grep -iq "${debType[i]} http://deb.debian.org/debian/ bullseye-updates " /etc/apt/sources.list
    then
        sudo sed -i "/${debType[i]} http:\/\/deb.debian.org\/debian\/ bullseye-updates /c${debType[i]} http:\/\/deb.debian.org\/debian\/ bullseye-updates main" /etc/apt/sources.list
    else
        echo "${debType[i]} http://deb.debian.org/debian/ bullseye-updates main" >> /etc/apt/sources.list
    fi

     if grep -iq "${debType[i]} http://security.debian.org/debian-security bullseye-security " /etc/apt/sources.list
    then
        sudo sed -i "/${debType[i]} http:\/\/security.debian.org\/debian-security bullseye-security /c${debType[i]} http:\/\/security.debian.org\/debian-security bullseye-security main" /etc/apt/sources.list
    else
        echo "${debType[i]} http://security.debian.org/debian-security bullseye-security main" >> /etc/apt/sources.list
    fi

done



for (( i=0; i<${#configType[@]}; i++ ));
do
    if grep -iq "APT::Periodic::${configType[i]}" /etc/apt/apt.conf.d/*unattended-upgrades
    then
        sed -i "/APT::Periodic::${configType[i]}/c\APT::Periodic::${configType[i]};" /etc/apt/apt.conf.d/*unattended-upgrades
    else
        echo "APT::Periodic::${configType[i]};" >> /etc/apt/apt.conf.d/*unattended-upgrades
    fi
done
for (( i=0; i<${#configType[@]}; i++ ));
do
    if grep -iq "APT::Periodic::AutocleanInterval" /etc/apt/apt.conf.d/*unattended-upgrades
    then
        sed -i '/APT::Periodic::AutocleanInterval/c\APT::Periodic::AutocleanInterval "14";' /etc/apt/apt.conf.d/*unattended-upgrades
    else
        echo 'APT::Periodic::AutocleanInterval "14";' >> /etc/apt/apt.conf.d/*unattended-upgrades
    fi
done

sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq
sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -yq

echo "UPDATES COMPLETE"