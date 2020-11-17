# This script is incomplete, but most of the steps can be executed manually.


#!/bin/bash
# Installing Blackbox exporter on CentOS 5 machine
# Download the file to the system before executing the script incase wget or curl doesn't work on the system.


BLACKBOX_EXPORTER_VERSION="0.18.0"
#curl -JLO https://github.com/prometheus/blackbox_exporter/releases/download/v${BLACKBOX_EXPORTER_VERSION}/blackbox_exporter-${BLACKBOX_EXPORTER_VERSION}.linux-386.tar.gz
tar -xzvf blackbox_exporter-${BLACKBOX_EXPORTER_VERSION}.linux-386.tar.gz
cd blackbox_exporter-${BLACKBOX_EXPORTER_VERSION}.linux-386

# create user
useradd --shell /bin/false blackbox_exporter

cp blackbox_exporter /usr/local/bin

chown blackbox_exporter:blackbox_exporter /usr/local/bin/blackbox_exporter

mkdir /etc/blackbox_exporter
chown blackbox_exporter:blackbox_exporter /etc/blackbox_exporter

cp blackbox.yml /etc/blackbox_exporter/

# Add user blackbox_exporter to sudo group and also enable password less sudo access without password by defining in visudo
usermod -aG wheel blackbox_exporter

# visudo and add the below line in wheel group
### Same thing without a password
## %wheel        ALL=(ALL)       NOPASSWD: ALL
#blackbox_exporter       ALL=(ALL)       NOPASSWD: ALL 

sudo nano /etc/blackbox_exporter/blackbox.yml


echo ''
