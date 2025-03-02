
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "cron" {
  count              = var.mode == "cron" ? 1 : 0
  name               = "ecs-cron-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.cron_assume_role[0].json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "cron_assume_role" {
  count   = var.mode == "cron" ? 1 : 0
  version = "2012-10-17"
  statement {
    sid     = "AllowAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "cron" {
  count   = var.mode == "cron" ? 1 : 0
  version = "2012-10-17"
  statement {
    sid     = "AllowECS"
    effect  = "Allow"
    actions = ["ecs:RunTask"]
    resources = [
      "${aws_ecs_task_definition.main.arn}*"
    ]
  }
  statement {
    sid       = "AllowPassRole"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.ecs_task_execution_role.arn]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "cron" {
  count       = var.mode == "cron" ? 1 : 0
  name        = "ecs-cron-${var.name}"
  description = "Allow EventBridge Scheduler (Cron) to run ECS"
  policy      = data.aws_iam_policy_document.cron[0].json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "cron" {
  count      = var.mode == "cron" ? 1 : 0
  role       = aws_iam_role.cron[0].name
  policy_arn = aws_iam_policy.cron[0].arn
}
