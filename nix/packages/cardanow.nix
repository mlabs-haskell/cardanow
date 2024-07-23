{ writeShellApplication, cardanow-ts, cleanup-local-data, git, curl, cardano-cli, mithril-client-cli, jq, openssh, cardano-configurations, postgresql_14, network ? "mainnet" }:
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
    # NOTE: this version should match the postgresql version that is used in the docker-compose
    postgresql_14
  ];
  text = ''
    # TODO there is probably a better way to write this
    ln -sfT ${../../config/mithril-configurations} mithril-configurations
    ln -sfT ${../../config/docker-compose.yaml} docker-compose.yaml
    ln -sfT ${cardano-configurations} cardano-configurations

    # shellcheck source=/dev/null
    source "${../../bin/setup-env-vars.sh}"
    # shellcheck source=/dev/null
    source "${../../bin/download-with-mithril.sh}"
    # shellcheck source=/dev/null
    source "${../../bin/start-cardanow-isolated-sync.sh}"
  '';
}
