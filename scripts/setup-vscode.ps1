# Get the instance ID from terraform output
$InstanceId = terraform output -raw instance_id

# Create .ssh directory if it doesn't exist
$SshPath = "$env:USERPROFILE\.ssh"
$SshConfDPath = "$SshPath\conf.d"
New-Item -ItemType Directory -Force -Path $SshConfDPath | Out-Null

# Create devbox SSH config
$DevboxConfig = @"
Host devbox
    HostName localhost
    Port 2222
    User ec2-user
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
"@

Set-Content -Path "$SshConfDPath\devbox.conf" -Value $DevboxConfig

# Update main SSH config to include our config
$SshConfigPath = "$SshPath\config"
$IncludeLine = "Include conf.d/devbox.conf"

if (!(Test-Path $SshConfigPath)) {
    Set-Content -Path $SshConfigPath -Value $IncludeLine
} elseif (!(Select-String -Path $SshConfigPath -Pattern $IncludeLine -Quiet)) {
    Add-Content -Path $SshConfigPath -Value $IncludeLine
}

Write-Host "SSH configuration has been updated!`n"
Write-Host "To connect to your devbox:`n"
Write-Host "1. Start the SSM tunnel (keep this PowerShell window running):"
Write-Host "   aws ssm start-session ``"
Write-Host "     --target $InstanceId ``"
Write-Host "     --document-name AWS-StartPortForwardingSession ``"
Write-Host "     --parameters '{""portNumber"":[""22""],""localPortNumber"":[""2222""]}'"
Write-Host "`n2. In VS Code:"
Write-Host "   - Open Command Palette (Ctrl+Shift+P)"
Write-Host "   - Type 'Remote-SSH: Connect to Host'"
Write-Host "   - Select 'devbox'"
Write-Host "`nNote: Keep the PowerShell window with the SSM tunnel running while using VS Code"

# Create a convenience script to start the tunnel
$TunnelScript = @"
aws ssm start-session ``
  --target $InstanceId ``
  --document-name AWS-StartPortForwardingSession ``
  --parameters '{""portNumber"":[""22""],""localPortNumber"":[""2222""]}'
"@

Set-Content -Path "scripts\start-tunnel.ps1" -Value $TunnelScript
Write-Host "`nCreated start-tunnel.ps1 script for easy tunnel startup"
