# Boilerplate DevOps AWS

## Overview

Example production-grade deployment in Amazon Web Services.
Use it as-is or as a reference for how the pieces fit together.

## Unstable Software

**WARNING** This is a work-in-progress and should not be used yet.

## Disclaimer

Using this software will incur costs on your AWS account. You are solely responsible for your use of this code (monitoring costs, adjusting settings, paying invoices, etc).

## Instructions

### Part 1 - S3 Backend for Terraform State

- Ensure you have an AWS IAM user created with "Administrator" privileges (or create a more locked-down version)
- Ensure you have AWS configured with this IAM user (`aws configure` to generate `~/.aws/credentials`)
- You can rename or copy the `aws_account` directory to better describe your account(s)
- If you use these scripts with multiple accounts, each should have its own directory
- Change to directory `aws_account/01_tf_backend/`
- Edit `variables.tf` with your IAM user name
- Edit `variables.tf` `random_id` with a random string to prevent global S3 naming conflicts
- If you use these scripts with multiple accounts, each should have a unique `random_id`
- Run `tofu init -upgrade`
- Run `tofu apply`
- Review and Approve changes

### Part 2 - Core Infrastructure

- Change to directory `aws_account/02_core/`
- Edit `providers.tf` section `backend "s3"` with **the same** random ID string from Step 1
- Edit `variables.tf` with `allowed_cidrs` to your IP address or change to empty array/list
- Edit `variables.tf` with your local SSH key
- Edit `variables.tf` with **the same** random string ID from Step 1
- Edit `variables.tf` with your root domain name
- Add a hosted zone for your domain in Route 53
- Point your root domain name servers to Route 53 hosted zone values (NS Records)
- Add a wildcard certificate for your domain in [AWS Certificate Manager](https://us-east-2.console.aws.amazon.com/acm/home?region=us-east-2#/certificates/list). Wait for "Create records in Route 53" button and click it
- Review the modules listed and remove any you will not use (Database, Cache, EC2 Machines, etc.)
- You may need to tweak some settings to you liking

### Optional - Enable VPN

Generally, you should connect to your EC2 instances through the AWS Console with SSM (Systems Manager). This will provide an SSH session in your browser that stores logs of commands. You can also use SSM for Windows RDP using Fleet Manager.

However, if you really need a VPN connection into your AWS VPC, you can enable a VPN for an additional cost. This uses an AWS service based on OpenVPN so you can use the vanilla/official OpenVPN client program to connect.

- Change to directory `aws_account/02_core/`
- Uncomment the VPN resource block
- Uncomment the VPN subnet (above the VPN resource block)
- Run `./script_generate_cert.sh`
- Run `tofu init -upgrade`
- Run `tofu apply`
- Review and Approve changes
- Go to section "VPC => Client VPN endpoints" in the AWS Console
- Click button "Download client configuration"
- Place this file in `aws_account/02_core/downloaded-client-config.ovpn`
- Run `./script_vpn_inject.sh`
- The file `downloaded-client-config.ovpn` is now ready to be imported into OpenVPN
- [Download the OpenVPN client](https://openvpn.net/client/) on their website (if needed)

### Publishing a Container Image

Edit the below commands to match your account ID, region, etc.  
There's also a helper script in the bastion host.

#### Podman / Docker

```bash
aws ecr get
aws ecr get-login-password --region "REGION" | docker login --username AWS --password-stdin "ACCOUNTID.dkr.ecr.REGION.amazonaws.com";
podman build -t ACCOUNTID.dkr.ecr.REGION.amazonaws.com/NAME:TAG .
podman push ACCOUNTID.dkr.ecr.REGION.amazonaws.com/NAME:TAG
```

## TODO

- Increase KMS Key deletion to max days for grace period
- Enable deletion protection on Databases, S3 (non-empty), etc.
