# This file will be automatically populated by setup-vscode.ps1
# with the correct instance ID

# Get the instance ID from terraform output
$InstanceId = terraform output -raw instance_id

Write-Host "Starting SSM tunnel for instance: $InstanceId"
Write-Host "Keep this window open while using VS Code"
Write-Host ""

aws ssm start-session `
  --target $InstanceId `
  --document-name AWS-StartPortForwardingSession `
  --parameters '{\"portNumber\":[\"22\"],\"localPortNumber\":[\"2222\"]}'
