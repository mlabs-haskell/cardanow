{ inputs, ... }: {
  perSystem = { pkgs, inputs', system, config, lib, ... }:
    {
      packages = {
        refresh-available-snapshots-state = pkgs.writeShellApplication {
          name = "refresh-available-snapshots-state";
          runtimeInputs = with pkgs; [ awscli2 jq python3 ];
          text =
            let
              # TODO: handle this variable better (e.g. move in a better place, some vars are duplicated in scheduled tasks) 
              awsEndpoint = "https://pub-b887f41ffaa944ebaae543199d43421c.r2.dev";
              awsEndpointEscaped = lib.escape [ ":" "/" "." ] awsEndpoint;
              outFile = "exported-snapshots/available-snapshots.json";
              bucketName = "cardanow";
            in
            ''
              aws s3api list-objects-v2 \
                  --output json \
                  --bucket ${bucketName} \
                  --query "Contents[].{Key:Key, LastModified:LastModified}" \
              | sed 's/"Key": "\(.*\)\/\(.*\)\/\(.*\)-\([0-9]*\)-\([0-9]*\)\.tgz"/"Key": "${awsEndpointEscaped}\/\1\/\2\/\3-\4-\5.tgz", "DataSource": "\1", "Network": "\2", "Epoch": "\4", "ImmutableFileNumber": "\5"/g' \
              | python -m json.tool \
              > ${outFile}
            '';
        };
        cleanup-local-data = pkgs.writeShellApplication {
          name = "cleanup-local-data";
          runtimeInputs = with pkgs; [
            awscli2
            bash
            config.packages.refresh-available-snapshots-state
            jq
          ];
          text = builtins.readFile ../../bin/cleanup-local-data.sh;
        };

        cardanow-mainnet = pkgs.callPackage ./cardanow.nix {
          inherit (inputs'.mithril.packages) mithril-client-cli;
          inherit (inputs'.cardano-node.packages) cardano-cli;
          inherit (inputs) cardano-configurations;
          inherit (config.packages) cardanow-ts refresh-available-snapshots-state;
        };
        cardanow-preview = config.packages.cardanow-mainnet.override {
          network = "preview";
          inherit (inputs'.mithril-preview.packages) mithril-client-cli;
        };
        cardanow-preprod = config.packages.cardanow-mainnet.override {
          network = "preprod";
        };
        cardanow-ts = inputs.dream2nix.lib.evalModules {
          packageSets. nixpkgs = inputs.dream2nix.inputs.nixpkgs.legacyPackages.${ system};
          modules = [
            ./cardanow-ts.nix
          ];
        };
      };
    };
}

