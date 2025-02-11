# EC2 DevBox Module

This Terraform module creates an EC2 instance configured for development purposes with the following features:

- AWS Systems Manager (SSM) enabled for remote access
- CloudWatch monitoring and logging
- Secure configuration with IMDSv2
- Custom security group
- IAM role with necessary permissions

## Usage

```hcl
module "devbox" {
  source = "./modules/ec2-devbox"

  name_prefix      = "mydevbox"
  vpc_id          = "vpc-xxxxxx"
  subnet_id       = "subnet-xxxxxx"
  instance_type   = "t3.micro"
  root_volume_size = 30

  tags = {
    Environment = "Development"
    Project     = "MyProject"
  }
}
```

## Connecting to the Instance

To connect to the instance using VS Code:

1. Install the AWS CLI and configure your credentials
2. Install the "Remote - SSH" extension in VS Code
3. Start an SSM session and create a port forward:

```bash
aws ssm start-session \
  --target <instance-id> \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["22"],"localPortNumber":["2222"]}'
```

4. Configure VS Code SSH config (~/.ssh/config):

```
Host devbox
  HostName localhost
  Port 2222
  User ec2-user
```

5. Connect to the instance using VS Code Remote SSH extension

## Requirements

- AWS provider version >= 4.0
- Terraform version >= 1.0

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix to be used for resource names | string | "" | no |
| instance_type | EC2 instance type | string | "t3.micro" | no |
| vpc_id | VPC ID where the instance will be created | string | n/a | yes |
| subnet_id | Subnet ID where the instance will be created | string | n/a | yes |
| root_volume_size | Size of the root volume in GB | number | 30 | no |
| log_retention_days | Number of days to retain CloudWatch logs | number | 30 | no |
| tags | Tags to apply to all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | ID of the EC2 instance |
| instance_arn | ARN of the EC2 instance |
| instance_private_ip | Private IP of the EC2 instance |
| security_group_id | ID of the security group |
| iam_role_arn | ARN of the IAM role |
| cloudwatch_log_group_name | Name of the CloudWatch log group |
