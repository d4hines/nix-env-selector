{ pkgs ? import <nixpkgs> {} }:

let
  # Console templates directory
  consoles = pkgs.stdenv.mkDerivation {
    name = "prometheus-consoles";
    src = ./consoles;
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };

  # Prometheus configuration
  prometheusConfig = pkgs.writeText "prometheus.yml" ''
    global:
      scrape_interval: 15s
      evaluation_interval: 15s

    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']

      - job_name: 'node'
        static_configs:
          - targets: ['localhost:9100']
  '';

  # Startup script
  startScript = pkgs.writeScriptBin "start-prometheus" ''
    #!${pkgs.bash}/bin/bash

    echo "Starting Prometheus with custom consoles..."
    echo "Console templates: ${consoles}"
    echo "Console libraries: ${pkgs.prometheus}/share/prometheus/console_libraries"
    echo ""
    echo "Access consoles at: http://localhost:9090/consoles/"
    echo ""

    ${pkgs.prometheus}/bin/prometheus \
      --config.file=${prometheusConfig} \
      --storage.tsdb.path=./data \
      --web.console.templates=${consoles} \
      --web.console.libraries=${pkgs.prometheus}/share/prometheus/console_libraries \
      --web.enable-lifecycle
  '';

in pkgs.mkShell {
  buildInputs = [
    pkgs.prometheus
    pkgs.prometheus-node-exporter
    startScript
  ];

  shellHook = ''
    echo "Prometheus Development Environment"
    echo "=================================="
    echo ""
    echo "Commands:"
    echo "  start-prometheus          - Start Prometheus with custom consoles"
    echo "  prometheus-node-exporter  - Start node exporter on :9100"
    echo ""
    echo "After starting, visit:"
    echo "  http://localhost:9090/consoles/        - Your custom consoles"
    echo "  http://localhost:9090/consoles/node.html - Node metrics dashboard"
    echo ""
  '';
}
