# IAM Role
resource "aws_iam_role" "devbox_role" {
  name_prefix = "${local.name_prefix}-role"
  description = "Role for DevBox EC2 instance with SSM and CloudWatch access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "devbox_profile" {
  name_prefix = "${local.name_prefix}-profile"
  role        = aws_iam_role.devbox_role.name
}

# SSM Core Policy - Required for SSM Session Manager
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.devbox_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# CloudWatch Agent Policy - Required for metrics and logs
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.devbox_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# SSM Parameter Store Access - For CloudWatch agent configuration
resource "aws_iam_role_policy" "ssm_parameters" {
  name_prefix = "ssm-parameters-"
  role        = aws_iam_role.devbox_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = [
          "arn:aws:ssm:*:*:parameter/AmazonCloudWatch/Config/${local.name_prefix}"
        ]
      }
    ]
  })
}

# CloudWatch Logs Policy - For sending logs
resource "aws_iam_role_policy" "cloudwatch_logs" {
  name_prefix = "cloudwatch-logs-"
  role        = aws_iam_role.devbox_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "${aws_cloudwatch_log_group.devbox.arn}:*"
        ]
      }
    ]
  })
}
