#!/usr/bin/env bash

# Settings
export ARCH=$(arch);
if [ $ARCH == "aarch64" ]; then
  export ARCH="arm64";
fi

echo "=> UPGRADE PACKAGES";
yum update -y;

######################
##### Amazon SSM #####
######################
# https://docs.aws.amazon.com/systems-manager/latest/userguide/verify-agent-signature.html
# We hardcode this for security purposes, because a dynamic URI download could change
echo "=> INSTALL AMAZON SSM";
cat << EOF > ./amazon-ssm-agent.gpg;
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2.0.22 (GNU/Linux)

mQENBGTtIoIBCAD2M1aoGIE0FXynAHM/jtuvdAVVaX3Q4ZejTqrX+Jq8ElAMhxyO
GzHu2CDtCYxtVxXK3unptLVt2kGgJwNbhYC393jDeZx5dCda4Nk2YXX1UK3P461i
axuuXRzMYvfM4RZn+7bJTu635tA07q9Xm6MGD4TCTvsjBfViOxbrxOg5ozWbJdSw
fSR8MwUrRfmFpAefRlYfCEuZ8FHywa9U6jLeWt2O/kqrZliJOAGjGzXtB7EZkqKb
faCCxikjjvhF1awdEqSK4DQorC/OvQc4I5kP5y2CJbtXvXO73QH2yE75JMDIIx9x
rOsIRUoSfK3UrWaOVuAnEEn5ueKzZNqGG1J1ABEBAAG0J1NTTSBBZ2VudCA8c3Nt
LWFnZW50LXNpZ25lckBhbWF6b24uY29tPokBPwQTAQIAKQUCZO0iggIbLwUJAsaY
gAcLCQgHAwIBBhUIAgkKCwQWAgMBAh4BAheAAAoJELwfSVyX3QTt+icH/A//tJsW
I+7Ay8FGJh8dJPNy++HIBjVSFdGNJFWNbw1Z8uZcazHEcUCH3FhW4CLQLTZ3OVPz
qvFwzDtRDVIN/Y9EGDhLMFvimrE+/z4olWsJ5DANf6BnX8I5UNIcRt5d8SWH1BEJ
2FWIBZFgKyTDI6XzRC5x4ahtgpOVAGeeKDehs+wh6Ga4W0/K4GsviP1Kyr+Ic2br
NAIq0q0IHyN1q9zam3Y0+jKwEuNmTj+Bjyzshyv/X8S0JWWoXJhkexkOvWeBYNNt
5wI4QcSteyfIzp6KlQF8q11Hzz9D9WaPfcBEYyhq7vLEARobkbQMBzpkmaZua241
0RaWG50HRvrgm4aJAhwEEAECAAYFAmTtIoMACgkQfdCXo9rX9fwwqBAAzkTgYJ38
sWgxpn7Ux/81F2BWR1sVkmP79i++fXyJlKI8xtcJFQZhzeUos69KBUCy7mgx5bYU
P7NA5o9DUbwz/QS0i1Cqm4+jtFlX0MXe4FikXcqfDPnnzN8mVB2H+fa43iHR1PuH
GgUWuNdxzSoIYRmLZXWmeN5YXPcmixlhLzcE2TOQn1mOKcu2fKdLtBQ8KiEkmjiu
naoLxnUcyk1zMhaha+LzEkQdOyasix0ggylN2ViWVnlmfy0niuXDxW0qZWPdLStF
OODiX3iqGmkH3rDfy6nvxxBR4GIs+MGD72fpWzzrINDgkGI2i2t1+0AX/mps3aTy
+ftlgrim8stYWB58XXDAb0vad06sNye5/zDzfr0I9HupJrTzFhaYJQjWPaSlINto
LDJnBXohiUIPRYRcy/k012oFHDWZHT3H6CyjK9UD5UlxA9H7dsJurANs6FOVRe+7
34uJyxDZ/W7zLG4AVG0zxibrUSoaJxwcOjVPVsQAlrwG/GTs7tcAccsJqbJ1Py/w
9AgJl8VU2qc8POsHNXk348gjP7C8PDnGMpZFzr9f5INctRushpiv7onX+aWJVX7T
n2uX/TP3LCyH/MsrNJrJOQnMYFRLQitciP0E+F+eA3v9CY6mDuyb8JSx5HuGGUsG
S4bKBOcA8vimEpwPoT8CE7fdsZ3Qkwdu+pw=
=zr5w
-----END PGP PUBLIC KEY BLOCK-----
EOF
rpm --import amazon-ssm-agent.gpg;
#sudo yum install -y "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_${ARCH}/amazon-ssm-agent.rpm";
wget --quiet "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_${ARCH}/amazon-ssm-agent.rpm";
wget --quiet "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_${ARCH}/amazon-ssm-agent.rpm.sig";
# TODO: Exit on failure
rpm --checksig ./amazon-ssm-agent.rpm.sig ./amazon-ssm-agent.rpm;
#
# Debug Commands
# systemctl status amazon-ssm-agent;
# journalctl -u amazon-ssm-agent -n 50;

# Capture SSM Agent Version
# It's core to connecting and may be useful for debugging
# v3.3.987.0 - 2024-12-08
amazon-ssm-agent --version > /home/ec2-user/amazon-ssm-agent-info.txt;

##################
##### Docker #####
##################
# Used for container builds (ECR, ECS, etc.)
yum install -y docker;

#########################
##### Node.js v22.x #####
#########################
# https://github.com/nodesource/distributions/blob/master/scripts/rpm/setup_22.x
echo "=> INSTALL NODEJS";
NODE_VERSION="22.x";
SYS_ARCH=$(uname -m);
cat << NODEJS > /etc/yum.repos.d/nodesource-nodejs.repo;
[nodesource-nodejs]
name=Node.js Packages for Linux RPM based distros - ${SYS_ARCH}
baseurl=https://rpm.nodesource.com/pub_${NODE_VERSION}/nodistro/nodejs/${SYS_ARCH}
priority=9
enabled=1
gpgcheck=1
gpgkey=https://rpm.nodesource.com/gpgkey/ns-operations-public.key
module_hotfixes=1
NODEJS
rpm --import https://rpm.nodesource.com/gpgkey/ns-operations-public.key;
yum check-update;
yum install -y nodejs;
node --version;
npm --version;

# All Done
echo "=> ALL DONE";
