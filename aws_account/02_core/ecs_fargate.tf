# ECS Clusters

###################
##### FARGATE #####
###################

# module "ecs_cluster_fargate" {
#   source             = "../../modules/ecs_cluster"
#   name               = "cluster-fargate"
#   type               = "FARGATE"
#   kms_key            = data.aws_kms_key.main
#   log_retention_days = var.log_retention_days
#   tags               = var.tags
# }

###########################
##### EC2 SELF-HOSTED #####
###########################

# # WARNING: You want to underestimate the autoscaling CPU threshold
# # We want this to scale at 80% but put in 60% due to reporting challenges
# # Even when CPU was pinned at 100% in the OS, only 80% was reported
# # We may consider an alternative monitoring solution in the future
# module "asg_ec2" {
#   source               = "../../modules/asg"
#   name                 = "ecs-x86_64"
#   subnets              = module.myvpc.subnets_private
#   security_groups      = [module.myvpc.security_group.id]
#   iam_instance_profile = module.ssm.instance_profile
#   instance_type        = "t3a.small"
#   scale_up_cpu         = 60
#   count_min            = 1
#   count_max            = 3
#   kms_key              = data.aws_kms_key.main
#   sns_topic_arn        = module.sns.topic_arn
#   dev_mode             = true
#   tags                 = var.tags
#   # # RHEL Example
#   # os            = "al2023"
#   # userdata_file = file("../../userdata/rhel.sh")
#   #
#   # ECS Bottlerocket Example
#   os = "bottlerocket_ecs"
#   userdata_file = templatefile("../../userdata/ecs_bottlerocket.sh.tpl", {
#     cluster_name = module.ecs_cluster_ec2.cluster_name
#   })
# }

# module "ecs_cluster_ec2" {
#   source             = "../../modules/ecs_cluster"
#   name               = "cluster-ec2"
#   type               = "EC2"
#   asg                = module.asg_ec2.asg
#   kms_key            = data.aws_kms_key.main
#   log_retention_days = var.log_retention_days
#   tags               = var.tags
# }
