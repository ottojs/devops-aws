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
amazon-ssm-agent --version > /root/amazon-ssm-agent.upgraded.txt; # 3.3.2746.0 (2025-08-25)

########################
##### Common Tools #####
########################
apt-get install -y gpg tree nmap ncat htop;

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

#########################
##### Node.js v22.x #####
#########################
# https://github.com/nodesource/distributions/blob/master/scripts/deb/setup_22.x
echo "=> INSTALL NODEJS";
NODE_VERSION="22.x";
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /usr/share/keyrings/nodesource.gpg;
chmod 644 /usr/share/keyrings/nodesource.gpg
cat << NODEJS > /etc/apt/sources.list.d/nodesource.list;
deb [arch=${ARCH2} signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_VERSION} nodistro main
NODEJS
apt-get update;
sleep 10;
apt-get install -y nodejs;
echo "Node.js Version";
node --version;
echo "npm Version";
npm --version;

##################
##### Golang #####
##################
GO_VERSION="1.25.0";
echo "=> INSTALL GOLANG";
echo "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH2}.tar.gz";
wget --quiet -O golang.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH2}.tar.gz";
tar -C /usr/local -xzf golang.tar.gz;
rm ./golang.tar.gz;
echo 'export PATH="${PATH}:/usr/local/go/bin";' >> /etc/profile;
/usr/local/go/bin/go version;
