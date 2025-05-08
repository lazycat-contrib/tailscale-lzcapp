#!/bin/sh
mkdir -p -m 0755 /tmp/tailscale
TAILSCALED_PORT="41641"
rm -rf /tmp/tailscale/tailscaled.pid
tailscaled --port=$TAILSCALED_PORT --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock  2> /dev/null &
echo $! > /tmp/tailscale/tailscaled.pid
sleep 5
if [ -e /tmp/tailscale/tailscaled.pid ]; then
    PID=$(cat /tmp/tailscale/tailscaled.pid)
    echo "tailscaled (pid:$PID) is up ,apply options"
    tailscale set --accept-routes 
    echo "Web client enabled..."
    tailscale web --listen=0.0.0.0:59527
    echo "tailscale is ready"  
fi
