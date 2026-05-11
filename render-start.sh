#!/bin/bash

# Filter environment variables to bind to wrangler
bindings=""

while IFS='=' read -r name value; do
  if [[ "$name" =~ ^[A-Z0-9_]+$ ]]; then
    if [[ "$name" =~ ^(PATH|HOSTNAME|PWD|HOME|SHELL|TERM|USER|LANG|PORT|NODE_VERSION|PNPM_HOME|SHLVL|EDITOR|DEBIAN_FRONTEND)$ ]]; then
      continue
    fi
    bindings+="--binding ${name}=${value} "
  fi
done < <(env)

bindings=$(echo $bindings | sed 's/[[:space:]]*$//')
RENDER_PORT=${PORT:-5173}

echo "Starting wrangler on port $RENDER_PORT"

if [ ! -d "./build/client" ]; then
  echo "Error: ./build/client directory not found."
else
  exec npx wrangler pages dev ./build/client $bindings --compatibility-flag nodejs_compat --ip 0.0.0.0 --port $RENDER_PORT --no-show-interactive-dev-session
fi
