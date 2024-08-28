{ config, ... }: {
  services.prometheus = {
    enable = true;
    port = 9001;

    pushgateway = {
      enable = true;
      web = {
        listen-address = "localhost:9094";
        telemetry-path = "/metrics";
      };
    };

    scrapeConfigs = [
      {
        job_name = "pushgateway";
        static_configs = [
          {
            targets = [ config.services.prometheus.pushgateway.web.listen-address ];
          }
        ];
      }
      {
        job_name = "node";
        static_configs = [
          {
            targets = [ "localhost:${builtins.toString config.services.prometheus.exporters.node.port}" ];
          }
        ];
      }
      {
        job_name = "zfs";
        static_configs = [
          {
            targets = [ "localhost:${builtins.toString config.services.prometheus.exporters.zfs.port}" ];
          }
        ];
      }
      {
        job_name = "nginx";
        static_configs = [
          {
            targets = [ "localhost:${builtins.toString config.services.prometheus.exporters.nginx.port}" ];
          }
        ];
      }
      {
        job_name = "smartctl";
        static_configs = [
          {
            targets = [ "localhost:${builtins.toString config.services.prometheus.exporters.smartctl.port}" ];
          }
        ];
      }
    ];

    exporters = {
      node = {
        enable = true;
        enabledCollectors = [
          "cpu"
          "conntrack"
          "diskstats"
          "entropy"
          "filefd"
          "filesystem"
          "loadavg"
          "mdadm"
          "meminfo"
          "netdev"
          "netstat"
          "stat"
          "time"
          "vmstat"
          "systemd"
          "logind"
          "interrupts"
          "ksmd"
          "textfile"
          "pressure"
        ];
        extraFlags = [ "--collector.ethtool" "--collector.softirqs" "--collector.tcpstat" ];
      };
      zfs.enable = true;
      nginx.enable = true;
      smartctl.enable = true;
    };
  };
}
