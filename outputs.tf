output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.devbox.instance_id
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = module.devbox.instance_private_ip
}

output "ssm_tunnel_command" {
  description = "Command to start the SSM tunnel for VS Code"
  value       = "aws ssm start-session --target ${module.devbox.instance_id} --document-name AWS-StartPortForwardingSession --parameters '{\"portNumber\":[\"22\"],\"localPortNumber\":[\"2222\"]}'"
}

output "setup_instructions" {
  description = "Instructions for connecting via VS Code"
  value       = <<EOF
1. Run the setup script:
   ./scripts/setup-vscode.sh

2. Start the SSM tunnel (keep the terminal running):
   ${module.devbox.instance_id}

3. In VS Code:
   - Open Command Palette (Cmd+Shift+P)
   - Type 'Remote-SSH: Connect to Host'
   - Select 'devbox'
EOF
}
