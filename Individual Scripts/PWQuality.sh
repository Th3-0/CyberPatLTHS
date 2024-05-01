#!/bin/bash

sudo apt-get install libpam-pwquality
#/etc/login.defs
sudo sed -i "/SYSLOG_SU_ENAB/cSYSLOG_SU_ENAB		yes" /etc/login.defs
sudo sed -i "/SYSLOG_SG_ENAB/cSYSLOG_SG_ENAB		yes" /etc/login.defs
sudo sed -i "/PASS_MAX_DAYS/cPASS_MAX_DAYS	90" /etc/login.defs
sudo sed -i "/PASS_MIN_DAYS/cPASS_MIN_DAYS	10" /etc/login.defs
sudo sed -i "/PASS_WARN_AGE/cPASS_WARN_AGE	14" /etc/login.defs
#/etc/pam.d/common-password
sudo sed -i '/Password:/!b;n;crequisite			pam_pwquality.so retry=3 minlen=8 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1 reject_username' /usr/share/pam-configs/pwquality
sudo sed -i '/Password-Initial:/!b;n;crequisite			pam_pwquality.so retry=3 minlen=8 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1 reject_username' /usr/share/pam-configs/pwquality
#/etc/pam.d/common-auth
sudo sed -i '/Password:/!b;n;c\        [success=1 default=ignore]    pam_unix.so obscure use_authtok yescrypt d remember=5 minlen=8' /usr/share/pam-configs/unix
sudo sed -i '/Password-Initial:/!b;n;c\        [success=1 default=ignore]    pam_unix.so obscure use_authtok yescrypt d remember=5 minlen=8' /usr/share/pam-configs/unix
sudo pam-auth-update --package --force
#/etc/security/faillock.conf
sudo sed -i "/unlock_time = /c\  unlock_time = 1800" /etc/security/faillock.conf
sudo sed -i "/deny = /c\  deny = 5" /etc/security/faillock.conf


