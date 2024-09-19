{ writeShellApplication, cardanow-ts, cleanup-local-data, git, curl, cardano-cli, mithril-client-cli, jq, openssh, cardano-configurations, postgresql_14, openssl, otel-cli, network ? "mainnet" }:
writeShellApplication
{
  name = "cardanow";
  runtimeEnv.NETWORK = network;
  runtimeInputs = [
    cardano-cli
    cardanow-ts
    cleanup-local-data
    curl
    git
    jq
    mithril-client-cli
    openssh
    openssl
    otel-cli
    # NOTE: this version should match the postgresql version that is used in the docker-compose
    postgresql_14
  ];
  text = ''
    # shellcheck source=/dev/null
    source "${../../bin/utils.sh}"

    ln -sfT ${../../config/docker-compose.yaml} docker-compose.yaml
    ln -sfT ${cardano-configurations} cardano-configurations

    source_files() {
      # shellcheck source=/dev/null
      source "${../../bin/download-with-mithril.sh}"
      # shellcheck source=/dev/null
      source "${../../bin/start-cardanow-isolated-sync.sh}"
    }
    trace "exporter" source_files
  '';
}
