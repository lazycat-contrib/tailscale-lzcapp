#!/bin/sh
set -u

TS_STATE_DIR=${TS_STATE_DIR:-/var/lib/tailscale}
TS_SOCKET=${TS_SOCKET:-/run/tailscale/tailscaled.sock}
STATE_FILE="$TS_STATE_DIR/tailscaled.state"

for var in TS_AUTHKEY TS_LOGIN_SERVER TS_HOSTNAME TS_EXTRA_ARGS; do
    eval "value=\${$var:-}"
    if [ "$value" = "<no value>" ]; then
        eval "$var="
    fi
done

mkdir -p -m 0755 /tmp/tailscale
mkdir -p -m 0755 "$TS_STATE_DIR" "$(dirname "$TS_SOCKET")"
rm -rf /tmp/tailscale/tailscaled.pid

# start tailscaled
tailscaled --state="$STATE_FILE" --socket="$TS_SOCKET" 2> /dev/null &
echo $! > /tmp/tailscale/tailscaled.pid
sleep 5

if [ -e /tmp/tailscale/tailscaled.pid ]; then
    PID=$(cat /tmp/tailscale/tailscaled.pid)
    echo "tailscaled (pid:$PID) is up"

    set --
    if [ -n "$TS_HOSTNAME" ]; then
        set -- "$@" "--hostname=$TS_HOSTNAME"
    fi
    if [ -n "$TS_LOGIN_SERVER" ]; then
        set -- "$@" "--login-server=$TS_LOGIN_SERVER"
    fi
    if [ -n "$TS_EXTRA_ARGS" ]; then
        # TS_EXTRA_ARGS intentionally supports shell-style word splitting.
        set -- "$@" $TS_EXTRA_ARGS
    fi

    RESET_INVALID_CONTROL_URL=0
    if tailscale --socket="$TS_SOCKET" debug prefs 2>/dev/null | grep -q '"ControlURL": *"\\u003cno value\\u003e"'; then
        echo "Resetting invalid login server value from previous startup"
        if [ -n "$TS_AUTHKEY" ]; then
            tailscale --socket="$TS_SOCKET" up --reset --authkey="$TS_AUTHKEY" "$@" || true
        else
            tailscale --socket="$TS_SOCKET" up --reset "$@" || true
        fi
        RESET_INVALID_CONTROL_URL=1
    fi

    if tailscale --socket="$TS_SOCKET" status --peers=false --json 2>/dev/null | grep -q '"BackendState": *"Running"'; then
        echo "Tailscale is already authenticated"
        if [ "$#" -gt 0 ] && [ "$RESET_INVALID_CONTROL_URL" -eq 0 ]; then
            echo "Applying startup options: $*"
            tailscale --socket="$TS_SOCKET" up "$@" || true
        fi
    elif [ -n "$TS_AUTHKEY" ]; then
        echo "Authenticating with auth key..."
        tailscale --socket="$TS_SOCKET" up --authkey="$TS_AUTHKEY" "$@"
    elif [ "$#" -gt 0 ]; then
        echo "Startup options are configured but no auth key was provided; start the web client first"
    fi

    # start web ui
    echo "Web client enabled, serving at https://$LAZYCAT_APP_DOMAIN..."
    tailscale --socket="$TS_SOCKET" web --listen=0.0.0.0:59527 --origin=https://$LAZYCAT_APP_DOMAIN
    echo "tailscale is ready"
fi
