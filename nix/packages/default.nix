{ inputs, ... }: {
  perSystem = { pkgs, inputs', system, config, lib, ... }:
    {
      packages = {
        s3-sync = pkgs.writeShellApplication {
          name = "s3-sync";
          runtimeInputs = with pkgs; [ awscli2 ];
          text = with import ../variables; "aws s3 sync ${EXPORTED_SNAPSHOT_BASE_PATH} ${BUCKET_LOCATION} --delete";
        };
        refresh-available-snapshots-state = pkgs.writeShellApplication {
          name = "refresh-available-snapshots-state";
          runtimeInputs = with pkgs; [
            awscli2
            jq
            python3
            config.packages.s3-sync
          ];
          text =
            with import ../variables;
            let
              awsEndpointEscaped = lib.escape [ ":" "/" "." ] AWS_PUBLIC_ENDPOINT_URL;
            in
            ''
              s3-sync
              aws s3api list-objects-v2 \
                  --output json \
                  --bucket ${BUCKET_NAME} \
                  --query "Contents[].{Key:Key, LastModified:LastModified}" \
              | sed 's/"Key": "\(.*\)\/\(.*\)\/\(.*\)-\([0-9]*\)-\([0-9]*\)\.tgz"/"Key": "${awsEndpointEscaped}\/\1\/\2\/\3-\4-\5.tgz", "Network": "\1", "DataSource": "\2", "Epoch": "\4", "ImmutableFileNumber": "\5"/g' \
              | python -m json.tool \
              > ${EXPORTED_SNAPSHOT_SUMMARY_FILE_PATH}
              echo "Syncing s3 bucket..."
              s3-sync
            '';

        };
        cleanup-local-data = pkgs.writeShellApplication {
          name = "cleanup-local-data";
          runtimeInputs = with pkgs; [
            awscli2
            bash
            config.packages.refresh-available-snapshots-state
            jq
            curl
            openssl
            otel-cli
          ];
          text = ''
            # shellcheck source=/dev/null
            source "${../../bin/utils.sh}"

            ${builtins.readFile ../../bin/cleanup-local-data.sh}
          '';
        };
        start-cardanow-monitoring-tmux = pkgs.writeShellApplication {
          name = "start-cardanow-monitoring-tmux";
          runtimeInputs = with pkgs; [ tmux btop ];
          text = builtins.readFile ../../bin/start-cardanow-monitoring-tmux.sh;
        };
        cardanow-mainnet = pkgs.callPackage ./cardanow.nix {
          inherit (inputs'.mithril.packages) mithril-client-cli;
          inherit (inputs'.cardano-node.packages) cardano-cli;
          inherit (inputs) cardano-configurations;
          inherit (config.packages) cardanow-ts cleanup-local-data;
        };
        cardanow-preview = config.packages.cardanow-mainnet.override {
          network = "preview";
          inherit (inputs'.mithril-preview.packages) mithril-client-cli;
        };
        cardanow-preprod = config.packages.cardanow-mainnet.override {
          network = "preprod";
        };
        cardanow-ts = inputs.dream2nix.lib.evalModules {
          packageSets.nixpkgs = inputs.dream2nix.inputs.nixpkgs.legacyPackages.${system};
          modules = [
            ./cardanow-ts.nix
          ];
        };
      };
    };
}

