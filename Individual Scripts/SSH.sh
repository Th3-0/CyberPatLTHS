#!/bin/bash

# Function to secure SSH configuration
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

if command -v sshd &>/dev/null; then
    echo "SSH is already installed."

    read -r -p "Do you want to secure it? (y/n) " yn

    case $yn in
    y) SecureSSH ;;
    n) exit ;;
    *)
        echo "Invalid response. Please enter 'y' or 'n'."
        exit 1
        ;;
    esac
else
    echo "SSH is not installed."

    read -r -p "Do you want to install and secure it? (y/n) " yn

    case $yn in
    y)
        # Install sshd
        sudo apt-get update
        sudo apt-get install openssh-server -y

        echo "SSH has been installed."
        SecureSSH
        ;;
    n) exit ;;
    *)
        echo "Invalid response. Please enter 'y' or 'n'."
        exit 1
        ;;
    esac
fi
