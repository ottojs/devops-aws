# Releases

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
