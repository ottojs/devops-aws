# === Welcome! ==
# Please uncomment the pieces you want to use
# Remember to enable the services (Load Balancers, ECS Clusters) in 02_main if you need them

# # Private Bucket
# module "bucket_example_private" {
#   source        = "../../modules/bucket_private"
#   name          = "bucket-example-private"
#   random_id     = var.random_id
#   kms_key       = data.aws_kms_key.main
#   log_bucket_id = data.aws_s3_bucket.logging.id
#   tags          = var.tags
# }

# # Public Bucket
# # Creation: 7 minutes
# # Deletion: 7 minutes
# module "bucket_public" {
#   source        = "../../modules/bucket_public"
#   name          = "static.${var.root_domain}"
#   log_bucket_id = data.aws_s3_bucket.logging.id
#   root_domain   = var.root_domain
#   domain_record = "static"
#   sns_topic_arn = data.aws_sns_topic.main.arn
#   tags          = var.tags
# }

### Note ###
# The below examples use Fargate
# You can use self-hosted EC2s instead if
# you enable the EC2 cluster in 02_core
#
# Then, replace the following
# type = "FARGATE" change to "EC2"
# ecs_cluster = "fargate" change to "ec2"
#
# You can run Fargate and EC2 side-by-side but note that
# the "name" must be unique as it's used for DNS
# If you use the same name, results may change randomly based on DNS responses
#
# You will want to create your own ECR registry for each application or 
# set "create_registry" to false shortly after creation and remove it from state
# tofu state list; tofu state rm ID_HERE;
#
# Ensure to publish your container to the AWS container registry (ECR) and match the tag version
# Also be sure to create your secrets in AWS Secrets Manager using the patterns below
# Otherwise, your service will fail to launch. You can check status in ECS console

# ### API SERVER ###
# # Your service MUST listen on port 8080
# module "api_server" {
#   source          = "../../modules/ecs_service"
#   mode            = "server"
#   type            = "FARGATE"
#   create_registry = true
#   name            = "api-server"
#   tag             = "0.0.1"
#   arch            = "X86_64" # ARM64
#   ecs_cluster     = "fargate"
#   vpc             = data.aws_vpc.main
#   subnet_ids      = data.aws_subnets.private.ids
#   kms_key         = data.aws_kms_key.main
#   # Example to add an inline policy for this service
#   # inline_policy = jsonencode({
#   #   Version = "2012-10-17"
#   #   Statement = [
#   #     {
#   #       Action = [
#   #         "s3:ListBucketMultipartUploads",
#   #         "s3:ListBucket",
#   #         "s3:ListMultipartUploadParts",
#   #         "...more...",
#   #       ]
#   #       Effect   = "Allow"
#   #       Resource = "*"
#   #     },
#   #   ]
#   # })
#   envvars = {
#     NODE_ENV = "production"
#   }
#   secrets = [
#     # Secrets Manager Key
#     # apps/APPNAME/SECRETNAME
#     # so in this case...
#     # apps/api-server/MY_SECRET
#     "MY_SECRET",
#   ]
#   tags = var.tags
#   ### Server Only ###
#   public      = true
#   root_domain = var.root_domain
#   priority    = 1
#   #additional_hosts = ["something.${var.root_domain}"]
# }

# ### API WORKER ###
# module "api_worker" {
#   source          = "../../modules/ecs_service"
#   mode            = "worker"
#   type            = "FARGATE"
#   create_registry = true
#   name            = "api-worker"
#   tag             = "0.0.1"
#   arch            = "X86_64" # ARM64
#   ecs_cluster     = "fargate"
#   vpc             = data.aws_vpc.main
#   subnet_ids      = data.aws_subnets.private.ids
#   kms_key         = data.aws_kms_key.main
#   envvars = {
#     NODE_ENV = "production"
#   }
#   secrets = [
#     # Secrets Manager Key
#     # apps/APPNAME/SECRETNAME
#     # so in this case...
#     # apps/api-worker/MY_SECRET
#     "MY_SECRET",
#   ]
#   tags = var.tags
#   # TODO: Possible bug, need this for now
#   root_domain = var.root_domain
# }

# ### API CRON JOB ###
# # https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
# # https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-scheduled-rule-pattern.html
# module "api_cron" {
#   source          = "../../modules/ecs_service"
#   mode            = "cron"
#   type            = "FARGATE"
#   create_registry = true
#   name            = "api-cron"
#   tag             = "0.0.1"
#   arch            = "X86_64" # ARM64
#   ecs_cluster     = "fargate"
#   vpc             = data.aws_vpc.main
#   subnet_ids      = data.aws_subnets.private.ids
#   kms_key         = data.aws_kms_key.main
#   envvars = {
#     NODE_ENV = "production"
#   }
#   secrets = [
#     # Secrets Manager Key
#     # apps/APPNAME/SECRETNAME
#     # so in this case...
#     # apps/api-cron/MY_SECRET
#     "MY_SECRET",
#   ]
#   tags = var.tags
#   ### Cron Job Only ###
#   timezone = "US/Eastern"
#   schedule = "cron(0 * * * ? *)" # Every hour
#   # TODO: Possible bug, need this for now
#   root_domain = var.root_domain
# }
