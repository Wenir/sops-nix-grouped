# sops-nix-grouped

A small NixOS module that lets you group related sops-nix secrets under a named namespace, so shared options like `sopsFile` are declared once instead of being repeated for every secret

## Without the module

```nix

    sops.secrets = {
      namespace1--private-key = {
        sopsFile = ./secrets.yaml;
        key = "private-key";
      };
      namespace1--some-password = {
        sopsFile = ./secrets.yaml;
        key = "some-password";
      };
    };
    nix.extraOptions = ''
      secret-key-files = ${config.sops.secrets.namespace--private-key.path}
    '';

```

## With the module

```nix

    sops-grouped.namespace1 = {
      sopsFile = ./secrets.yaml;

      secrets = {
        private-key = {};
        some-password = {};
      };
    };

    nix.extraOptions = ''
      secret-key-files = ${config.sops-grouped.namespace1.secrets.private-key.final.path}
    '';

```

Note: `[...].x.final` option exposes final values defined in `config.sops.secrets.x.`

## Placeholder

Placeholder for the secret can be accessed via `.placeholder`

```nix

config.sops-grouped.namespace1.secrets.private-key.placeholder

# is equivalent to 

config.sops.placeholder."namespace1--private-key"

```