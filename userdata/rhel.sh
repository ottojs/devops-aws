#!/usr/bin/env bash

# Prerequisites (RHEL9)
# awscli2 (aws) is not installed on RHEL9, is installed on AL2023
# wget is not installed on RHEL9, is installed on AL2023
#
# redhat:enterprise_linux:9::baseos
# rocky:rocky:9::baseos
if ! grep amazon:amazon_linux:2023 /etc/os-release; then
  yum install -y awscli2 wget;
fi

# Settings
ARCH=$(arch); # x86_64 or aarch64, uname -m
ARCH2="";
if [ "${ARCH}" == "x86_64" ]; then
  ARCH2="amd64";
elif [ "${ARCH}" == "aarch64" ]; then
  ARCH2="arm64";
fi

# Working Directory
cd /root || exit 1;

######################
##### Amazon SSM #####
######################
# https://docs.aws.amazon.com/systems-manager/latest/userguide/operating-systems-and-machine-types.html
# https://docs.aws.amazon.com/systems-manager/latest/userguide/verify-agent-signature.html
# We hardcode this for security purposes, because a dynamic URI download could change
echo "=> INSTALL AMAZON SSM";
amazon-ssm-agent --version > /root/amazon-ssm-agent.default.txt || echo "NO-SSM-AGENT"; # 3.3.1957.0 (2025-05-07)
cat << EOF > ./amazon-ssm-agent.gpg;
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2.0.22 (GNU/Linux)

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
E6+O8RI2451Dcg==
=aDkv
-----END PGP PUBLIC KEY BLOCK-----
EOF
rpm --import ./amazon-ssm-agent.gpg;
gpg --import ./amazon-ssm-agent.gpg;
rm ./amazon-ssm-agent.gpg;

# Note: This URI says "windows" but this is the correct link
# for Linux UNLESS you want to specify a bucket region (more complex)
#sudo yum install -y "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_${ARCH2}/amazon-ssm-agent.rpm";
wget --quiet "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_${ARCH2}/amazon-ssm-agent.rpm";
wget --quiet "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_${ARCH2}/amazon-ssm-agent.rpm.sig";

if gpg --verify ./amazon-ssm-agent.rpm.sig ./amazon-ssm-agent.rpm 2>&1 | grep 'Good signature from "SSM Agent'; then
  echo "==> [OK] Amazon SSM Agent GPG Check";
else
  echo "==> [FAILED] Amazon SSM Agent GPG Check";
  exit 1;
fi
if rpm --checksig ./amazon-ssm-agent.rpm.sig ./amazon-ssm-agent.rpm | grep 'digests signatures OK'; then
  echo "==> [OK] Amazon SSM Agent RPM Check";
else
  echo "==> [FAILED] Amazon SSM Agent RPM Check";
  exit 1;
fi

yum install -y ./amazon-ssm-agent.rpm;
rm ./amazon-ssm-agent.rpm;
rm ./amazon-ssm-agent.rpm.sig;

# Debug Commands
# systemctl status amazon-ssm-agent;
# journalctl -u amazon-ssm-agent -n 50;

# Capture SSM Agent Version
# It's core to connecting and may be useful for debugging
amazon-ssm-agent --version > /root/amazon-ssm-agent.upgraded.txt; # 3.3.2299.0 (2025-05-07)

############################
##### Upgrade Packages #####
############################
echo "=> UPGRADE PACKAGES";
yum update -y;

########################
##### Common Tools #####
########################
yum install -y git tree nmap nmap-ncat;

# Remove Annoying Prompts
sed -i '/^alias rm=/d' /root/.bashrc;
sed -i '/^alias cp=/d' /root/.bashrc;
sed -i '/^alias mv=/d' /root/.bashrc;

############################
##### Database Clients #####
############################
# AL2023
if grep amazon:amazon_linux:2023 /etc/os-release; then
  yum install -y postgresql17 mariadb1011 valkey;
else
  yum install -y postgresql mysql redis;
fi

#########################
##### Node.js v22.x #####
#########################
# https://github.com/nodesource/distributions/blob/master/scripts/rpm/setup_22.x
echo "=> INSTALL NODEJS";
NODE_VERSION="22.x";
cat << NODEJS > /etc/yum.repos.d/nodesource-nodejs.repo;
[nodesource-nodejs]
name=Node.js Packages for Linux RPM based distros - ${ARCH}
baseurl=https://rpm.nodesource.com/pub_${NODE_VERSION}/nodistro/nodejs/${ARCH}
priority=9
enabled=1
gpgcheck=1
gpgkey=https://rpm.nodesource.com/gpgkey/ns-operations-public.key
module_hotfixes=1
NODEJS
rpm --import https://rpm.nodesource.com/gpgkey/ns-operations-public.key;
yum check-update;
yum install -y nodejs;
echo "Node.js Version";
node --version;
echo "npm Version";
npm --version;

##################
##### Golang #####
##################
GO_VERSION="1.24.3";
echo "=> INSTALL GOLANG";
echo "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH2}.tar.gz";
wget --quiet -O golang.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH2}.tar.gz";
tar -C /usr/local -xzf golang.tar.gz;
rm ./golang.tar.gz;
echo 'export PATH="${PATH}:/usr/local/go/bin";' >> /etc/profile;
/usr/local/go/bin/go version;

#############################
##### Container Builder #####
#############################
if ! grep amazon:amazon_linux:2023 /etc/os-release; then
  yum install -y podman podman-docker;
  systemctl enable podman --now;
  touch /etc/containers/nodocker;
else
  yum install -y docker;
  systemctl enable docker --now;
fi
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account');
AWS_REGION=$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]');
cat << EOF > /root/container_build.sh;
#!/usr/bin/env bash

# Verify arguments
if [ -z \$1 ]; then
  echo "Usage: ./\${0} IMAGE_NAME IMAGE_TAG";
  exit 1;
fi
if [ -z \$2 ]; then
  echo "Usage: ./\${0} IMAGE_NAME IMAGE_TAG";
  exit 1;
fi

# Log into AWS ECR (Elastic Container Registry)
aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com";
# Build and Push
docker build -t "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/\${1}:\${2}" .;
docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/\${1}:\${2}";
EOF
chmod +x /root/container_build.sh;

##########################
##### Docker Compose #####
##########################
# Alternative Path: /usr/local/lib/docker/cli-plugins
# https://github.com/docker/compose/releases
DOCKER_COMPOSE_VERSION="v2.36.0";
# if grep amazon:amazon_linux:2023 /etc/os-release; then
echo "=> INSTALL DOCKER COMPOSE ${DOCKER_COMPOSE_VERSION} on AL2023";
mkdir -p /usr/libexec/docker/cli-plugins/;
wget --quiet -O /usr/libexec/docker/cli-plugins/docker-compose "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${ARCH}";
chmod +x /usr/libexec/docker/cli-plugins/docker-compose;

# # Optional - Used for Testing
# yum install nginx -y;
# systemctl enable nginx --now;

# All Done
echo "=> ALL DONE";
