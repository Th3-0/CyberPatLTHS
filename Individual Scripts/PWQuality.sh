#!/bin/bash

sudo apt-get install libpam-pwquality
#/etc/login.defs
sudo sed -i "/SYSLOG_SU_ENAB/c\SYSLOG_SU_ENAB		yes" /etc/login.defs
sudo sed -i "/SYSLOG_SG_ENAB/c\SYSLOG_SG_ENAB		yes" /etc/login.defs
sudo sed -i "/PASS_MAX_DAYS/c\PASS_MAX_DAYS	90" /etc/login.defs
sudo sed -i "/PASS_MIN_DAYS/c\PASS_MIN_DAYS	10" /etc/login.defs
sudo sed -i "/PASS_WARN_AGE/c\PASS_WARN_AGE	14" /etc/login.defs
#/etc/pam.d/common-password
sudo sed -i "/pam_unix.so/c\password	[success=1 default=ignore]	pam_unix.so obscure use_authtok yescrypt d remember=5 minlen=8" /etc/pam.d/common-password
sudo sed -i "/requisite/c\requisite			pam_pwquality.so retry=3 minlen=8 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1" /usr/share/pam-configs
#/etc/pam.d/common-auth
sudo sed -i "/pam_tally2.so/c\auth    required                        pam_tally2.so deny=5 onerr=fail unlock_time=1800" /etc/pam.d/common-auth





