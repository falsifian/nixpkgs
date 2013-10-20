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

  startupScript = netName: pkgs.writeScript "start_tinc_${netName}.sh" ''
    #! ${pkgs.stdenv.shell}
    ${pkgs.tinc}/sbin/tincd -n ${netName} \
      --no-detach \
      --pidfile="${stateDir}/tinc.${netName}.pid"
  '';


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

    users.extraUsers = singleton
      { name = tincUser;
        uid = config.ids.uids.tinc;
        description = "tinc daemon user";
      };

    jobs = flip pkgs.lib.mapAttrs' cfg.networks (netName: netCfg:
      nameValuePair
        "tinc_${netName}"
        { description = "TODO";
  
          wantedBy = [ "ip-up.target" ];
          partOf = [ "ip-up.target" ];

          preStart =
            ''
              mkdir -m 0755 -p ${stateDir}
              chown ${tincUser} ${stateDir}
            '';

          exec = "${startupScript netName} ";
        });

  };

}
