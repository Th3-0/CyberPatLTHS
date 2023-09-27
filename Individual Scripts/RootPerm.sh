#!/bin/bash

#disable root
sudo passwd -l root
echo "root account disabled"

#check for NOPASSWD or !authenticate
if grep -q 'NOPASSWD\|!authenticate' /etc/sudoers ;
then
    echo "instances of NOPASSWD or !authenticate found please check /etc/sudoers"
else
    echo "no instances of NOPASSWD or !authenticate found"
fi

#shadow permissions
sudo chmod 000 /etc/shadow
echo "/etc/shadow permissions changed"