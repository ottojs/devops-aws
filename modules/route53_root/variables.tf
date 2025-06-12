
variable "vpc" {
  type = object({
    id = string
  })
}

variable "root_domain" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "create_dmarc_record" {
  description = "Whether to create the _dmarc TXT record for email authentication"
  type        = bool
  default     = true
}
