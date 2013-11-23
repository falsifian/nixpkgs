{ config, pkgs, ... }:

with pkgs.lib;

let

  cfg = config.services.tinc;

  ## configDir = pkgs.stdenv.mkDerivation {
  ##   name = "tinc-conf";
  ##   buildCommand = ''
  ##     ensureDir "$out"
  ##     TODO
  ##   '';
  ## };

  ## networkOpts = { name, ... }: {
  ##   options = TODO;
  ## };

  stateDir = "/var/run/tinc";

  tincUser = "tinc";

in

{

  ###### interface

  options = {

    services.tinc = {

      enable = mkOption {
        default = false;
        description = "TODO";
      };

      networks = mkOption {
        # TODO example
        # TODO type
        # TODO options = [ networkOpts ];
        default = { };
        description = "TODO";
      };

    };

  };


  ###### implementation

  config = mkIf config.services.tinc.enable {

    ## TODO enable
    ## environment.etc = singleton
    ##   { source = configDir;
    ##     target = "tinc";
    ##   };

    boot.kernelModules = [ "tun" ];

    users.extraUsers = singleton
      { name = tincUser;
        uid = config.ids.uids.tinc;
        description = "tinc daemon user";
      };

    systemd.services = flip pkgs.lib.mapAttrs' cfg.networks (netName: netCfg:
      nameValuePair
        "tinc_${netName}"
        { description = "tinc VPN daemon for network \"${netName}\"";
  
          wantedBy = [ "ip-up.target" ];
          partOf = [ "ip-up.target" ];

          preStart =
            ''
              mkdir -m 0755 -p '${stateDir}'
              chown '${tincUser}' '${stateDir}'
            '';

          serviceConfig.ExecStart = ''
            ${pkgs.tinc}/sbin/tincd -n ${netName} --no-detach
              --pidfile=${stateDir}/tinc.${netName}.pid --user=tinc
          '';
        });

    # TODO: should this do something on nixos-rebuild switch?

  };

}
