# Event Subscriptions for Aurora MySQL

# Event subscription for cluster events
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_event_subscription
resource "aws_db_event_subscription" "cluster" {
  name             = "aurora-mysql-${var.name}-cluster-events"
  sns_topic        = var.sns_topic.arn
  source_type      = "db-cluster"
  source_ids       = [aws_rds_cluster.aurora_mysql.id]
  event_categories = var.cluster_event_categories

  tags = merge(var.tags, {
    Name = "aurora-mysql-${var.name}-cluster-events"
  })
}

# Event subscription for instance events
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_event_subscription
resource "aws_db_event_subscription" "instance" {
  name             = "aurora-mysql-${var.name}-instance-events"
  sns_topic        = var.sns_topic.arn
  source_type      = "db-instance"
  source_ids       = [aws_rds_cluster_instance.primary.id]
  event_categories = var.instance_event_categories

  tags = merge(var.tags, {
    Name = "aurora-mysql-${var.name}-instance-events"
  })
}

