
# # External Load Balancer (Public)
# module "alb_public" {
#   source             = "../../modules/load_balancer"
#   name               = "alb-public" # Keep this name
#   public             = true
#   vpc                = module.myvpc.vpc
#   subnets            = module.myvpc.subnets_public
#   root_domain        = module.route53.domain
#   log_bucket         = data.aws_s3_bucket.logging
#   log_retention_days = var.log_retention_days
#   kms_key            = data.aws_kms_key.main
#   sns_topic_arn      = module.sns.topic_arn
#   tags               = var.tags
#   depends_on         = [module.route53]
# }

# # Internal Load Balancer (Private)
# module "alb_private" {
#   source             = "../../modules/load_balancer"
#   name               = "alb-private" # Keep this name
#   public             = false
#   vpc                = module.myvpc.vpc
#   subnets            = module.myvpc.subnets_private
#   root_domain        = module.route53.domain
#   log_bucket         = data.aws_s3_bucket.logging
#   log_retention_days = var.log_retention_days
#   kms_key            = data.aws_kms_key.main
#   sns_topic_arn      = module.sns.topic_arn
#   tags               = var.tags
#   depends_on         = [module.route53]
# }
