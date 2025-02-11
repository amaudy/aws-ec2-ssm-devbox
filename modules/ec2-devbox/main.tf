locals {
  name_prefix = var.name_prefix != "" ? var.name_prefix : "devbox"
}

# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# EC2 Instance
resource "aws_instance" "devbox" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.devbox.id]
  iam_instance_profile        = aws_iam_instance_profile.devbox_profile.name
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # IMDSv2
  }

  monitoring = true

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-instance"
    }
  )

  user_data = <<-EOF
              #!/bin/bash
              # Install CloudWatch agent
              yum install -y amazon-cloudwatch-agent
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:/AmazonCloudWatch/Config/${local.name_prefix}
              systemctl enable amazon-cloudwatch-agent
              systemctl start amazon-cloudwatch-agent
              EOF
}

# Security Group
resource "aws_security_group" "devbox" {
  name_prefix = "${local.name_prefix}-sg"
  vpc_id      = var.vpc_id
  description = "Security group for DevBox instance managed via SSM"

  # No inbound rules needed as we use SSM for access

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-sg"
    }
  )
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "devbox" {
  name              = "/ec2/${local.name_prefix}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# SSM Parameter for CloudWatch Agent config
resource "aws_ssm_parameter" "cw_agent" {
  name = "/AmazonCloudWatch/Config/${local.name_prefix}"
  type = "String"
  value = jsonencode({
    agent = {
      run_as_user = "root"
    }
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path       = "/var/log/messages"
              log_group_name  = "/ec2/${local.name_prefix}"
              log_stream_name = "{instance_id}/messages"
              timezone        = "UTC"
            },
            {
              file_path       = "/var/log/secure"
              log_group_name  = "/ec2/${local.name_prefix}"
              log_stream_name = "{instance_id}/secure"
              timezone        = "UTC"
            }
          ]
        }
      }
    }
    metrics = {
      metrics_collected = {
        cpu = {
          measurement                 = ["cpu_usage_idle", "cpu_usage_user", "cpu_usage_system"]
          metrics_collection_interval = 60
        }
        disk = {
          measurement                 = ["used_percent"]
          metrics_collection_interval = 60
          resources                   = ["*"]
        }
        mem = {
          measurement                 = ["mem_used_percent"]
          metrics_collection_interval = 60
        }
      }
    }
  })
}
