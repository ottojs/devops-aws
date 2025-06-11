data "aws_caller_identity" "current" {}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone
data "aws_route53_zone" "root" {
  name         = "${var.root_domain}."
  private_zone = false
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate
data "aws_acm_certificate" "main" {
  domain   = "*.${var.root_domain}"
  statuses = ["ISSUED"]
}

locals {
  fqdn = "${var.domain_record}.${var.root_domain}"
}

# TODO: Replication
# variable "region" {
#   type    = string
# }

variable "name" {
  type        = string
  description = "Bucket name that must be globally unique"
}

variable "log_bucket_id" {
  type        = string
  description = "S3 Log Bucket ID"
}

variable "delete_days_files" {
  type        = number
  description = "Delete ALL files after X days. WARNING: Keep at 0 for public websites to prevent content deletion"
  default     = 0 # Disabled - DO NOT change for public website buckets
}

variable "delete_days_old_versions" {
  type    = number
  default = 90
}

variable "delete_days_multipart" {
  type    = number
  default = 3
}

variable "error_page_path" {
  type        = string
  description = "Path to custom error page (e.g., /error.html)"
  default     = "/error.html"
}

variable "error_caching_min_ttl" {
  type        = number
  description = "Minimum TTL in seconds for caching error pages (403/404)"
  default     = 300
}

variable "cloudfront_comment" {
  type        = string
  description = "Comment for the CloudFront distribution"
  default     = ""
}

variable "cloudfront_price_class" {
  type        = string
  description = "CloudFront price class for distribution"
  default     = "PriceClass_100"

  # Price classes (from cheapest to most expensive):
  # "PriceClass_100"    = US, Canada, Europe (lowest cost)
  # "PriceClass_200"    = US, Canada, Europe, Asia, Middle East, Africa
  # "PriceClass_All"    = All edge locations (best performance)
}

variable "enable_cors" {
  type        = bool
  description = "Enable CORS configuration for the bucket"
  default     = false
}

variable "cors_allowed_origins" {
  type        = list(string)
  description = "List of allowed origins for CORS (e.g., ['https://example.com'])"
  default     = ["*"]
}

variable "cors_allowed_methods" {
  type        = list(string)
  description = "List of allowed HTTP methods for CORS"
  default     = ["GET", "HEAD"]
}

variable "cors_allowed_headers" {
  type        = list(string)
  description = "List of allowed headers for CORS"
  default     = ["*"]
}

variable "cors_expose_headers" {
  type        = list(string)
  description = "List of headers to expose in CORS response"
  default     = ["ETag"]
}

variable "cors_max_age_seconds" {
  type        = number
  description = "Time in seconds that browser can cache CORS response"
  default     = 3600
}

variable "enable_cloudfront_cors" {
  type        = bool
  description = "Enable CORS headers at CloudFront level (applies to entire distribution)"
  default     = false
}

variable "cloudfront_cors_allowed_origins" {
  type        = list(string)
  description = "List of allowed origins for CloudFront CORS"
  default     = ["*"]
}

variable "cloudfront_cors_allowed_methods" {
  type        = list(string)
  description = "List of allowed HTTP methods for CloudFront CORS"
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "cloudfront_cors_allowed_headers" {
  type        = list(string)
  description = "List of allowed headers for CloudFront CORS"
  default     = ["*"]
}

variable "cloudfront_cors_expose_headers" {
  type        = list(string)
  description = "List of headers to expose in CloudFront CORS response"
  default     = ["ETag", "Content-Type", "Content-Length"]
}

variable "cloudfront_cors_max_age" {
  type        = number
  description = "Time in seconds that browser can cache CloudFront CORS response"
  default     = 86400
}

variable "content_security_policy_directives" {
  type        = list(string)
  description = "List of Content Security Policy directives. Empty list disables CSP header."
  default     = []

  # Example usage:
  # content_security_policy_directives = [
  #   "default-src 'self'",
  #   "script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net",
  #   "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
  #   "font-src 'self' https://fonts.gstatic.com",
  #   "img-src 'self' data: https:",
  #   "connect-src 'self'",
  #   "frame-ancestors 'none'",
  #   "base-uri 'self'",
  #   "form-action 'self'"
  # ]
}

variable "permissions_policy_directives" {
  type        = list(string)
  description = "List of Permissions Policy directives. Each will have =() appended to disable the feature."
  default = [
    "accelerometer",
    "ambient-light-sensor",
    "autoplay",
    "battery",
    "camera",
    "cross-origin-isolated",
    "display-capture",
    "document-domain",
    "encrypted-media",
    "execution-while-not-rendered",
    "execution-while-out-of-viewport",
    "fullscreen",
    "geolocation",
    "gyroscope",
    "keyboard-map",
    "magnetometer",
    "microphone",
    "midi",
    "navigation-override",
    "payment",
    "picture-in-picture",
    "publickey-credentials-get",
    "screen-wake-lock",
    "sync-xhr",
    "usb",
    "web-share",
    "xr-spatial-tracking"
  ]
}

variable "domain_record" {
  type        = string
  description = "static"
  default     = null
}

variable "root_domain" {
  type        = string
  description = "domain_name"
  default     = null
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of ACM certificate for custom domain (must be in us-east-1)"
  default     = null
}

variable "route53_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for custom domain"
  default     = null
}

variable "create_route53_record" {
  type        = bool
  description = "Whether to create Route53 record for custom domain"
  default     = true
}

variable "cloudfront_cache_policy_id" {
  type        = string
  description = "CloudFront cache policy ID. Default: Managed-CachingOptimized for static content"
  default     = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized

  # Other useful managed cache policies:
  # "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" = CachingDisabled
  # "b2884449-e4de-46a7-ac36-70bc7f1ddd6d" = CachingOptimizedForUncompressedObjects
  # "08627262-05a9-4f76-9ded-b50ca2e3a84f" = Elemental-MediaPackage
}

variable "cloudfront_origin_request_policy_id" {
  type        = string
  description = "CloudFront origin request policy ID. Default: Managed-CORS-S3Origin"
  default     = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # Managed-CORS-S3Origin

  # Other useful managed origin request policies:
  # "216adef6-5c7f-47e4-b989-5492eafa07d3" = AllViewer (forwards all headers/cookies)
  # "59781a5b-3903-41f3-afcb-af62929ccde1" = CORS-CustomOrigin
  # "775133bc-15f2-49f9-abea-afb2e0bf67d2" = UserAgentRefererHeaders
}

variable "cloudfront_minimum_protocol_version" {
  type        = string
  description = "Minimum TLS protocol version for CloudFront. TLSv1.2_2021 supports only TLS 1.2 and 1.3"
  default     = "TLSv1.2_2021"

  # Available options (from least to most secure):
  # "TLSv1"        = TLS 1.0, 1.1, 1.2 (deprecated, insecure)
  # "TLSv1_2016"   = TLS 1.0, 1.1, 1.2 with slightly better ciphers
  # "TLSv1.1_2016" = TLS 1.1, 1.2
  # "TLSv1.2_2018" = TLS 1.2 only with older cipher suites
  # "TLSv1.2_2019" = TLS 1.2 only with better cipher suites
  # "TLSv1.2_2021" = TLS 1.2, 1.3 only with modern cipher suites (recommended)
}

variable "dev_mode" {
  type        = bool
  description = "Enable development mode (allows force_destroy on S3 bucket)"
  default     = false
}

variable "enable_cloudwatch_alarms" {
  type        = bool
  description = "Enable CloudWatch alarms for 4xx/5xx errors"
  default     = true
}

variable "alarm_sns_topic_arn" {
  type        = string
  description = "SNS topic ARN for CloudWatch alarm notifications"
  default     = null
}

variable "alarm_4xx_threshold" {
  type        = number
  description = "Threshold for 4xx error rate alarm (percentage)"
  default     = 5
}

variable "alarm_5xx_threshold" {
  type        = number
  description = "Threshold for 5xx error rate alarm (percentage)"
  default     = 1
}

variable "alarm_evaluation_periods" {
  type        = number
  description = "Number of periods to evaluate for alarm"
  default     = 2
}

variable "alarm_period" {
  type        = number
  description = "Period in seconds for alarm evaluation"
  default     = 300
}

variable "enable_budget_alerts" {
  type        = bool
  description = "Enable AWS Budget alerts for cost monitoring"
  default     = false
}

variable "monthly_budget_amount" {
  type        = number
  description = "Monthly budget amount in USD for CloudFront costs"
  default     = 100
}

variable "budget_alert_thresholds" {
  type        = list(number)
  description = "List of percentage thresholds for budget alerts"
  default     = [50, 80, 100, 120]
}

variable "budget_alert_email" {
  type        = string
  description = "Email address for budget alert notifications"
  default     = null
}

variable "budget_time_unit" {
  type        = string
  description = "Time unit for budget (MONTHLY, QUARTERLY, ANNUALLY)"
  default     = "MONTHLY"
}

variable "enable_anomaly_detection" {
  type        = bool
  description = "Enable AWS Cost Anomaly Detection for unusual spending patterns"
  default     = false
}

variable "anomaly_threshold" {
  type        = number
  description = "Threshold in USD for anomaly detection alerts"
  default     = 10
}

variable "tags" {
  type = map(string)
}
