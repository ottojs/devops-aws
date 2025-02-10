
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "opensearch" {
  name        = "secgrp-db-${var.name}"
  vpc_id      = var.vpc.id
  description = "Database OpenSearch"

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc.cidr_block]
  }

  tags = merge(var.tags, {
    Name = "secgrp-db-${var.name}"
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "index_slow_logs" {
  name              = "/aws/opensearch/${var.name}/index-slow"
  retention_in_days = 14
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "search_slow_logs" {
  name              = "/aws/opensearch/${var.name}/search-slow"
  retention_in_days = 14
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "es_application_logs" {
  name              = "/aws/opensearch/${var.name}/es-application"
  retention_in_days = 14
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "audit_logs" {
  name              = "/aws/opensearch/${var.name}/audit-logs"
  retention_in_days = 14
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy
resource "aws_cloudwatch_log_resource_policy" "opensearch_log_resource_policy" {
  policy_name     = "${var.name}-policy"
  policy_document = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch"
      ],
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Resource": [
        "${aws_cloudwatch_log_group.index_slow_logs.arn}:*",
        "${aws_cloudwatch_log_group.search_slow_logs.arn}:*",
        "${aws_cloudwatch_log_group.es_application_logs.arn}:*",
        "${aws_cloudwatch_log_group.audit_logs.arn}:*"
      ],
      "Condition": {
          "StringEquals": {
            "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
          },
          "ArnLike": {
            "aws:SourceArn": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.name}"
          }
      }
    }
  ]
}
JSON
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain
# https://docs.aws.amazon.com/opensearch-service/latest/developerguide/supported-instance-types.html
# https://docs.aws.amazon.com/cloudsearch/latest/developerguide/API_DomainEndpointOptions.html
# https://docs.aws.amazon.com/opensearch-service/latest/developerguide/infrastructure-security.html
resource "aws_opensearch_domain" "main" {
  domain_name     = var.name
  engine_version  = "OpenSearch_${var.opensearch_version}"
  ip_address_type = "ipv4" # "dualstack"

  cluster_config {
    # dedicated_master_count   = var.dedicated_master_count
    # dedicated_master_type    = var.dedicated_master_type
    # dedicated_master_enabled = var.dedicated_master_enabled
    instance_type  = var.node_size
    instance_count = var.node_count
    # zone_awareness_enabled   = var.zone_awareness_enabled
    # zone_awareness_config {
    #   availability_zone_count = var.zone_awareness_enabled ? length(local.subnet_ids) : null
    # }
  }

  advanced_security_options {
    enabled                        = true
    anonymous_auth_enabled         = false
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.username
      master_user_password = var.password
    }
  }

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https                   = true
    tls_security_policy             = "Policy-Min-TLS-1-2-2019-07"
    custom_endpoint_enabled         = true
    custom_endpoint                 = "${var.name}.${var.root_domain}"
    custom_endpoint_certificate_arn = data.aws_acm_certificate.main.arn
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.disk_size
    # TODO: Maybe Variables
    volume_type = "gp3"
    iops        = 3000
    throughput  = 125
  }

  software_update_options {
    auto_software_update_enabled = false
  }

  log_publishing_options {
    enabled                  = true
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.index_slow_logs.arn
    log_type                 = "INDEX_SLOW_LOGS"
  }

  log_publishing_options {
    enabled                  = true
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.search_slow_logs.arn
    log_type                 = "SEARCH_SLOW_LOGS"
  }

  log_publishing_options {
    enabled                  = true
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_application_logs.arn
    log_type                 = "ES_APPLICATION_LOGS"
  }

  # log_publishing_options {
  #   enabled = true
  #   cloudwatch_log_group_arn = aws_cloudwatch_log_group.audit_logs.arn
  #   log_type                 = "AUDIT_LOGS"
  # }

  node_to_node_encryption {
    enabled = true
  }

  vpc_options {
    subnet_ids         = [local.subnet_ids[0]]
    security_group_ids = [aws_security_group.opensearch.id]
  }

  access_policies = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "es:*",
      "Principal": "*",
      "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.name}/*"
    }
  ]
}
JSON
}
