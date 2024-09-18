{ ... }: {
  services.tempo = {
    enable = true;
    settings = {
      server = {
        grpc_listen_port = 9096;
        http_listen_address = "0.0.0.0";
        http_listen_port = 8080;
        graceful_shutdown_timeout = "10s";

      };
      distributor.receivers = {
        otlp.protocols = {
          grpc = { };
        };
      };
      storage.trace = {
        backend = "local";
        wal.path = "/var/lib/tempo/wal";
        local.path = "/var/lib/tempo/blocks";
      };
      ingester.lifecycler.ring = {
        kvstore.store = "inmemory";
        replication_factor = 1;
      };
      usage_report.reporting_enabled = false;
    };
  };
}
