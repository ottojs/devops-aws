
# General Documentation
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateDBInstance.Settings.html
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html

locals {
  subnet_ids = [for s in var.subnets : s.id]
}

variable "name" {
  type = string
}

# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.Concepts.General.DBVersions.html
# https://docs.aws.amazon.com/AmazonRDS/latest/PostgreSQLReleaseNotes/postgresql-release-calendar.html
# aws rds describe-db-engine-versions  --engine postgres | jq '.DBEngineVersions[].EngineVersion'
variable "engine_version" {
  type    = string
  default = "17.2"
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

# TODO
variable "subnets" {
  default = []
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

variable "tag_app" {
  type    = string
  default = "SOMEAPP"
}
