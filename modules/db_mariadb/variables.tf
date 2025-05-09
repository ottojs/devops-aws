
# General Documentation
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateDBInstance.Settings.html

data "aws_sns_topic" "devops" {
  name = "devops"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone
data "aws_route53_zone" "root" {
  name         = "${var.root_domain}."
  private_zone = true
}

# MiB and GiB do not align well with console graphs
locals {
  mb = 1000000    # 1048576 Mebibytes
  gb = 1000000000 # 1073741824 Gibibytes
}

variable "name" {
  type = string
}

# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MariaDB.Concepts.VersionMgmt.html
# aws rds describe-db-engine-versions  --engine mariadb | jq '.DBEngineVersions[].EngineVersion'
variable "engine_version" {
  type    = string
  default = "11.4.5"
}

# https://aws.amazon.com/rds/instance-types/
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.Types.html
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.Summary.html
variable "machine_type" {
  type    = string
  default = "db.t4g.micro"
}

variable "kms_key" {
  type = object({
    id  = string
    arn = string
  })
}

variable "vpc" {
  type = object({
    id         = string
    cidr_block = string
  })
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "root_domain" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "db_name" {
  type = string
}

variable "storage_max" {
  type    = number
  default = 1000
}

variable "backup_days" {
  type    = number
  default = 7
}

variable "alert_cpu" {
  type    = number
  default = 60 # Percent
}

variable "alert_memory" {
  type    = number
  default = 256 # MB
}

variable "alert_disk_space" {
  type    = number
  default = 5 # GB
}

variable "alert_write_iops" {
  type    = number
  default = 20
}

variable "alert_read_iops" {
  type    = number
  default = 100
}

variable "tags" {
  type = map(string)
}
