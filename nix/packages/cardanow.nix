{ writeShellApplication, cardanow-ts, cleanup-local-data, git, curl, cardano-cli, mithril-client-cli, jq, openssh, cardano-configurations, network ? "mainnet" }:
writeShellApplication
{
  name = "cardanow";
  runtimeEnv.NETWORK = network;
  runtimeInputs = [
    cardanow-ts
    cleanup-local-data
    curl
    git
    cardano-cli
    mithril-client-cli
    jq
    openssh
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
