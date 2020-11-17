#!/bin/bash
PUSHGATEWAY_VERSION="1.3.0"
wget https://github.com/prometheus/pushgateway/releases/download/v${PUSHGATEWAY_VERSION}/pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64.tar.gz
tar -xzvf pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64.tar.gz
cd pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64/

# create user
useradd --no-create-home --shell /bin/false pushgateway

# copy binaries
cp pushgateway /usr/local/bin

# set ownership
chown pushgateway:pushgateway /usr/local/bin/pushgateway

# setup systemd
echo '[Unit]
Description=Push Gateway
Wants=network-online.target
After=network-online.target
[Service]
User=pushgateway
Group=pushgateway
Type=simple
ExecStart=/usr/local/bin/pushgateway
[Install]
WantedBy=multi-user.target' > /etc/systemd/system/pushgateway.service

# enable pushgateway in systemctl
systemctl daemon-reload
systemctl start pushgateway
systemctl enable pushgateway

echo "Setup complete.
Add the following lines to /etc/prometheus/prometheus.yml:
  - job_name: 'pushgateway'
    scrape_interval: 30s
    static_configs:
      - targets: ['localhost:9100']
"
