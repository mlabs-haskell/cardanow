{
  perSystem = {inputs', pkgs, ...}: {
    packages."dockerImage/cardano-mithril" = inputs'.cardano-node.packages."dockerImage/node".overrideAttrs (old: {
      name = "cardano-mithril";
      fromImage = old.fromImage.overrideAttrs (old: {
	fromImage = pkgs.dockerTools.pullImage {
	  imageName = "ubuntu";
	  imageDigest = "sha256:145bacc9db29ff9c9c021284e5b7b22f1193fc38556c578250c926cf3c883a13";
	  sha256 = "sha256-2Abodpsn2CkDVWwNnAVPF1LLv9+Xsyorr0VFY8XtcJw";
	};
      });
      extraCommands = let
	entrypoint = pkgs.writeText "entrypoint" ''
          #!/bin/env bash

	  apt --version
	  ${inputs'.mithril.packages.mithril}/bin/mithril --version
	  
	  if [[ -n $NETWORK ]]; then
	    exec /usr/local/bin/run-network $@
	  elif [[ $1 == "run" ]]; then
	    exec /usr/local/bin/run-node $@
	  elif [[ $1 == "cli" ]]; then
	    exec /usr/local/bin/run-client $@
	  else
	    echo "Nothing to do! Perhaps try [run|cli], or set NETWORK environment variable."
	    exit 1
	  fi
        '';
      in ''
        ${old.passthru.buildArgs.extraCommands}
	cp ${entrypoint} /usr/local/bin/${entrypoint}
      '';
    });
  };
}
