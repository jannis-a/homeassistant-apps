# Grafana Alloy

Runs [Grafana Alloy](https://grafana.com/docs/alloy/latest/) on Home
Assistant OS and sends:

- **Metrics** via Prometheus remote write, every 15 s:
  - `job="homeassistant"`: everything Home Assistant exposes at
    `/api/prometheus`
  - `job="integrations/node_exporter"`: the host; of the filesystems only the
    data partition (`mountpoint="/data"`), as Home Assistant OS doesn't give
    apps its other mounts
  - `job="integrations/docker"`: cAdvisor's metrics of every running
    container, the same set and labels as Grafana's k8s-monitoring chart
    collects of Kubernetes pods (`container_cpu_usage_seconds_total`,
    `container_memory_working_set_bytes`, ...), with the container's name
    as `container`
  - `job="alloy"`: Alloy itself
- **Logs** via Loki push: the host's journal, which holds the systemd units,
  the kernel and the output of all containers (Home Assistant, the
  Supervisor, its plugins and all apps).

All of it carries `instance` from the options.

## Setup

1. Enable Home Assistant's [Prometheus
   integration](https://www.home-assistant.io/integrations/prometheus/) in
   `configuration.yaml` and restart Home Assistant:

   ```yaml
   prometheus:
   ```

2. Install the app and turn **Protection mode** off on its Info tab. The
   container metrics need the host's cgroups, Docker and containerd: the
   app runs privileged and in the host's PID namespace, which Home Assistant
   only grants to unprotected apps.
3. Set the options and start the app.

## Options

| Option | Description |
|---|---|
| `instance` | The `instance` label of all metrics and log entries. |
| `metrics_url` | Prometheus remote write endpoint. |
| `metrics_token` | Sent as bearer token (`Authorization: Bearer …`) with every remote write request. |
| `logs_url` | Loki push endpoint (`/loki/api/v1/push`). |
| `logs_token` | Sent as bearer token (`Authorization: Bearer …`) with every push request. |
| `log_level` | Alloy's own log level. |

## Outages

Nothing is lost while an endpoint is unreachable or answers with a server
error:

- Metrics wait in Alloy's write-ahead log in `/data` for up to a week and are
  sent in order once the endpoint is back.
- Log entries are retried without limit. Alloy stops reading the journal in
  the meantime and continues from its position afterwards, also across
  restarts. Home Assistant OS keeps the journal for several weeks.

Home Assistant backups contain the journal position but not the metrics'
write-ahead log: after a restore, the app continues reading the journal
where the backup left it.

Client errors (`4xx` other than `429`), such as a wrong token, are not
retried: the data is dropped. Check the app's log after changing the
options.

## Log format

The app doesn't label the journal entries itself. Each line is one
journal entry with all its fields as a JSON object (`MESSAGE`, `PRIORITY`,
`_HOSTNAME`, `_SYSTEMD_UNIT`, `CONTAINER_NAME`, `SYSLOG_IDENTIFIER`, ...),
and the only label is `instance`. The receiving side labels them, so changes
of the labels don't need an update of the app. The app only drops a
warning of its own cAdvisor that the Raspberry Pi 5 repeats every 5
minutes ("Found node without any CPU"). With Alloy as the receiver,
that's a `loki.source.api` with `use_incoming_timestamp = true` (entries
arrive late after an outage), followed by `stage.json` on the fields and
`stage.output` on `MESSAGE`. Home Assistant and its Supervisor color their
lines, and container output carries the priority of its stream (`3` for all
of Home Assistant's), so a level is best taken from the line.
