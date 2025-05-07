#!/bin/sh
# origin entrypoint
nohup containerboot &
echo "Web client enabled..."
tailscale set --webclient
