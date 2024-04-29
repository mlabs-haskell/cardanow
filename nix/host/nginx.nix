{
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
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
