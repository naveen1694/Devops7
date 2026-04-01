#!/bin/bash

# Update system
sudo dnf update -y

# Install Java 17
sudo dnf install java-17-amazon-corretto -y

# Create nexus user
sudo useradd nexus

# Download Nexus
cd /opt
sudo wget https://download.sonatype.com/nexus/3/nexus-unix-x86-64-3.79.0-09.tar.gz

# Extract Nexus
sudo tar -xvzf nexus-unix-x86-64-3.79.0-09.tar.gz

# Rename for simplicity
sudo mv nexus-3.79.0-09 nexus

# Create sonatype-work directory
sudo mkdir -p /opt/sonatype-work

# Change ownership
sudo chown -R nexus:nexus /opt/nexus
sudo chown -R nexus:nexus /opt/sonatype-work

# Configure Nexus to run as nexus user
echo 'run_as_user="nexus"' | sudo tee /opt/nexus/bin/nexus.rc

# Create systemd service file
sudo tee /etc/systemd/system/nexus.service > /dev/null <<EOF
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
sudo systemctl daemon-reload

# Enable Nexus at boot
sudo systemctl enable nexus

# Start Nexus
sudo systemctl start nexus

# Check status
sudo systemctl status nexus
