with import ../nix/public-keys.nix; {
  "cardanow-environment.age".publicKeys = secret-managers ++ [ hosts.cardanow ];
  "grafana-admin-password.age".publicKeys = secret-managers ++ [ hosts.cardanow ];
}
