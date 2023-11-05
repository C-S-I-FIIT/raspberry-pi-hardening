#!/bin/bash

# Update the package list and upgrade installed packages
sudo apt update
sudo apt upgrade -y

# Install essential security tools
sudo apt install fail2ban -y

# Configure fail2ban for basic protection
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Create a non-root user for everyday tasks
sudo adduser your_username
sudo usermod -aG sudo your_username

# Disable root login
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Enable key-based SSH authentication and disable password authentication
sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication no/PasswordAuthentication no/' /etc/ssh/sshd_config

# Generate SSH key pairs for secure access (replace your_username)
sudo -u your_username ssh-keygen

# Allow SSH access only from a specific management server
# Replace 'management_server_ip' with the actual IP address
sudo iptables -A INPUT -p tcp --dport 22 -s management_server_ip -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j DROP

# Create reverse SSH tunnel for remote management
# Replace 'management_server_ip' and '25000' with actual values
nohup ssh -N -R 25000:localhost:22 your_username@management_server_ip &

# Configure the firewall to allow only necessary ports
sudo iptables -A INPUT -p tcp --dport 25001 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 10514 -j ACCEPT
sudo iptables -A INPUT -j DROP

# Save the iptables rules
sudo sh -c "iptables-save > /etc/iptables/rules.v4"

# Set up an automatic security update cron job
echo "0 0 * * * root unattended-upgrades -d" | sudo tee -a /etc/crontab

# Apply additional basic hardening steps
# - Disable unused services
# - Secure shared memory
# - Set secure sysctl parameters

# Reboot for changes to take effect
sudo reboot

