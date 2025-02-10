# Releases

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
