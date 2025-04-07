
################################
##### AWS Config S3 Bucket #####
################################

module "aws_config_bucket" {
  source        = "../../modules/bucket_private"
  name          = "devops-aws-config-bucket"
  random_id     = var.random_id
  kms_key       = var.kms_key
  log_bucket_id = data.aws_s3_bucket.log_bucket.id
  tags          = var.tags
}
