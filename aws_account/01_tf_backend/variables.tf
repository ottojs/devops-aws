
variable "iam_user" {
  type    = string
  default = "myiamuser"
}

# This is used to make S3 bucket names more unique
# It will be appended to the end of the name
variable "random_id" {
  type    = string
  default = "RANDOM-ID-HERE"
}

variable "tag_app" {
  type    = string
  default = "DEVOPS-CORE"
}
