
# Main Notification Topic
# This is needed to send alerts for overall account health
module "sns" {
  source  = "../../modules/sns"
  name    = "devops"
  email   = var.email
  kms_key = data.aws_kms_key.main
  tags    = var.tags
}

# Once per account
module "security_global" {
  source        = "../../modules/security_global"
  sns_topic_arn = module.sns.topic_arn
  tags          = var.tags
}

# Allows SSM Connection (WebShell)
# Also contains EC2 Bastion role (ec2-ssm)
# Consider adding VPC Endpoints for extra protection
module "ssm" {
  source             = "../../modules/ssm"
  log_bucket         = data.aws_s3_bucket.logging
  log_retention_days = var.log_retention_days
  tags               = var.tags
}

# # WARNING: For production, set cost_savings to false or remove it
# module "security" {
#   source       = "../../modules/security"
#   cost_savings = true
#   random_id    = var.random_id
#   kms_key      = data.aws_kms_key.main
#   tags         = var.tags
# }

module "route53" {
  source      = "../../modules/route53_root"
  vpc         = module.myvpc.vpc
  root_domain = var.root_domain
  tags        = var.tags
}

# module "ses" {
#   source      = "../../modules/ses"
#   root_domain = module.route53.domain
#   depends_on  = [module.route53]
# }

# module "sqs" {
#   source  = "../../modules/sqs"
#   name    = "devops"
#   kms_key = data.aws_kms_key.main
#   tags    = var.tags
# }
