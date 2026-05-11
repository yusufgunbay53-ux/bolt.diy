#!/bin/bash

# Filter environment variables to bind to wrangler
# We exclude common system variables to avoid bloat and potential issues
bindings=""

# Get all environment variables
while IFS='=' read -r name value; do
  # Only include variables that are likely app-specific (e.g. UPPER_CASE or VITE_ prefix)
  # or specifically known to be needed.
  if [[ "$name" =~ ^[A-Z0-9_]+$ ]]; then
    # Skip some common system vars
    if [[ "$name" =~ ^(PATH|HOSTNAME|PWD|HOME|SHELL|TERM|USER|LANG|PORT|NODE_VERSION|PNPM_HOME|SHLVL|EDITOR|DEBIAN_FRONTEND)$ ]]; then
      continue
    fi

    # Escape value for the command line if necessary (though wrangler handles simple ones)
    bindings+="--binding ${name}=${value} "
  fi
done < <(env)

bindings=$(echo $bindings | sed 's/[[:space:]]*$//')

echo "Starting wrangler on port ${PORT:-5173}"
# Using exec to replace the shell process with wrangler
exec npx wrangler pages dev ./build/client $bindings --compatibility-flag nodejs_compat --ip 0.0.0.0 --port ${PORT:-5173} --no-show-interactive-dev-session
