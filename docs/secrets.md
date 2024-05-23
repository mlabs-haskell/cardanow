# Secrets

This project uses [agenix](https://github.com/ryantm/agenix) to store encrypted secrets directly in the repository and automatically decrypt them in NixOS hosts.

## Manage secrets

### Add a new secret manager

Someone that is already a secret manager has to add a new public key under `users` in [public-keys.nix](../nix/public-keys.nix) and run the following command:

```bash
cd secrets
agenix --rekey
```

### Add a secret

Add a line to `secrets.nix`, e.g.

```nix
with import ../nix/public-keys.nix; {
  # ...
  "new-secret.age".publicKeys = secret-managers ++ [ hosts.cardanow ];
  # ...
}
```

Be sure that your ssh public key is between `secret-managers` (it will be automatically if it's in `users` in [public-keys.nix](../nix/public-keys.nix)).

At this point run the following:

```bash
cd secrets
agenix --edit new-secret.age
```

Notice that:

- If you are using this flake's `devShell` then you already have `agenix` in your PATH
- `agenix` will read the `EDITOR` environment variable and use that executable to let you edit the secret

Type the secret and close the editor, at this point `agenix` will transparently encrypt it.
