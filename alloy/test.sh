#!/bin/sh
# Alloy's own checks of the app's config, with the Alloy of the built image:
# formatted as alloy fmt writes it, and valid.
# Usage: test.sh <image>
set -eu
image=$1
cd "$(dirname "$0")"

alloy() {
  docker run --rm -v "$PWD:/app:ro" \
    -e SUPERVISOR_TOKEN=x -e INSTANCE=x -e LOG_LEVEL=info \
    -e METRICS_URL=http://x -e METRICS_TOKEN=x -e LOGS_URL=http://x -e LOGS_TOKEN=x \
    --entrypoint alloy "$image" "$@"
}

alloy fmt /app/config.alloy | diff config.alloy -
alloy validate /app/config.alloy
