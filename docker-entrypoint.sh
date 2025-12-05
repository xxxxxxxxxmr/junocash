#!/bin/bash
set -e

# Define default config path
CONFIG_DIR="/root/.junocash"
CONFIG_FILE="$CONFIG_DIR/junocashd.conf"

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

# Generate junocashd.conf if RPC variables are set
if [ -n "$RPC_USER" ] && [ -n "$RPC_PASSWORD" ]; then
    echo "Generating $CONFIG_FILE from environment variables..."
    cat > "$CONFIG_FILE" <<EOF
server=1
rpcuser=$RPC_USER
rpcpassword=$RPC_PASSWORD
rpcport=${RPC_PORT:-8232}
rpcallowip=${RPC_ALLOW_IP:-127.0.0.1}
randomxfastmode=1
EOF
else
    echo "WARNING: RPC_USER and RPC_PASSWORD not set. Node may not start or RPC may be inaccessible."
fi

# Execute the passed command
exec "$@"
