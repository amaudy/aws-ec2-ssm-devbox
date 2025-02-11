#!/bin/bash

# Get the instance ID from terraform output
INSTANCE_ID=$(terraform output -raw instance_id)

# Create SSH config
mkdir -p ~/.ssh/conf.d
cat > ~/.ssh/conf.d/devbox.conf << EOF
Host devbox
    HostName localhost
    Port 2222
    User ec2-user
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF

# Update main SSH config to include our config
if ! grep -q "Include conf.d/devbox.conf" ~/.ssh/config 2>/dev/null; then
    echo "Include conf.d/devbox.conf" >> ~/.ssh/config
fi

echo "SSH configuration has been updated!"
echo ""
echo "To connect to your devbox:"
echo ""
echo "1. Start the SSM tunnel (keep this terminal running):"
echo "   aws ssm start-session --target $INSTANCE_ID \\"
echo "     --document-name AWS-StartPortForwardingSession \\"
echo "     --parameters '{\"portNumber\":[\"22\"],\"localPortNumber\":[\"2222\"]}'"
echo ""
echo "2. In VS Code:"
echo "   - Open Command Palette (Cmd+Shift+P)"
echo "   - Type 'Remote-SSH: Connect to Host'"
echo "   - Select 'devbox'"
echo ""
echo "Note: Keep the SSM tunnel running while using VS Code"
