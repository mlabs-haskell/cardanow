# Deploy
The nixos machine that is running the service is defined in `.nix` files and can be deployed with this command
```bash
nixos-rebuild --flake .#cardanow switch --target-host $HOST_LOCATION
```
It is possible to specify another host for the build
```bash
nixos-rebuild --flake .#cardanow switch --target-host $HOST_LOCATION --build-host $BUILDER_LOCATION 
```
