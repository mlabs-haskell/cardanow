# Deploy

## VM

It is possible to test the machine configuration by running a virtual machine with the following command:

```bash
nix run .#vm
```

To turn the vm off you can simply run `poweroff`

## Cloud machine

The nixos machine that is running the service is defined in `.nix` files and can be deployed with this command

```bash
nixos-rebuild --flake .#cardanow switch --target-host $HOST_LOCATION
```

It is possible to specify another host for the build

```bash
nixos-rebuild --flake .#cardanow switch --target-host $HOST_LOCATION --build-host $BUILDER_LOCATION 
```

To simply test the configuration, you can use `test` instead of `switch`

```bash
nixos-rebuild --flake .#cardanow test --target-host $HOST_LOCATION
```

If the deployment is successful the next time the service will be started, the new version will be used, if you want to see the result immediately, you can restart the service by hand in the server: `systemctl status cardanow.service`.

## Check logs

The application will start as 3 separate systemd services, to check the log produced by it you can run

```bash
journalctl -u cardanow-preview.service
```

The actual data can be found in the home of the user: `/var/lib/cardanow`.
