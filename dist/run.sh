#!/bin/sh
mkdir -p -m 0755 /tmp/tailscale
rm -rf /tmp/tailscale/tailscaled.pid

# start tailscaled
tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock 2> /dev/null &
echo $! > /tmp/tailscale/tailscaled.pid
sleep 5

if [ -e /tmp/tailscale/tailscaled.pid ]; then
    PID=$(cat /tmp/tailscale/tailscaled.pid)
    echo "tailscaled (pid:$PID) is up"
    echo "ts auth key：$TS_AUTH_KEY"
    # if auth key provided, join the network
    if [ -n "$TS_AUTH_KEY" ]; then
        echo "Authenticating with auth key..."
        tailscale up --authkey=$TS_AUTH_KEY ${TS_HOSTNAME:+--hostname=$TS_HOSTNAME}
    fi

    # apply other configurations
    if [ -n "$TS_EXTRA_ARGS" ]; then
        echo "Applying options: $TS_EXTRA_ARGS"
        tailscale set $TS_EXTRA_ARGS
    fi

    # star web ui
    echo "Web client enabled, serving at https://$LAZYCAT_APP_DOMAIN..."
    tailscale web --listen=0.0.0.0:59527 --origin=https://$LAZYCAT_APP_DOMAIN
    echo "tailscale is ready"
fi
