{ config, ... }: {
  services.grafana = {
    enable = true;
    settings = {
      server = {
        domain = "status.cardanow.staging.mlabs.city";
        http_addr = "127.0.0.1";
        http_port = 2342;
        root_url = "https://${config.services.grafana.settings.server.domain}:443";
      };
      users = {
        allow_org_create = false;
        allow_sign_up = false;
        editors_can_admin = false;
      };
      security = {
        admin_user = "admin";
        admin_password = "$__file{${config.age.secrets.grafana-admin-password.path}}";
      };
    };
    provision = {
      datasources.settings = {
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            uid = "local_prometheus";
            url = "http://localhost:${builtins.toString config.services.prometheus.port}";
          }
          {
            name = "Loki";
            type = "loki";
            uid = "local_loki";
            url = "http://localhost:${builtins.toString config.services.loki.configuration.server.http_listen_port}";
          }
          {
            name = "Tempo";
            type = "tempo";
            uid = "local_tempo";
            url = "http://localhost:${builtins.toString config.services.tempo.settings.server.http_listen_port}";
            jsonData = {
              tracesToLogs.datasourceUid = "local_loki";
              tracesToMetrics.datasourceUid = "local_prometheus";
              serviceMap.datasourceUid = "local_prometheus";
              nodeGraph.enabled = true;
              lokiSearch.datasourceUid = "local_loki";
            };
          }
        ];
      };
      dashboards.settings.providers = [
        {
          name = "Node";
          options.path = ./dashboards/node.json;
        }
      ];
    };
  };
}
