#!/bin/bash
# Installing and running blackbox as a service on Ubuntu 18.04 server
BLACKBOX_VERSION="0.18.0"
wget https://github.com/prometheus/blackbox_exporter/releases/download/v${BLACKBOX_VERSION}/blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64.tar.gz
tar -xzvf blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64.tar.gz
cd blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64/

# create user
useradd --no-create-home --shell /bin/false blackbox_exporter

# copy binaries
cp blackbox_exporter /usr/local/bin

# set ownership
chown blackbox_exporter:blackbox_exporter /usr/local/bin/blackbox_exporter

mkdir /etc/blackbox_exporter
chown blackbox_exporter:blackbox_exporter /etc/blackbox_exporter

# setup systemd
echo '[Unit]
Description=Blackbox Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/bin/sudo /usr/local/bin/blackbox_exporter --config.file /etc/blackbox_exporter/blackbox.yml
[Install]
WantedBy=multi-user.target' > /etc/systemd/system/blackbox_exporter.service

# enable blackbox_exporter in systemctl
systemctl daemon-reload
systemctl start blackbox_exporter
systemctl enable blackbox_exporter

echo "Setup complete.
Update the file /etc/blackbox_exporter/blackbox.yml by appending the below lines, so that ICMP is performed using ipv4 addresses.
  icmp_ipv4:
    prober: icmp
    icmp:
      preferred_ip_protocol: ip4
"
