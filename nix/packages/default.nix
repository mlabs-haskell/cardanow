{
  perSystem = { pkgs, inputs', ... }: {
    packages.cardanow = pkgs.writeShellApplication {
      name = "cardanow";
      runtimeInputs = [
        inputs'.cardano-node.packages.cardano-cli
        inputs'.mithril.packages.mithril-client-cli
      ];
      text = ''
        cardano-cli --version
        mithril-client --version
      '';
    };
  };
}
