
# This is the main Customer-Managed Key
# We'll use it elsewhere using a "data" block
module "kms_main" {
  source      = "../../modules/kms_key_region_symmetric"
  name        = "main"
  description = "Main Customer-Managed Key"
  iam_user    = var.iam_user
  tag_app     = var.tag_app
}

# This is the main logging bucket
# Again, we'll re-use it elsewhere
# But if it makes more sense, you can make another
module "log_bucket" {
  source              = "../../modules/bucket_private"
  name                = "devops-log-bucket"
  random_id           = var.random_id
  kms_key             = module.kms_main.key
  log_bucket_id       = "none"
  log_bucket_disabled = true
  tag_app             = var.tag_app
}

module "bucket_tf_state" {
  source        = "../../modules/bucket_private"
  name          = "devops-terraform-state-bucket"
  random_id     = var.random_id
  kms_key       = module.kms_main.key
  log_bucket_id = module.log_bucket.bucket.id
  tag_app       = var.tag_app
}

resource "aws_dynamodb_table" "tf_state" {
  name         = "devops-terraform-state"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  point_in_time_recovery {
    enabled = true
  }
  server_side_encryption {
    enabled     = true
    kms_key_arn = module.kms_main.key.arn
  }
  tags = {
    Name = "terraform-state"
    App  = var.tag_app
  }
}
