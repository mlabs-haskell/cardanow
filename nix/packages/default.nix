{ inputs, ... }: {
  perSystem = { pkgs, inputs', system, config, ... }:
    {
      packages = {
        get-s3-state = pkgs.writeShellApplication {
          name = "get-s3-state";
          runtimeInputs = with pkgs; [ awscli2 jq ];
          text =
            let
              # TODO: handle this variable better (e.g. move in a better place, some vars are duplicated in scheduled tasks) 
              awsEndpoint = "https://pub-b887f41ffaa944ebaae543199d43421c.r2.dev/";
              outFile = "andrea-change-this.json";
              bucketName = "cardanow";
            in
              ''aws s3api list-objects-v2 --bucket ${bucketName} --query "Contents[].{Key:Key, LastModified:LastModified}" | jq '.[] | .Key = "${awsEndpoint}" + .Key' > ${outFile}'';
        };
        cleanup-local-data = pkgs.writeShellApplication {
          name = "cleanup-local-data";
          runtimeInputs = with pkgs; [ bash ];
          text = ../../bin/cleanup-local-data.sh;
        };
        cleanup-s3-data = pkgs.writeShellApplication {
          name = "cleanup-local-data";
          runtimeInputs = with pkgs; [ awscli2 bash jq ];
          text = ''${../../bin/cleanup-s3-data.sh} "$@"'';
        };

        upload-data = pkgs.writeShellApplication {
          name = "upload-data";
          runtimeInputs = with pkgs; [ bash awscli2 ];
          text = ''${../../bin/upload-data.sh} "$@"'';
        };

        cardanow = pkgs.writeShellApplication
          {
            name = "cardanow";
            runtimeInputs = with pkgs; [
              inputs'.cardano-node.packages.cardano-cli
              inputs'.mithril.packages.mithril-client-cli
              git
              openssh
              config.packages.cardanow-ts
              config.packages.upload-data
              curl
              jq
            ];
            text = ''
              # TODO there is probably a better way to write this
              ln -sfT ${../../config/mithril-configurations} mithril-configurations
              ln -sfT ${../../config/docker-compose.yaml} docker-compose.yaml
              ln -sfT ${inputs.cardano-configurations} cardano-configurations

              # shellcheck source=/dev/null
              source "${../../setup_env_vars.sh}"
              # shellcheck source=/dev/null
              source "${../../entrypoint.sh}"

            '';
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

