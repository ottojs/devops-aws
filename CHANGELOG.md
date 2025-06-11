# Releases

## Unreleased v0.9.0

- Fix: Output ordering of VPC subnets
- Edit: Improve module sns
- Edit: Default log retention changed from 365 days to 400 days
- Edit: Refine VPC Flow Logs IAM Role/Policy
- Edit: EC2 Monitoring enabled, EBS Optimization enabled, Dev Mode, remove AZ, Add Recovery Alarm
- Edit: ASG EBS Optimized, Dynamic AMI Lookup, Encrypted Disk, Health Check, KMS Encryption, Dev Mode
- Edit: ECS Cluster to better utilize resources, Dev Mode, CloudWatch Log Group
- Edit: Load Balancer, more restrictive TLS/ciphers, cross-zone load balancing
- Edit: WAF: rate limits, SQLi/Unix/Linux rule sets
- Add: VPC Endpoints to modules/vpc
- Add: Module for AMI Lookup
- Add: Enable switches for IGW/NAT to modules/vpc (default: false)
- Add: Module security_global
- Dependencies: Upgrade provider aws to 6.0.0-beta3

## 2025-05-21 v0.8.0

- Breaking: Module ecs_service now passes secrets as a list/array
- Fix: Upgrade EC2 SSM policy from AmazonEC2RoleforSSM to AmazonSSMManagedInstanceCore
- Fix: Refine Debian AMI name filter to avoid backports
- Add: Module db_mariadb for MariaDB instance
- Add: Support for Debian 11 (bullseye) and 12 (bookworm)
- Add: Security Module - ResourceExplorer
- Add: Module bucket_private log bucket can now receive CloudWatch logs
- Add: Module ecs_service supports skeleton creation
- Add: Module ecs_service supports use_registry to re-use another container registry
- Add: Module ecs_service supports replicas (default 1)
- Add: Database tools to the bastion hosts init scripts (debian/al2023)
- Add: Common tools to the bastion hosts init scripts (debian/al2023)
- Add: Tags to VPC Flow Logs, VPC IAM Roles, and SSM IAM Roles
- Add: Variable for container command to execute in ECS
- Add: VPC outputs NAT EIP
- Add: Valkey module outputs endpoint address
- Add: Load Balancer now accepts security group IDs
- Add: Bastion RHEL9 Golang
- Add: Bastion RHEL9 Docker Compose Plugin
- Add: Bastion Debian 11/12 Golang 1.24.3 and Node.js v22.x
- Add: Bastion Rocky Linux 9 (RHEL9 base)
- Edit: Always adding private DNS record for ECS service
- Edit: Moving SSM settings out of VPC to its own module to prevent conflicts
- Edit: Terraform State Bucket Name tag and deletion protection
- Edit: Changing default Bastion machine type from "t3" to "t3a" for small cost savings
- Dependencies: Upgrade provider aws to v5.97.0

## 2025-04-06 v0.7.0

- Fix: Module "bucket_private" to stay current
- Add: Module "security" with AWS Config, Security Hub, GuardDuty, Inspector, Detective, etc.
- Add: Cloudflare Security Group for HTTP/HTTPS
- Edit: Switching default region from us-east-2 to us-east-1
- Edit: Upgrading RHEL9 AMI from v9.4.x to v9.5.x
- Dependencies: Upgrade provider aws to v5.94.1

## 2025-03-09 v0.6.0

It is still _not recommended_ to use this in production (yet).

- New: WAF on Public Load Balancer(s)
- New: RHEL 9 Support (v9.4)
- New: APP_VERSION environment variable for ECS to match container image tag
- New: EC2 Machine parameter AMI
- New: EC2 Machine parameter disk_size
- New: EC2 Machine dynamic AMI
- New: AWS Certificate Manager automatic wildcard certificate (incl DNS validation in Route53)
- New: DNS Record for DMARC
- New: DNS Record for Valkey (internal/private)
- New: DNS Record for PostgreSQL (internal/private)
- New: Account High Password Requirements
- New: ECS Example Service Worker
- New: ECS Service parameter to specify inline IAM policy
- New: ECS Service parameter "create_registry"
- New: IAM Policy to block non-US regions (not attached)
- New: Self-signed TLS/SSL Certificate Script
- Edit: EC2 Machine Naming Pattern
- Edit: EC2 Machine "access" ("private"/"public") has been changed to "public" (true/false)
- Upgrade: Provider aws to v5.90.0
- Remove: ECS EC2 Example (Commented Out)

## 2025-02-23 v0.5.0

Fourth release for testing!
It is still _not recommended_ to use this in production (yet).

- New: 03_apps directory
- New: ECS Service option fault_injection
- New: VPC Endpoints option (experimental, untested)
- Edit: VPC Default Network ACL to have individual rules (idempotency)
- Edit: Merge module ecs_cron into ecs_service
- Edit: Security Group names
- Upgrade: PostgreSQL default version to v17.4
- Upgrade: Amazon Linux 2023 AMI to v20250218
- Upgrade: Container image node to v22.14.0
- Upgrade: Provider aws to v5.88.0

## 2025-02-16 v0.4.0

Third release for testing!
It is still _not recommended_ to use this in production (yet).

- Fix: ECS Execution and Task Role (same)
- Fix: OpenSearch now uses private subnets in the example
- Fix: Provider aws upgraded to v5.87.0 (v5.86.0 was removed)
- New: OpenSearch Audit Logs are now enabled by default
- New: Load Balancer dynamic health check path
- New: Module Route 53 for Root Domain
- New: Tags on Subnets "Public" => true/false
- Edit: Upgraded AL2023 AMI for EC2 Hosts
- Edit: NACLs and Security Groups to be more secure
- Edit: OpenSearch password now uses variable
- Edit: Simplifying tags on SNS module
- Edit: Move `userdata` to root for use in multiple accounts
- Removed: Node.js Code for SQS (another repo)
- Removed: Route 53 Subdomain Zone

## 2025-02-09 v0.3.0

Second release for testing!
It is still _not recommended_ to use this in production (yet).

- Fix: ECS Cron Tasks
- New: CloudWatch Alerts for RDS PostgreSQL
- New: ECS can use dynamic envvars/secrets provided
- New: Module for SES
- New: Module for SQS
- New: Module for Valkey ElastiCache Cluster
- New: Module for OpenSearch
- New: Node.js Code for SQS
- New: Load Balancer Access and Connection logs
- New: Route 53 Zones
- Edit: Load Balancer option: Public/Private
- Edit: Move from tag_app to tag map
- Edit: Remove most instances of hard-coded region
- Edit: Upgraded AL2023 AMI for EC2 Hosts

## 2025-02-02 v0.2.0

First release for testing!
It is still _not recommended_ to use this in production (yet).

Supports the high-level features below:

- VPC Core Networks
- S3 Buckets
- EC2 Machines for Web SSH (SSM)
- EC2 AutoScaling Groups
- Load Balancers
- ECS Provider Fargate
- ECS Provider EC2
- ECS Cron Schedules
- Database PostgreSQL
- Database Redis/Valkey (Valkey not yet supported by provider)
- VPN (optional, disabled by default)
- SNS Topics
