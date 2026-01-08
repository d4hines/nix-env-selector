# Prometheus Console Templates Example

This example demonstrates how to set up Prometheus with custom console templates using Nix, perfect for embedded devices or resource-constrained environments.

## Architecture

- **Embedded Device**: Runs only Prometheus (lightweight)
- **Local Development**: SSH port forwarding + browser-based consoles
- **No Heavy UI**: Uses built-in console templates (static HTML/JS)

## Quick Start

```bash
# Enter the nix environment
nix-shell

# Start Prometheus with custom consoles
start-prometheus

# In another terminal (optional), start node exporter
prometheus-node-exporter
```

## Access Consoles

Open your browser to:
- http://localhost:9090/consoles/ - Dashboard index
- http://localhost:9090/consoles/node.html - Node metrics
- http://localhost:9090/consoles/prometheus.html - Prometheus internals

## Remote Access via SSH

For embedded devices, use SSH port forwarding:

```bash
# Forward Prometheus port from remote device
ssh -L 9090:localhost:9090 user@embedded-device

# Now access http://localhost:9090/consoles/ in your browser
```

## Console Templates

Console templates are located in the `consoles/` directory:

- **index.html** - Main dashboard with system overview
- **node.html** - Node Exporter metrics (CPU, memory, disk, network)
- **prometheus.html** - Prometheus internal metrics

### Template Structure

All templates follow the standard Prometheus console structure:

```html
{{ template "head" . }}
{{ template "prom_content_head" . }}

<h1>Your Dashboard</h1>
<!-- Your metrics and graphs -->

{{ template "prom_content_tail" . }}
{{ template "tail" }}
```

### Features

- **Static HTML/JS**: No backend required beyond Prometheus
- **Built-in Graphing**: Uses PromConsole.Graph JavaScript library
- **Template Functions**:
  - `prom_query_drilldown` - Displays query results with drill-down links
  - `query` - Executes PromQL queries
  - `sortByLabel` - Sorts results by label

## Customization

### Add New Consoles

1. Create a new `.html` file in `consoles/`
2. Use the template structure above
3. Add PromQL queries and graphs
4. Link from `index.html`

### Example Query

```html
<h3>CPU Usage</h3>
{{ template "prom_query_drilldown" (args "100 - (avg(irate(node_cpu_seconds_total{mode='idle'}[5m])) * 100)") }}
```

### Example Graph

```html
<div id="myGraph"></div>
<script>
new PromConsole.Graph({
  node: document.querySelector("#myGraph"),
  expr: "rate(node_cpu_seconds_total[5m])",
  name: "CPU Rate",
  yAxisFormatter: PromConsole.NumberFormatter.humanizeNoSmallPrefix,
  yTitle: "Seconds/sec"
})
</script>
```

## Documentation

For more information about Prometheus console templates:

- [Console Templates Overview](https://prometheus.io/docs/visualization/consoles/)
- [Template Reference](https://prometheus.io/docs/prometheus/latest/configuration/template_reference/)
- [Template Examples](https://prometheus.io/docs/prometheus/latest/configuration/template_examples/)

## Benefits

✅ **Lightweight**: Only ~100MB for Prometheus (vs 254MB for Perses)
✅ **No Dependencies**: Pure Prometheus, no separate UI service
✅ **Ephemeral**: Users run consoles locally via SSH tunnel
✅ **Multi-User**: Each user has their own view, no conflicts
✅ **Source Control**: Console templates are just HTML files
✅ **Fast**: Static HTML/JS, no server-side rendering
