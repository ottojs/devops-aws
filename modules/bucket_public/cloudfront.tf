
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution
resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = [local.fqdn]
  comment             = var.cloudfront_comment != "" ? var.cloudfront_comment : "Distribution for ${var.name}"

  # AWS Shield Standard is automatically enabled for CloudFront distributions at no additional cost
  # It provides protection against common DDoS attacks
  # For enhanced DDoS protection, consider AWS Shield Advanced (paid service)
  # Shield Standard provides:
  # - SYN/UDP floods protection
  # - Reflection attacks protection
  # - HTTP slow reads and other layer 7 attacks protection
  # - Automatic inline mitigation without latency impact

  origin {
    domain_name              = aws_s3_bucket.main.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.main.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.main.id}"

    # Modern Cache Policy approach (replaces legacy forwarded_values)
    # AWS Managed Cache Policies are pre-configured and optimized by AWS
    # 
    # Documentation:
    # - Main guide: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html
    # - Cache policies list: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html#managed-cache-policies-list
    # - Origin request policies: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-origin-request-policies.html#managed-origin-request-policies-list
    # - CLI: aws cloudfront list-cache-policies --type managed

    # Cache Policy: Determines what CloudFront includes in the cache key
    # Managed-CachingOptimized (658327ea-f89d-4709-b370-b4c650ea3fcf):
    # - Ignores query strings (good for static sites)
    # - Ignores cookies (improves cache hit ratio)
    # - Uses Accept-Encoding header for compression support
    # - Ideal for static websites, images, CSS, JS files
    cache_policy_id = var.cloudfront_cache_policy_id

    # Origin Request Policy: Determines what CloudFront forwards to origin
    # Managed-CORS-S3Origin (88a5eaf4-2fd4-4709-b370-b4c650ea3fcf):
    # - Forwards necessary headers for S3 CORS
    # - Includes Origin, Access-Control headers
    # - Does NOT forward cookies or most headers (better for S3)
    origin_request_policy_id = var.cloudfront_origin_request_policy_id

    # TTL values are now controlled by the cache policy
    # These min/default/max TTL settings are IGNORED when using cache_policy_id
    # (Keeping them commented for reference)
    # min_ttl     = 0      # Minimum seconds to cache
    # default_ttl = 3600   # Default when origin doesn't specify
    # max_ttl     = 86400  # Maximum seconds to cache

    viewer_protocol_policy = "redirect-to-https"

    # Security headers
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security.id

    # Note: The old forwarded_values block is replaced by cache_policy_id
    # This was the legacy way:
    # forwarded_values {
    #   query_string = false
    #   cookies {
    #     forward = "none"
    #   }
    # }
  }

  # Logging
  logging_config {
    bucket          = "${var.log_bucket_id}.s3.amazonaws.com"
    prefix          = "cloudfront/${var.name}/"
    include_cookies = false
  }

  # Price class configuration
  price_class = var.cloudfront_price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.main.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = var.cloudfront_minimum_protocol_version
  }

  # Custom error responses
  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = var.error_page_path
    error_caching_min_ttl = var.error_caching_min_ttl
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = var.error_page_path
    error_caching_min_ttl = var.error_caching_min_ttl
  }

  custom_error_response {
    error_code            = 500
    error_caching_min_ttl = 10
    response_code         = 500
    response_page_path    = var.error_page_path
  }

  custom_error_response {
    error_code            = 502
    error_caching_min_ttl = 10
    response_code         = 502
    response_page_path    = var.error_page_path
  }

  custom_error_response {
    error_code            = 503
    error_caching_min_ttl = 10
    response_code         = 503
    response_page_path    = var.error_page_path
  }

  custom_error_response {
    error_code            = 504
    error_caching_min_ttl = 10
    response_code         = 504
    response_page_path    = var.error_page_path
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control
resource "aws_cloudfront_origin_access_control" "main" {
  name                              = var.name
  description                       = var.name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_response_headers_policy
resource "aws_cloudfront_response_headers_policy" "security" {
  name = "${replace(var.name, ".", "-")}-security-headers"

  security_headers_config {
    # Strict Transport Security
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      override                   = true
    }

    # X-Content-Type-Options
    content_type_options {
      override = true
    }

    # X-Frame-Options
    frame_options {
      frame_option = "DENY"
      override     = true
    }

    # X-XSS-Protection
    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }

    # Referrer-Policy
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
  }

  # CORS Configuration at CloudFront level
  dynamic "cors_config" {
    for_each = var.enable_cloudfront_cors ? [1] : []
    content {
      access_control_allow_credentials = false

      access_control_allow_headers {
        items = var.cloudfront_cors_allowed_headers
      }

      access_control_allow_methods {
        items = var.cloudfront_cors_allowed_methods
      }

      access_control_allow_origins {
        items = var.cloudfront_cors_allowed_origins
      }

      access_control_expose_headers {
        items = var.cloudfront_cors_expose_headers
      }

      access_control_max_age_sec = var.cloudfront_cors_max_age

      origin_override = true
    }
  }

  # Custom Headers Configuration
  custom_headers_config {
    # Content Security Policy (only if provided)
    dynamic "items" {
      for_each = length(var.content_security_policy_directives) > 0 ? [1] : []
      content {
        header   = "Content-Security-Policy"
        value    = join("; ", var.content_security_policy_directives)
        override = true
      }
    }

    # X-Permitted-Cross-Domain-Policies - Prevents Flash/PDF cross-domain requests
    items {
      header   = "X-Permitted-Cross-Domain-Policies"
      value    = "none"
      override = true
    }

    # Permissions-Policy (formerly Feature-Policy) - Controls browser features
    items {
      header   = "Permissions-Policy"
      value    = join(", ", [for directive in var.permissions_policy_directives : "${directive}=()"])
      override = true
    }
  }
}
