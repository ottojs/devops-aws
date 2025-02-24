
# This is used to make S3 bucket names more unique
# It will be appended to the end of the name
variable "random_id" {
  type    = string
  default = "RANDOM-ID-HERE-FROM-STEP-1"
}

variable "root_domain" {
  type    = string
  default = "example.com"
}

# password must contain at least one:
# - uppercase letter
# - lowercase letter
# - number
# - special character
variable "opensearch_password" {
  type    = string
  default = "REPLACEME"
}

# You can use "checksum" to track and dynamically update tags
# If you change the checksum and immediately run an "apply"
# You'll be able to detect which resources are not in the pipeline
variable "tags" {
  type = map(string)
  default = {
    App      = "DEVOPS-APPS"
    Owner    = "otto"
    Checksum = "abc123"
  }
}
