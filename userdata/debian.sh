#!/usr/bin/env bash

# Basics
export DEBIAN_FRONTEND="noninteractive";
echo "=> UPGRADE PACKAGES";
apt-get update;
apt-get dist-upgrade -y;

ARCH=$(arch); # x86_64 or aarch64
if [ "${ARCH}" == "x86_64" ]; then
  ARCH2="amd64";
elif [ "${ARCH}" == "aarch64" ]; then
  ARCH2="arm64";
fi
export ARCH;
export ARCH2;

# Install AWS CLI
# apt-get install -y awscli;
apt-get install -y vim wget curl unzip;
wget --quiet -O awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip";
unzip -q awscliv2.zip;
./aws/install;
aws --version;
rm -rf ./aws/ ./awscliv2.zip;

# Install
# This does say windows but also hosts others
wget --quiet "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_${ARCH2}/amazon-ssm-agent.deb";
dpkg -i ./amazon-ssm-agent.deb;
systemctl enable amazon-ssm-agent;
systemctl start amazon-ssm-agent;
systemctl status amazon-ssm-agent;

########################
##### Common Tools #####
########################
apt-get install -y tree nmap ncat;

############################
##### Database Clients #####
############################
# Debian 11 and 12
apt-get install -y postgresql-client default-mysql-client;
# Debian 12 only
DEBIAN_RELVER=$(head -c 2 /etc/debian_version);
if [ "${DEBIAN_RELVER}" == "12" ]; then
  apt-get install -y valkey-tools;
fi
