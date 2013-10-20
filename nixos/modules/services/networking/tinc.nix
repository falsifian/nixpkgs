{ config, pkgs, ... }:

with pkgs.lib;

let

  tincUser = "tinc";

in

{

  ###### interface

  options = {

    services.tinc = {

      enable = mkOption {
        default = true;
        description = "TODO";
      };

    };

  };


  ###### implementation

  config = mkIf config.services.tinc.enable {

    # Make tools such as ntpq available in the system path
    environment.systemPackages = [ pkgs.tinc ];

    users.extraUsers = singleton
      { name = tincUser;
        uid = config.ids.uids.tinc;
        description = "tinc daemon user";
        home = TODO;
      };

    jobs.tinc =
      { description = "TODO";

        wantedBy = [ "ip-up.target" ];  # TODO check
        partOf = [ "ip-up.target" ];  # TODO check

        path = [ tinc ];  # TODO what is this?

        preStart =
          ''
            # TODO change this
            mkdir -m 0755 -p ${stateDir}
            chown ${ntpUser} ${stateDir}
          '';

        exec = "tinc --TODO";
      };

  };

}
