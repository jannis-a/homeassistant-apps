#!/bin/sh
set -eu

# Every option as an environment variable for sys.env in config.alloy
# (metrics_url as METRICS_URL, ...). The Supervisor doesn't start the app
# without the required ones.
eval "$(jq -r 'to_entries[] | "export \(.key | ascii_upcase)=\(.value | @sh)"' /data/options.json)"

# The host's cgroups for cAdvisor instead of the app's own: mounted from the
# host's cgroup namespace (PID 1's), as Docker gives the app a private one.
umount /sys/fs/cgroup
nsenter --target 1 --cgroup -- mount -t cgroup2 none /sys/fs/cgroup

# /data persists across restarts and updates: the WAL and the journal position.
exec alloy run \
  --server.http.listen-addr=127.0.0.1:12345 \
  --storage.path=/data/alloy \
  --disable-reporting \
  /etc/alloy/config.alloy
