
###############################
##### AWS Config Recorder #####
###############################

# Remove existing recorder (if needed)
# https://www.repost.aws/knowledge-center/config-max-recorders-error
# aws configservice describe-configuration-recorders --region REGION
# aws configservice stop-configuration-recorder --configuration-recorder-name NAME --region REGION
# aws configservice delete-configuration-recorder --configuration-recorder-name NAME --region REGION
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder
resource "aws_config_configuration_recorder" "main" {
  name     = "aws-config-recorder"
  role_arn = aws_iam_role.awsconfig.arn

  # TODO: Bug when editing
  recording_group {
    all_supported = !var.cost_savings
    # exclusion_by_resource_types
    include_global_resource_types = false
    # recording_strategy {}
    resource_types = var.cost_savings == true ? [
      "AWS::CloudTrail::Trail",
      "AWS::EC2::Instance",      # Inspector and GuardDuty
      "AWS::S3::Bucket",         # GuardDuty and Security Hub
      "AWS::IAM::Role",          # Security Hub compliance
      "AWS::IAM::Policy",        # Security Hub compliance
      "AWS::EC2::SecurityGroup", # Inspector and GuardDuty
      "AWS::Lambda::Function"    # Inspector (if using Lambda)
    ] : null
  }
  recording_mode {
    recording_frequency = var.cost_savings == true ? "DAILY" : "CONTINUOUS"
  }
}

# Remove existing delivery channel (if needed)
# aws configservice describe-delivery-channels --region REGION
# You may also need to "stop" the recorder, see above
# aws configservice delete-delivery-channel --delivery-channel-name NAME --region REGION
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel
resource "aws_config_delivery_channel" "main" {
  name           = "aws-config-delivery"
  s3_bucket_name = module.aws_config_bucket.bucket.bucket

  depends_on = [aws_config_configuration_recorder.main]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status
resource "aws_config_configuration_recorder_status" "recorder_status" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.main]
}
