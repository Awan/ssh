#!/bin/sh     

coded_by='

In the name of Allah, the most Gracious, the most Merciful.

 ▓▓▓▓▓▓▓▓▓▓
░▓ Author ▓ Abdullah <https://abdullah.today>
░▓▓▓▓▓▓▓▓▓▓ YouTube <https://YouTube.com/AbdullahToday>
░░░░░░░░░░

░█▀▀░█▀▀░█░█░░░█▀▀░█▀▀░█▀▀░█░█░█▀▄░█▀▀░█▀▄
░▀▀█░▀▀█░█▀█░░░▀▀█░█▀▀░█░░░█░█░█▀▄░█▀▀░█░█
░▀▀▀░▀▀▀░▀░▀░░░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀▀░
'

# Make a server ready for ssh

echo "$coded_by"
sleep 2
server_config_file="/etc/ssh/sshd_config"
super_key="/etc/super_key"

# Exit if not run as root

if [ "$(id -u)" -ne 0 ]; then
    echo 'Error: This script must be run as root or with sudo! Bye' >&2
    exit 1
fi

# Ask user to enter the public SSH key.

read -r "Enter public SSH key: " public_key

# Check if required directories exist on server with correct permissions, create them if not, copy ID and change file permissions.

if [ ! -d ~/.ssh ]; then
    mkdir -m 700 ~/.ssh >/dev/null 2>&1
    echo "$public_key" >> ~/.ssh/authorized_keys
    chmod 0600 ~/.ssh/authorized_keys >/dev/null 2>&1
fi

# Enable Public key authentication. 

sed -i '/PubKeyAuthentication/c\PubKeyAuthentication yes' "$server_config_file"

# Disable password authentication

sed -i '/PasswordAuthentication/c\PasswordAuthentication no' "$server_config_file"
sed -i '/UsePAM/c\UsePAM no' $server_config_file

# Disable root login with clear password. Only allow root login with Public Key authentication

sed -i '/PermitRootLogin/c\PermitRootLogin without-password' "$server_config_file"

# Enable super key. So you can login as any user.

sed -i '/AuthorizedKeysFile/c\AuthorizedKeysFile %h/.ssh/authorized_keys /etc/super_key' "$server_config_file"

# Add this key as super key

echo "$public_key" >> "$super_key"

# And finally restart SSH service

systemctl restart sshd 
