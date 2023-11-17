#!/bin/bash
echo "========================================"
echo "██████╗░██╗░░░░░███████╗███████╗██████╗░"
echo "██╔══██╗██║░░░░░██╔════╝██╔════╝██╔══██╗"
echo "██████╦╝██║░░░░░█████╗░░█████╗░░██████╔╝"
echo "██╔══██╗██║░░░░░██╔══╝░░██╔══╝░░██╔═══╝░"
echo "██████╦╝███████╗███████╗███████╗██║░░░░░"
echo "╚═════╝░╚══════╝╚══════╝╚══════╝╚═╝░░░░░"
echo "========================================"
echo "      SCRIPT MUST BE RAN AS ROOT"
echo "========================================"

echo "========================================"
echo "Download readme html and make name short
echo "========================================"
read -p "Readme Path: " path

Users() {
    echo "================================================================" 
    echo "                     PASSWORDS AND USERS                               "
    echo "     output for this is stored in separate UserChangeLog file"
    echo "================================================================"
    CurrentUser=$(whoami)
    sudo apt install members -yq
    if [ $CurrentUser != "root" ]
    then
        echo "============================================"
        echo "   THIS MUST SCRIPT MUST BE RUN WITH SUDO"
        echo "============================================"
        exit
    fi
    echo "========================================================================================="
    echo "   THIS SCRIPT WILL PERMANANTLY MODIFY USERS. IF YOU DO NOT WISH TO CONTINUE EXIT NOW."
    echo "========================================================================================="

    updateUserDefs() {
    mapfile -t AllCurrentUsers < <(getent passwd {1000..1500} | cut -d: -f1) 
    mapfile -t CurrentAdminUsers < <(members sudo)
    mapfile -t CurrentNormUsers < <(echo ${AllCurrentUsers[@]} ${CurrentAdminUsers[@]} | tr ' ' '\n' | sort | uniq -u)
    }
    updateUserDefs
    CurrentAdminUsers+=("root")

    mapfile -t NeededStandard < <(sed -n '/Authorized Users:<\/b>/, /</{ /Authorized Users:<\/b>/! { /</! p } }' $path | xargs)
    mapfile -t NeededUsers < <(sed -n '/Authorized Administrators:/, /</{ /Authorized Administrators:/! { /</! p } }' $path | sed -n '1~2p' |cut -d" " -f1 | xargs)
    if (( ${#NeededStandard[@]} == 0 )); 
    then
        echo "STANDARD USERS NOT DEFINED"
    fi
    if (( ${#NeededUsers[@]} == 0 )); 
    then
        echo "ADMINS NOT DEFINED"
    fi
    NeededUsers+=("root")
    MainUser=${NeededUsers[0]}

    #admin user differences
    mapfile -t AdminDiffs < <(echo ${CurrentAdminUsers[@]} ${NeededUsers[@]} | tr ' ' '\n' | sort | uniq -u)

    for (( i=0; i<${#AdminDiffs[@]}; i++ ));
    do
        if [[ ${NeededUsers[*]} =~ ${AdminDiffs[i]} ]]
        then #if user is on README but not currently admin
            if [[ ${CurrentNormUsers[*]} =~ ${AdminDiffs[i]} ]]
            then # user is a standard user that needs to be upgraded
                usermod -aG sudo ${AdminDiffs[i]}
                usermod -aG adm ${AdminDiffs[i]}
                echo "change standard user ${AdminDiffs[i]} to admin" >> UserChangeLog
            elif [[ ! ${CurrentNormUsers[*]} =~ ${AdminDiffs[i]} ]]
            then # user is not present on system
                useradd -s /bin/bash -m -G sudo ${AdminDiffs[i]}
                echo "add admin user ${AdminDiffs[i]}" >> UserChangeLog
            fi
        elif [[ ! ${NeededUsers[*]} =~ ${AdminDiffs[i]} ]]
        then #user is on system but not readme
            if [[  ${NeededStandard[*]} =~ ${AdminDiffs[i]} ]]
            then
                deluser ${AdminDiffs[i]} sudo
                echo "downgrade Admin ${AdminDiffs[i]} to standard" >> UserChangeLog 
            else
                userdel -rf ${AdminDiffs[i]}
                echo "remove user ${AdminDiffs[i]}" >> UserChangeLog

            fi

        fi
    done
    #==================STANDARD USERS==============
    #update users
    updateUserDefs
    #standard user differences
    mapfile -t StandardDiffs < <(echo ${CurrentNormUsers[@]} ${NeededStandard[@]} | tr ' ' '\n' | sort | uniq -u)

    for (( i=0; i<${#StandardDiffs[@]}; i++ ));
    do
        if [[ ${NeededStandard[*]} =~ ${StandardDiffs[i]} ]]
        then #if user is on README but not currently on system
            if [[ ${CurrentAdminUsers[*]} =~ ${StandardDiffs[i]} ]]
            then #user is admin that needs to be downgraded(shouldnt happen but is here just in case)
                deluser ${StandardDiffs[i]} sudo
                deluser ${StandardDiffs[i]} adm
                echo "change admin ${StandardDiffs[i]} to standard user" >> UserChangeLog
            elif [[ ! ${CurrentAdminUsers[*]} =~ ${StandardDiffs[i]} ]]
            then # user is not present on system
                useradd -s /bin/bash -m ${StandardDiffs[i]}
                echo "add standard user ${StandardDiffs[i]}" >> UserChangeLog
            fi
        elif [[ ! ${NeededStandard[*]} =~ ${StandardDiffs[i]} ]]
        then #user is on system but not Readme
            if [[  ${NeededUsers[*]} =~ ${StandardDiffs[i]} ]]
            then #(again somewhat redundant) user is supposed to be admin
                usermod -aG sudo ${StandardDiffs[i]}
                usermod -aG adm ${StandardDiffs[i]}
                echo "upgrade standard ${StandardDiffs[i]} to admin" >> UserChangeLog
            else #user should not be on machine
                userdel -rf ${StandardDiffs[i]}
                echo "remove user ${StandardDiffs[i]}" >> UserChangeLog
            fi
        fi
    done
    clear
    echo "  check UserChangeLog file to find, troubleshoot or review what was edited"
    echo "============================================================================"
    echo "                                PASSWORDS                                   "
    echo "============================================================================"
    echo "ALL PASSWORDS EXCEPT ROOT AND MAIN USER WILL BE CHANGED TO [Cyb3rPatr!0t$]"
    #=============PASSWORDS============
    updateUserDefs
    #====================================================================================================================
    #FOR THE LOVE OF ALL THAT IS HOLY PLEASE NEVER DO THIS ON SOMETHING THAT ISN'T A CYBERPATRIOTS COMPETITION.
    #IT IS HORRIBLY INSECURE(cyberpatriots doesn't detect or care though). IT IS A STUPID FUCKING WORKAROUND FOR SPEED 
    #========================================================================================================================
    for (( i=1; i<${#AllCurrentUsers[@]}; i++ ));
    do
        if [[ ${AllCurrentUsers[i]} != "root" ]]
        then
            echo "changing password for ${AllCurrentUsers[i]}"
            echo "${AllCurrentUsers[i]}:Cyb3rPatr!0t$" | chpasswd
        fi
    done
}

DisableRoot() {
    echo "============================================================================"
    echo "                               DISABLE ROOT                                  "
    echo "============================================================================"
    sudo passwd -l root
    echo "Root Account Disabled"
}

Sudoers() {
    echo "============================================================================"
    echo "                               SUDOERS FILE                                  "
    echo "============================================================================"
    if grep -q 'NOPASSWD\|!authenticate' /etc/sudoers ;
    then
        echo "instances of NOPASSWD or !authenticate found please check /etc/sudoers"
    else
        echo "no instances of NOPASSWD or !authenticate found"
    fi
    chmod 640 /etc/sudoers
}

shadow() {
    echo "============================================================================"
    echo "                               SHADOW PERMISSIONS                                  "
    echo "============================================================================"
    sudo chmod 640 /etc/shadow
    echo "/etc/shadow permissions changed"
}

UBUpdates() {
    echo "============================================================================"
    echo "                               UBUNTU UPDATES                                  "
    echo "============================================================================"
    sudo apt-get install unattended-upgrades -yq
    sudo systemctl start unattended-upgrades
    sudo systemctl enable unattended-upgrades
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
            sudo sed -i "/${debType[i]} http:\/\/archive.canonical.com\/ubuntu focal/c${debType[i]} http:\/\/archive.canonical.com\/ubuntu focal partner" /etc/apt/sources.list
        else
            echo "${debType[i]} http://archive.canonical.com/ubuntu focal partner" >> /etc/apt/sources.list
        fi
    done

    for (( i=0; i<${#configType[@]}; i++ ));
    do
        if grep -iq "APT::Periodic::${configType[i]}" /etc/apt/apt.conf.d/*auto-upgrades /etc/apt/apt.conf.d/*periodic
        then
            sed -i "/APT::Periodic::${configType[i]}/c\APT::Periodic::${configType[i]};" /etc/apt/apt.conf.d/*auto-upgrades /etc/apt/apt.conf.d/*periodic
        else
            echo "APT::Periodic::${configType[i]};" >> /etc/apt/apt.conf.d/*auto-upgrades /etc/apt/apt.conf.d/*periodic
        fi
    done
    for (( i=0; i<${#configType[@]}; i++ ));
    do
        if grep -iq "APT::Periodic::AutocleanInterval" /etc/apt/apt.conf.d/*auto-upgrades /etc/apt/apt.conf.d/*periodic
        then
            sed -i '/APT::Periodic::AutocleanInterval/c\APT::Periodic::AutocleanInterval "14";' /etc/apt/apt.conf.d/*auto-upgrades /etc/apt/apt.conf.d/*periodic #add too periodic as well
        else
            echo 'APT::Periodic::AutocleanInterval "14";' >> /etc/apt/apt.conf.d/*auto-upgrades /etc/apt/apt.conf.d/*periodic
        fi
    done

    sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq
    sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -yq

    echo "UPDATES COMPLETE"

}

DEBUpdates() {
    echo "============================================================================"
    echo "                               DEBIAN UPDATES                                  "
    echo "============================================================================"
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
}

MediaScan() {
    echo "============================================================================"
    echo "                               MEDIA SCAN                                  "
    echo "============================================================================"
    if [ -f "media.log" ]; then
        rm media.log
    fi

    fileTypes=(
        # Video
        "mp4" "mpeg" "avi" "mpg" "webm" "mov" "wav"
        # Pictures
        "png" "jpg" "jpeg" "gif" "bmp" "tiff" "raw"
        # Audio
        "mp3" "ogg" "m4a" "flac"
        # Misc
        "txt" "docx" "pdf" "doc" "ppt" "pptx" "xls" "ps"
    ) 

    fileCount=0
    echo "Scanning..."
    for file in "${fileTypes[@]}"; do
        foundFiles=$(sudo find /home -name "*.$file" -type f)
        if [ -n "$foundFiles" ]; then
            echo "$foundFiles" >> media.log
            fileCount=$((fileCount + $(echo "$foundFiles") | wc -l))
        fi
    done

    echo "Media scan complete $fileCount files found."
    echo "Output dropped to 'media.log'"
}

Firewall() {
    echo "============================================================================"
    echo "                               Firewall(UFW)                                  "
    echo "============================================================================"
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
}

SysctlConfig() {
    echo "============================================================================"
    echo "                               SYSCTL CONFIGURATION                                  "
    echo "============================================================================"

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
    echo "COMPLETE"
}

SecureSSH() {
    # Backup the SSH configuration
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    echo "SSH config backed up to: /etc/ssh/sshd_config.backup"

    # Modify SSH configuration to secure settings
    sudo sed -i 's/^#*LoginGraceTime .*/LoginGraceTime 60/' /etc/ssh/sshd_config
    sudo sed -i 's/^#*PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
    sudo sed -i 's/^#*Protocol .*/Protocol 2/' /etc/ssh/sshd_config
    sudo sed -i 's/^#*PermitEmptyPasswords .*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
    sudo sed -i 's/^#*PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sudo sed -i 's/^#*X11Forwarding .*/X11Forwarding no/' /etc/ssh/sshd_config
    sudo sed -i 's/^#*UsePAM .*/UsePAM yes/' /etc/ssh/sshd_config
    sudo sed -i 's/^#*UsePrivilegeSeparation .*/UsePrivilegeSeparation yes/' /etc/ssh/sshd_config

    # Restart SSH service
    sudo systemctl restart sshd

    echo "SSH has been secured."
}

UBUpdates
Users
DisableRoot
Sudoers
shadow
#DEBUpdates
Firewall
SysctlConfig
SecureSSH
MediaScan