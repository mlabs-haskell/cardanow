{ config, ... }: {
  security.acme = {
    acceptTerms = true;
    defaults.email = "devops+acme@mlabs.city";
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    serverNamesHashBucketSize = 128;

    virtualHosts = {
      "cardanow.staging.mlabs.city" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          return = "301 https://pub-b887f41ffaa944ebaae543199d43421c.r2.dev$request_uri";
        };
      };
      "${config.services.grafana.settings.server.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:${builtins.toString config.services.grafana.settings.server.http_port}";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
