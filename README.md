# Raspberry Pi Hardening Guide

## Recommendations

1. **Create a Non-Root User**: It's crucial not to use the default 'pi' user for everyday tasks. Create a non-root user and give it sudo privileges.

2. **Disable Root Login**: Disabling root login via SSH enhances security by preventing direct root access.

3. **Key-Based SSH Authentication**: Generate SSH key pairs for secure authentication. Use key-based authentication instead of passwords.

4. **Allow SSH Access Only from Management Server**: Restrict SSH access to only the IP address of your management server to prevent unauthorized access.

5. **Create a Reverse SSH Tunnel**: Create a reverse SSH tunnel to allow remote management. Adjust the port and username as needed.

6. **Firewall Configuration**: Configure the Uncomplicated Firewall (UFW) to allow only necessary ports (25001 and 10514) and deny all other incoming traffic.

7. **Automatic Security Updates**: Set up a cron job to automatically apply security updates.

8. **Apply Basic Hardening Steps**: You can add additional hardening steps specific to your requirements, such as disabling unused services and securing shared memory and sysctl parameters.

9. **Automate the Hardening Process**: You can use bash script to automate hardening process and modify the script according to your specific requirements.

## Create a Non-Root User

Creating a non-root user on a Raspberry Pi is a fundamental security step. You can follow these steps to create a non-root user:

1. **Log in to the Raspberry Pi:** If you're not already logged in, SSH into your Raspberry Pi with the root or superuser privileges. The default user is often named 'pi.' For example:

   ```bash
   ssh pi@your_raspberry_pi_ip
   ```

2. **Create a New User:** To create a new user, you can use the `adduser` command. Replace `new_username` with the username you want to create:

   ```bash
   sudo adduser new_username
   ```

   The command will prompt you to set a password and additional information for the new user. You can choose to leave these fields blank if you want to set up these details later.

3. **Add the New User to the sudo Group:** By adding the user to the 'sudo' group, you grant them superuser privileges. This allows them to execute administrative tasks with elevated permissions. Use the `usermod` command:

   ```bash
   sudo usermod -aG sudo new_username
   ```

4. **Test the New User:** You can now switch to the new user to verify that it has the correct permissions. Use the `su` command to switch to the new user:

   ```bash
   su - new_username
   ```

   You will be prompted to enter the new user's password. Once logged in as the new user, you can execute commands with regular user privileges. To return to the superuser account, type `exit`.

5. **Secure SSH Key Authentication (Optional):** For additional security, you can set up SSH key authentication for the new user. This allows you to log in without a password. Generate an SSH key pair on your local machine and add the public key to the new user's `~/.ssh/authorized_keys` file.

   On your local machine:

   ```bash
   ssh-keygen
   ```

   Then, copy the public key to the Raspberry Pi:

   ```bash
   ssh-copy-id new_username@your_raspberry_pi_ip
   ```

   After this, you can log in as the new user without a password.

Your new non-root user is now set up and can be used for everyday tasks. Make sure to log in as the new user when you want to perform regular actions and only use the superuser (root) account when necessary for administrative tasks. This practice improves the security of your Raspberry Pi by reducing the likelihood of unintentional mistakes or unauthorized access.

## Disable Root Login

Disabling root login is a security best practice to prevent unauthorized access to your Raspberry Pi. You can disable root login by editing the SSH configuration file. Here are the steps to disable root login:

1. **Log in to your Raspberry Pi:** If you're not already logged in, SSH into your Raspberry Pi with a user account that has sudo privileges. For example:

   ```bash
   ssh your_username@your_raspberry_pi_ip
   ```

2. **Edit the SSH Configuration File:** Use a text editor to edit the SSH server configuration file, typically located at `/etc/ssh/sshd_config`. You'll need superuser privileges to modify this file, so use `sudo` with your text editor of choice. For example, using `nano`:

   ```bash
   sudo nano /etc/ssh/sshd_config
   ```

3. **Find and Edit the PermitRootLogin Directive:** Inside the SSH configuration file, locate the line that begins with `PermitRootLogin`. By default, it is often set to `yes`. Change it to `no`:

   ```text
   PermitRootLogin no
   ```

4. **Save and Exit the Editor:** In the `nano` text editor, you can save your changes by pressing `Ctrl` + `O`, then press `Enter` to confirm the filename. To exit, press `Ctrl` + `X`.

5. **Restart the SSH Service:** To apply the changes, you need to restart the SSH service:

   ```bash
   sudo service ssh restart
   ```

Now, root login should be disabled, and you won't be able to log in directly as the root user. Instead, you should log in using a non-root user with sudo privileges and then use `sudo` for administrative tasks when needed.

Make sure you have tested your non-root user to ensure it has the necessary permissions to perform administrative tasks. Disabling root login enhances the security of your Raspberry Pi by reducing the attack surface and preventing unauthorized users from logging in as the root user.

## Key-Based SSH Authentication

Key-based SSH authentication is a more convenient way to log in to your Raspberry Pi compared to using passwords. Here are the steps to set up key-based SSH authentication:

1. **Generate SSH Key Pair on Your Local Machine:**

   On your local machine, open a terminal and generate an SSH key pair using the `ssh-keygen` command. This will create a public key and a private key. Replace `your_email@example.com` with your email address:

   ```bash
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```

   You will be prompted to choose a location for the key pair. The default location is typically `~/.ssh/id_rsa`. You can press Enter to accept the default location.

   This command generates a public key (`id_rsa.pub`) and a private key (`id_rsa`) in the `~/.ssh/` directory.

2. **Copy Your Public Key to the Raspberry Pi:**

   Use the `ssh-copy-id` command to copy your public key to the Raspberry Pi. Replace `your_username` and `your_raspberry_pi_ip` with your Raspberry Pi's username and IP address:

   ```bash
   ssh-copy-id your_username@your_raspberry_pi_ip
   ```

   You will be prompted to enter the password for your Raspberry Pi user. After providing the password, the public key will be added to the `~/.ssh/authorized_keys` file on the Raspberry Pi.

3. **Test Key-Based Authentication:**

   You should now be able to log in to your Raspberry Pi without a password, using your private key. The following command should log you in:

   ```bash
   ssh your_username@your_raspberry_pi_ip
   ```

   You may be prompted to unlock your local private key with a passphrase if you set one during key generation.

4. **Disable Password Authentication (Optional):**

   For additional security, you can disable password authentication in the SSH server configuration file. On the Raspberry Pi, edit the SSH configuration file with superuser privileges:

   ```bash
   sudo nano /etc/ssh/sshd_config
   ```

   Look for the `PasswordAuthentication` line and change it to `no`:

   ```text
   PasswordAuthentication no
   ```

   Save the file and restart the SSH service:

   ```bash
   sudo service ssh restart
   ```

   This step will ensure that SSH access is only possible with key-based authentication, further enhancing security.

After completing these steps, your Raspberry Pi is configured for key-based SSH authentication. This method provides a more secure way to access your device compared to password-based authentication. Make sure to keep your private key secure on your local machine.

## Allow SSH Access Only from Management Server

To allow SSH access only from your specific management server and deny access from all other sources, you can configure your Raspberry Pi's firewall settings to filter incoming SSH connections based on the source IP address. Follow these steps:

1. **Log in to your Raspberry Pi:**

   Use SSH to connect to your Raspberry Pi:

   ```bash
   ssh your_username@your_raspberry_pi_ip
   ```

2. **Backup the Current SSH Configuration:**

   Before making changes to your SSH configuration, it's a good practice to back up the current configuration file. Use the following command to create a backup:

   ```bash
   sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
   ```

3. **Edit the SSH Configuration:**

   Use a text editor, like `nano`, to edit the SSH configuration file:

   ```bash
   sudo nano /etc/ssh/sshd_config
   ```

4. **Configure SSH to Allow Access Only from the Management Server:**

   Look for the `AllowUsers` or `AllowGroups` directive in the SSH configuration file. If it's not present, you can add it. Replace `management_server_ip` with the actual IP address of your management server. If you have multiple management servers, separate their IP addresses with spaces. 

   For `AllowUsers`:

   ```text
   AllowUsers your_username@management_server_ip
   ```

   For `AllowGroups` (create a group if needed):

   ```text
   AllowGroups mysshgroup
   ```

5. **Disable Password Authentication (Optional):**

   For added security, you can disable password authentication as mentioned in a previous recommendation. To do this, set `PasswordAuthentication` to `no` in the SSH configuration:

   ```text
   PasswordAuthentication no
   ```

6. **Save and Close the SSH Configuration File:**

   In `nano`, press `Ctrl` + `O`, then press `Enter` to save the changes. Press `Ctrl` + `X` to exit the editor.

7. **Restart the SSH Service:**

   To apply the changes, restart the SSH service:

   ```bash
   sudo service ssh restart
   ```

8. **Test SSH Access:**

   Ensure you can still access your Raspberry Pi from the authorized management server:

   ```bash
   ssh your_username@your_raspberry_pi_ip
   ```

   You should be able to log in without any issues. SSH access from other IP addresses should be denied.

By configuring the SSH server in this way, you restrict access to only the specified management server or group, enhancing security by reducing the attack surface. Make sure you maintain proper access controls and regularly monitor your SSH logs for any unusual activity.

## Create a Reverse SSH Tunnel

Creating a reverse SSH tunnel allows your Raspberry Pi to connect back to a management server, providing a way for you to manage the Pi remotely. Here's how you can create a reverse SSH tunnel:

1. **On the Raspberry Pi:**

   First, log in to your Raspberry Pi via SSH. If you're using the default 'pi' user, the command might look like this:

   ```bash
   ssh pi@your_raspberry_pi_ip
   ```

2. **Create the Reverse SSH Tunnel:**

   Replace `management_server_ip` with the IP address or hostname of your management server and `25000` with the desired port on the management server.

   ```bash
   ssh -N -R 25000:localhost:22 your_username@management_server_ip
   ```

   - `-N`: Tells SSH not to execute any remote commands, which is useful for tunneling purposes.
   - `-R`: Specifies the reverse tunnel, mapping port `25000` on the management server to the Raspberry Pi's SSH service (port 22).

   This command establishes the reverse SSH tunnel. It's essential that this command remains running for the tunnel to stay active. To ensure it keeps running, you might use tools like `nohup` to run it in the background or set it up as a systemd service.

3. **Test the Tunnel:**

   To test the tunnel, from your management server, try SSH'ing into the Raspberry Pi via the management server's port `25000`:

   ```bash
   ssh -p 25000 your_username@localhost
   ```

   You should be able to log in to your Raspberry Pi. This connection is routed through the reverse SSH tunnel.

4. **Automate the Tunnel at Startup (Optional):**

   To ensure the reverse SSH tunnel is always available, you can add it to your Raspberry Pi's startup procedures. One common way to do this is by creating a systemd service. Here's a simple example:

   Create a systemd service file for the reverse SSH tunnel:

   ```bash
   sudo nano /etc/systemd/system/reverse-ssh-tunnel.service
   ```

   Add the following content to the service file, adjusting the configuration to match your setup:

   ```plaintext
   [Unit]
   Description=Reverse SSH Tunnel

   [Service]
   ExecStart=/usr/bin/ssh -N -R 25000:localhost:22 your_username@management_server_ip
   Restart=always
   User=your_username

   [Install]
   WantedBy=multi-user.target
   ```

   Save and close the file.

   Then, enable and start the service:

   ```bash
   sudo systemctl enable reverse-ssh-tunnel
   sudo systemctl start reverse-ssh-tunnel
   ```

   Now, the reverse SSH tunnel will be established automatically at boot.

Please ensure you replace `your_username`, `management_server_ip`, and any port numbers with the actual values you're using. Additionally, secure the Raspberry Pi and management server to limit access to this tunnel, as it provides remote access to your device.

## Firewall Configuration

You can use either UFW (Uncomplicated Firewall) or iptables to configure the firewall on your Raspberry Pi to allow only the necessary incoming and outgoing communication. Below, I'll provide both UFW and iptables solutions for your specific requirements, which are to allow incoming SSH access from the management server and outgoing communication on specified ports (25001 and 10514).

### UFW (Uncomplicated Firewall) Solution

UFW is a user-friendly interface for managing iptables rules. Here's how to configure UFW to meet your requirements:

1. **Install UFW (if not already installed):**

   ```bash
   sudo apt install ufw
   ```

2. **Enable UFW and Deny Incoming Connections:**

   By default, UFW should deny all incoming connections. You can enable it with:

   ```bash
   sudo ufw enable
   ```

3. **Allow SSH Access from the Management Server:**

   Allow incoming SSH connections from your management server's IP address:

   ```bash
   sudo ufw allow from management_server_ip to any port 22
   ```

4. **Allow Outgoing Communication on Ports 25001 and 10514:**

   Allow outgoing communication on the specified ports (25001 and 10514):

   ```bash
   sudo ufw allow out 25001/tcp
   sudo ufw allow out 10514/tcp
   ```

5. **Deny All Other Incoming Traffic:**

   Ensure that all other incoming connections are denied by default:

   ```bash
   sudo ufw default deny incoming
   ```

6. **Deny All Other Outgoing Traffic (Optional):**

   To further restrict outgoing traffic, you can set a default deny rule for outgoing traffic, which will block all outgoing connections except for the ones you've explicitly allowed:

   ```bash
   sudo ufw default deny outgoing
   ```

7. **Enable UFW:**

   After configuring the rules, enable UFW to apply them:

   ```bash
   sudo ufw enable
   ```

8. **Check UFW Status:**

   You can check the status of UFW to verify your rules:

   ```bash
   sudo ufw status
   ```

### iptables Solution

If you prefer to use `iptables` directly, here's how you can configure it:

1. **Install iptables (if not already installed):**

   ```bash
   sudo apt install iptables-persistent
   ```

   During the installation, you will be prompted to save the current iptables rules. Choose to save them.

2. **Allow SSH Access from the Management Server:**

   Allow incoming SSH connections from your management server's IP address (replace `management_server_ip` with the actual IP address):

   ```bash
   sudo iptables -A INPUT -p tcp --dport 22 -s management_server_ip -j ACCEPT
   ```

3. **Allow Outgoing Communication on Ports 25001 and 10514:**

   Allow outgoing communication on the specified ports (25001 and 10514):

   ```bash
   sudo iptables -A OUTPUT -p tcp --dport 25001 -j ACCEPT
   sudo iptables -A OUTPUT -p tcp --dport 10514 -j ACCEPT
   ```

4. **Deny All Other Incoming Traffic:**

   Deny all other incoming connections:

   ```bash
   sudo iptables -A INPUT -j DROP
   ```

5. **Deny All Other Outgoing Traffic (Optional):**

   To further restrict outgoing traffic, you can set a default policy to deny outgoing connections, which will block all outgoing connections except for the ones you've explicitly allowed:

   ```bash
   sudo iptables -P OUTPUT DROP
   ```

6. **Save iptables Rules:**

   Save the iptables rules to make them persistent across reboots:

   ```bash
   sudo iptables-save | sudo tee /etc/iptables/rules.v4
   ```

   This command saves the rules to the `/etc/iptables/rules.v4` file.

After configuring `iptables`, you should also run the following command to save the rules for IPv6 (if you're using it):

```bash
sudo ip6tables-save | sudo tee /etc/iptables/rules.v6
```

These rules will be applied each time your Raspberry Pi starts up.

Both UFW and iptables solutions will help you achieve your firewall configuration requirements. Choose the one that you're more comfortable with or find more convenient for your use case. Make sure to test the rules and configurations to ensure that they meet your security and communication needs.

## Automatic Security Updates

To set up automatic security updates for a Raspberry Pi, you should use the "unattended-upgrades" package, which is specifically designed for this purpose. Here's how you can set it up:

1. Install the "unattended-upgrades" package if it's not already installed:

   ```bash
   sudo apt install unattended-upgrades
   ```

2. Configure the package by editing the `/etc/apt/apt.conf.d/50unattended-upgrades` file:

   ```bash
   sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
   ```

   Inside the file, you can configure which updates to install automatically. For example, you can uncomment and set the following options:

   ```text
   Unattended-Upgrade::Allowed-Origins {
      "${distro_id}:${distro_codename}";
      "${distro_id}:${distro_codename}-security";
      "${distro_id}ESM:${distro_codename}";
   };
   ```

   This configuration allows automatic installation of security updates.

3. Enable the "unattended-upgrades" service:

   ```bash
   sudo dpkg-reconfigure -plow unattended-upgrades
   ```

4. By default, the package should already set up a daily cron job for you. You can check the status of the unattended-upgrades service:

   ```bash
   sudo systemctl status unattended-upgrades
   ```

With these steps, your Raspberry Pi will automatically install security updates as they become available.

The previous script I provided, which included the manual addition of a cron job for security updates, was not the recommended way to handle updates on a Raspberry Pi. The "unattended-upgrades" package simplifies the process and ensures that your system stays up to date with security patches.

## Apply Basic Hardening Steps

Applying basic hardening steps to your Raspberry Pi is an important part of securing your system. These steps typically include disabling unnecessary services, securing shared memory, and setting secure sysctl parameters. Here's how to perform these basic hardening steps:

1. **Disabling Unnecessary Services:**

   - Identify the services running on your Raspberry Pi using the following command:

     ```bash
     systemctl list-units --type=service
     ```

   - Review the list of services and determine which ones are not required for your specific use case.

   - To disable a service, use the following command, replacing `service_name` with the name of the service you want to disable:

     ```bash
     sudo systemctl disable service_name
     ```

   - After disabling a service, you should also stop it to prevent it from running immediately:

     ```bash
     sudo systemctl stop service_name
     ```

   - Be cautious when disabling services to ensure you do not disable any essential ones. Consult official documentation or seek guidance if you are unsure about a specific service.

2. **Securing Shared Memory:**

   You can configure your system to protect shared memory segments from unauthorized access. Edit the `/etc/fstab` file using a text editor:

   ```bash
   sudo nano /etc/fstab
   ```

   Add the following line to the file:

   ```text
   tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0
   ```

   This entry mounts the shared memory directory with `noexec` and `nosuid` options, which restrict the execution of binaries from shared memory and prevent setuid processes.

   Save the file and exit the text editor.

3. **Setting Secure sysctl Parameters:**

   To set secure sysctl parameters, you can edit the `/etc/sysctl.conf` file:

   ```bash
   sudo nano /etc/sysctl.conf
   ```

   Add or modify the following lines to improve security. These settings restrict ICMP requests, improve IPv4 and IPv6 network security, and prevent IP spoofing:

   ```text
   # Disable ICMP Redirect Acceptance
   net.ipv4.conf.all.accept_redirects = 0
   net.ipv6.conf.all.accept_redirects = 0
   net.ipv4.conf.default.accept_redirects = 0
   net.ipv6.conf.default.accept_redirects = 0

   # Disable Source Routing
   net.ipv4.conf.all.accept_source_route = 0
   net.ipv6.conf.all.accept_source_route = 0
   net.ipv4.conf.default.accept_source_route = 0
   net.ipv6.conf.default.accept_source_route = 0

   # Enable IP Spoofing Protection
   net.ipv4.conf.all.rp_filter = 1
   net.ipv4.conf.default.rp_filter = 1
   net.ipv6.conf.all.rp_filter = 1
   net.ipv6.conf.default.rp_filter = 1
   ```

   Save the file and exit the text editor.

   To apply the new sysctl settings, run:

   ```bash
   sudo sysctl -p
   ```

   This reloads the sysctl configuration with the updated settings.

After performing these basic hardening steps, your Raspberry Pi should be more secure. Remember to test your configuration thoroughly and take regular backups to ensure you can recover your system in case of any issues.

## Brute-force Protection

**Fail2ban** is a useful tool for protecting your Raspberry Pi from DDoS (Distributed Denial of Service) attacks and brute-force attempts by blocking malicious IP addresses. It works by monitoring log files for specific patterns and bans IP addresses that repeatedly exhibit suspicious behavior. Here's how to set up DDoS and brute-force protection using Fail2ban:

1. **Install Fail2ban**:

   If you haven't already installed Fail2ban, you can do so with the following command:

   ```bash
   sudo apt update
   sudo apt install fail2ban
   ```

2. **Configuration Files**:

   Fail2ban's configuration files are usually located in the `/etc/fail2ban/` directory. The main configuration file is `/etc/fail2ban/jail.conf`.

   **Note**: It's not recommended to directly edit `jail.conf`, as it can be overwritten during updates. Instead, you can create a custom configuration file in `/etc/fail2ban/jail.d/`. For example:

   ```bash
   sudo nano /etc/fail2ban/jail.d/custom.conf
   ```

   This custom file can be used to override settings from the `jail.conf` file.

3. **Create a Jail Configuration**:

   Create a jail configuration to specify which services you want to protect. In the custom configuration file, you can define a jail like this:

   ```text
   [sshd]
   enabled = true
   port = ssh
   filter = sshd
   logpath = /var/log/auth.log
   maxretry = 3
   findtime = 600
   bantime = 3600
   ```

   - `enabled`: Set to `true` to enable the jail.
   - `port`: The service or port you want to protect. In this example, it's for SSH (port 22).
   - `filter`: The filter to use. `sshd` is the default for SSH.
   - `logpath`: The log file Fail2ban monitors for banned attempts.
   - `maxretry`: The number of retries allowed before an IP is banned.
   - `findtime`: The time window in seconds during which retries are counted.
   - `bantime`: The duration of the ban in seconds (1 hour in this example).

   You can create similar jail configurations for other services you want to protect.

4. **Create Filters (Optional)**:

   Filters are used to specify the patterns to look for in log files. In most cases, the default filters work well, and you don't need to create custom filters. However, you can create a custom filter if you have specific requirements.

5. **Start Fail2ban**:

   After configuring your jail(s) and filter(s), start the Fail2ban service:

   ```bash
   sudo service fail2ban start
   ```

   You can also enable Fail2ban to start at boot:

   ```bash
   sudo systemctl enable fail2ban
   ```

6. **Check Status and View Banned IP Addresses**:

   You can check the status of Fail2ban and view the currently banned IP addresses with these commands:

   - To check the status of Fail2ban:

     ```bash
     sudo fail2ban-client status
     ```

   - To view the banned IP addresses:

     ```bash
     sudo fail2ban-client status jail_name
     ```

   Replace `jail_name` with the name of the specific jail you want to check, such as `sshd`.

7. **Customize Rules**:

   You can customize the rules, such as the `maxretry`, `findtime`, and `bantime`, to better fit your needs. Adjust these values based on your specific requirements and the level of protection you want.

Fail2ban will continuously monitor the log files for suspicious activities and temporarily ban IP addresses that exceed the defined thresholds. It provides an effective way to protect your Raspberry Pi from DDoS and brute-force attacks.

## Automate the Hardening Process

### Simple Hardening Script with UFW

```bash
#!/bin/bash

# Update the package list and upgrade installed packages
sudo apt update
sudo apt upgrade -y

# Install essential security tools
sudo apt install fail2ban ufw -y

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
sudo ufw allow from management_server_ip to any port 22
sudo ufw enable
sudo ufw status

# Create reverse SSH tunnel for remote management
# Replace 'management_server_ip' and '25000' with actual values
nohup ssh -N -R 25000:localhost:22 your_username@management_server_ip &

# Configure the firewall to allow only necessary ports
sudo ufw allow 25001/tcp
sudo ufw allow 10514/tcp

# Enable the firewall
sudo ufw enable

# Set up an automatic security update cron job
echo "0 0 * * * root unattended-upgrades -d" | sudo tee -a /etc/crontab

# Apply basic hardening steps
# - Disable unused services
# - Secure shared memory
# - Set secure sysctl parameters

# Reboot for changes to take effect
sudo reboot
```

Please replace `your_username` and `management_server_ip` with your specific values.

### Simple Hardening Script with iptables

This script assumes you have a clean iptables configuration on your Raspberry Pi:

```bash
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

# Apply basic hardening steps
# - Disable unused services
# - Secure shared memory
# - Set secure sysctl parameters

# Reboot for changes to take effect
sudo reboot
```

This script configures `iptables` rules directly. It allows SSH access only from your management server, establishes a reverse SSH tunnel, and permits only the required ports (25001 and 10514). Make sure to replace `your_username` and `management_server_ip` with your actual values.

The `iptables` rules are saved to `/etc/iptables/rules.v4` to persist across reboots. Make sure to test the configuration thoroughly before deploying it in a production environment.

