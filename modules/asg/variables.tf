
locals {
  subnet_ids = [for s in var.subnets : s.id]
}

variable "name" {
  type = string
}

variable "subnets" {
  type = list(object({ id = string }))
}

variable "instance_type" {
  type = string
}

variable "ami" {
  type    = string
  default = ""
}

variable "userdata_file" {
  type = string
}

variable "iam_instance_profile" {
  type = object({
    name = string
    arn  = string
  })
}

variable "security_groups" {
  type = list(string)
}

variable "count_min" {
  type    = number
  default = 1
}

variable "count_max" {
  type    = number
  default = 1
}

variable "seconds_warmup" {
  type    = number
  default = 120
}

variable "seconds_cooldown" {
  type    = number
  default = 120
}

variable "seconds_health" {
  type    = number
  default = 120
}

variable "scale_up_cpu" {
  type    = number
  default = 60
}

variable "tags" {
  type = map(string)
}
