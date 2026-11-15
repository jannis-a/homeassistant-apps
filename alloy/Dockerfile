FROM docker.io/grafana/alloy:v1.21.3@sha256:8ab871206bd2d8f89277f53abffee5f452a293980788d52f85fa183a87a505a4

# curl for the health check, jq for run.sh.
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl jq \
 && rm -rf /var/lib/apt/lists/*

# An empty udev database instead of an error from the diskstats collector
# (Home Assistant OS gives apps none).
RUN mkdir -p /run/udev/data

COPY run.sh /usr/local/bin/
COPY config.alloy /etc/alloy/

# The Supervisor shows the container's health as the app's and restarts it
# when the watchdog is on.
HEALTHCHECK --start-period=30s --interval=30s --timeout=5s --retries=3 \
  CMD curl -fsS http://127.0.0.1:12345/-/ready >/dev/null || exit 1

ENTRYPOINT ["/usr/local/bin/run.sh"]
CMD []
