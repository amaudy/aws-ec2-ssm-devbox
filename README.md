# AWS EC2 DevBox with SSM Access

This project provides a Terraform configuration for creating a secure development environment on AWS EC2, accessible via AWS Systems Manager (SSM) Session Manager. It's designed for developers who need a remote development environment that's both secure and easy to access via VS Code.

## Features

- 🔒 **Secure Access**: No inbound ports open, all access via AWS SSM
- 🔗 **VS Code Integration**: Easy connection via VS Code Remote-SSH
- 📊 **Monitoring**: CloudWatch metrics and logs enabled
- 🏗️ **Infrastructure as Code**: Complete Terraform configuration
- 🔄 **Cross-Platform**: Support for both PowerShell and Bash

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- VS Code with Remote-SSH extension installed
- PowerShell or Bash shell

## Quick Start

1. **Initialize Terraform**
   ```bash
   terraform init
   ```

2. **Apply the configuration**
   ```bash
   terraform apply
   ```

3. **Run the setup script**
   
   For PowerShell:
   ```powershell
   .\scripts\setup-vscode.ps1
   ```
   
   For Bash:
   ```bash
   ./scripts/setup-vscode.sh
   ```

4. **Start the SSM tunnel**
   
   For PowerShell:
   ```powershell
   .\scripts\start-tunnel.ps1
   ```

5. **Connect via VS Code**
   - Open Command Palette (Ctrl/Cmd + Shift + P)
   - Type "Remote-SSH: Connect to Host"
   - Select "devbox"

## Project Structure

```
.
├── main.tf                 # Root Terraform configuration
├── versions.tf             # Provider and version constraints
├── outputs.tf             # Root outputs
├── modules/
│   └── ec2-devbox/        # EC2 instance module
│       ├── main.tf        # Main module configuration
│       ├── iam.tf         # IAM roles and policies
│       ├── variables.tf   # Module variables
│       ├── outputs.tf     # Module outputs
│       └── README.md      # Module documentation
└── scripts/
    ├── setup-vscode.ps1   # PowerShell setup script
    ├── setup-vscode.sh    # Bash setup script
    └── start-tunnel.ps1   # PowerShell tunnel script
```

## Security Features

- No inbound security group rules
- SSM access only (no SSH keys needed)
- Minimal IAM permissions
- CloudWatch logging and monitoring
- IMDSv2 required

## Customization

The module supports various customization options through variables:

```hcl
module "devbox" {
  source = "./modules/ec2-devbox"

  name_prefix      = "custom-name"
  instance_type    = "t3.large"  # For more resources
  root_volume_size = 100         # Larger storage
  
  tags = {
    Environment = "Development"
    Project     = "MyProject"
  }
}
```

## Monitoring

The instance comes with CloudWatch monitoring enabled for:
- CPU usage
- Memory usage
- Disk usage
- System logs (/var/log/messages, /var/log/secure)

View these metrics in the AWS CloudWatch console under:
- Metrics: EC2 instance metrics
- Logs: `/ec2/devbox/`

## Troubleshooting

1. **VS Code can't connect**
   - Ensure the SSM tunnel is running
   - Check AWS CLI credentials
   - Verify instance is running

2. **No metrics in CloudWatch**
   - Wait a few minutes for metrics to appear
   - Check instance has internet access
   - Verify IAM roles are correct

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- AWS Systems Manager team for the excellent SSM Session Manager
- Visual Studio Code team for Remote-SSH capabilities
- Terraform and HashiCorp for the excellent IaC tools
