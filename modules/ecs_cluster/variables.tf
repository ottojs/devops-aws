
variable "name" {
  type = string
}

variable "kms_key" {
  type = object({
    id  = string
    arn = string
  })
}

variable "log_retention_days" {
  type = number
}

variable "asg" {
  type = object({
    name                  = string
    arn                   = string
    protect_from_scale_in = bool
  })
  default = {
    name                  = "default"
    arn                   = "default"
    protect_from_scale_in = false
  }
}

# FARGATE or EC2
variable "type" {
  type = string
}

variable "tags" {
  type = map(string)
}
