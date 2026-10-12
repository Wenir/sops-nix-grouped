{ pkgs, lib, config, ... }: let
  top = config;
in {
  options.sops-grouped = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({ name, config, ... }: let
      groupName = name;
    in {
      options = {
        sopsFile = lib.mkOption {
          type = lib.types.path;
        };

        secrets = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule ({ name, config, ... }: {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                default = groupName + "--" + name;
              };
              key = lib.mkOption {
                type = lib.types.str;
                default = name;
              };
              final = lib.mkOption {
                type = lib.types.attrs;
              };
            };
            freeformType = lib.types.attrsOf lib.types.unspecified;
            config = {
              final = top.sops.secrets."${config.name}";
            };
          }));
        };

        _result = lib.mkOption {
          type = lib.types.anything;
        };
      };
      freeformType = lib.types.attrsOf lib.types.unspecified;

      config = let 
        common = lib.attrsets.filterAttrs 
          (name: submodule: ! ((lib.hasPrefix "_" name) || name == "secrets"))
          config;
      in {
        _result = lib.mapAttrs' 
          (name: value: let
            filtered = lib.attrsets.filterAttrs 
              (name: submodule: ! ((lib.hasPrefix "_" name) || name == "final"))
              value;
          in {
            name = filtered.name;
            value = common // filtered;
          }) 
          config.secrets;
      };
    }));
  };
  config = {
    sops.secrets = 
      builtins.foldl' (acc: x: acc // x._result) {} (builtins.attrValues config.sops-grouped);

  };
}