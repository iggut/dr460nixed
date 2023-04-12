{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.dr460nixed;
in
{
  options.dr460nixed = {
    desktop = lib.mkOption
      {
        default = true;
        type = types.bool;
        internal = true;
        description = lib.mdDoc ''
          Whether this is a desktop device.
        '';
      };
    rpi = lib.mkOption
      {
        default = true;
        type = types.bool;
        internal = true;
        description = lib.mdDoc ''
          Whether this is a Raspberry Pi.
        '';
      };
    nodocs = lib.mkOption
      {
        default = true;
        type = types.bool;
        internal = true;
        description = lib.mdDoc ''
          Whether to disable the documentation.
        '';
      };
    common = {
      enable = lib.mkOption
        {
          default = true;
          type = types.bool;
          internal = true;
          description = lib.mdDoc ''
            Whether to enable common system configurations.
          '';
        };
    };
  };

  config = mkIf cfg.common.enable
    {
      # We want to use NetworkManager
      networking = {
        # Pointing to our Adguard instance via Tailscale
        nameservers = [ "1.1.1.1" ];
        networkmanager = lib.mkIf config.dr460nixed.desktop or config.dr460nixed.rpi {
          dns = "none";
          enable = true;
          wifi.backend = "iwd";
        };
        # Disable non-NetworkManager
        useDHCP = lib.mkDefault false;
      };
      ## Enable BBR & cake
      boot.kernelModules = [ "tcp_bbr" ];
      boot.kernel.sysctl = {
        "kernel.nmi_watchdog" = 0;
        "kernel.printks" = "3 3 3 3";
        "kernel.sched_cfs_bandwidth_slice_us" = 3000;
        "kernel.sysrq" = 1;
        "kernel.unprivileged_userns_clone" = 1;
        "net.core.default_qdisc" = "cake";
        "net.core.rmem_max" = 2500000;
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.ipv4.tcp_fin_timeout" = 5;
        "vm.max_map_count" = 16777216; # helps with Wine ESYNC/FSYNC
        "vm.swappiness" = 60;
      };

      # Microcode and firmware updates
      hardware = {
        cpu = {
          amd.updateMicrocode = true;
          intel.updateMicrocode = true;
        };
        enableRedistributableFirmware = true;
      };
      services.fwupd.enable = true;

      # # Kernel paramters & settings
      # boot = lib.mkIf config.dr460nixed.desktop {
      #   kernelParams = [
      #     # Disable all mitigations
      #     "mitigations=off"
      #     "nopti"
      #     "tsx=on"
      #     # Laptops and desktops don't need watchdog
      #     "nowatchdog"
      #     # https://github.com/NixOS/nixpkgs/issues/35681#issuecomment-370202008
      #     "systemd.gpt_auto=0"
      #     # https://www.phoronix.com/news/Linux-Splitlock-Hurts-Gaming
      #     "split_lock_detect=off"
      #   ];
      # };

      # We want to be insulted on wrong passwords
      security.sudo = {
        execWheelOnly = true;
        extraConfig = ''
          Defaults pwfeedback
          deploy ALL=(ALL) NOPASSWD:ALL
        '';
        package = pkgs.sudo.override { withInsults = true; };
      };

      # Increase open file limit for sudoers
      security.pam.loginLimits = [
        {
          domain = "@wheel";
          item = "nofile";
          type = "soft";
          value = "524288";
        }
        {
          domain = "@wheel";
          item = "nofile";
          type = "hard";
          value = "1048576";
        }
      ];

      # Programs I always need
      programs = {
        git = {
          enable = true;
          lfs.enable = true;
        };
        # The GnuPG agent
        gnupg.agent.enable = true;
        # Use the performant openssh
        ssh.package = pkgs.openssh_hpn;
      };

      # Always needed services
      services = {
        locate = {
          enable = true;
          localuser = null;
          locate = pkgs.plocate;
        };
        openssh = {
          enable = true;
          startWhenNeeded = true;
        };
        vnstat.enable = true;
      };

      # Better for mobile device SSH
      programs.mosh.enable = true;
      environment.variables = { MOSH_SERVER_NETWORK_TMOUT = "604800"; };

      # Who needs documentation when there is the internet? #bl04t3d
      documentation = lib.mkIf config.dr460nixed.nodocs {
        doc.enable = false;
        enable = false;
        info.enable = false;
        man.enable = false;
        nixos.enable = false;
      };

      # Zerotier network to connect the devices
      networking.firewall.trustedInterfaces = [ "tailscale0" ];
      services.tailscale = {
        enable = true;
        permitCertUid = "nico";
      };

      # General nix settings
      nix = {
        # Do garbage collections whenever there is less than 1GB free space left
        extraOptions = ''
          min-free = ${toString (1024 * 1024 * 1024)}
        '';
        # Do daily garbage collections
        gc = {
          automatic = true;
          dates = "daily";
          options = "--delete-older-than 7d";
        };
        settings = {
          # Only allow the wheel group to handle Nix
          allowed-users = [ "@wheel" ];
          # Allow using flakes
          auto-optimise-store = true;
          # A few extra binary caches
          extra-substituters = [
            "https://colmena.cachix.org"
            "https://dr460nf1r3.cachix.org"
            "https://garuda-linux.cachix.org"
            "https://nix-community.cachix.org"
            "https://nyx.chaotic.cx"
          ];
          extra-trusted-public-keys = [
            "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
            "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
            "dr460nf1r3.cachix.org-1:ujkI5l3i3m6Jh3J8phRXtnUbKdrn7JIxb/dPAO3ePbI="
            "garuda-linux.cachix.org-1:tWw7YBE6qZae0L6BbyNrHo8G8L4sHu5QoDp0OXv70bg="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "nyx.chaotic.cx-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
          ];
          # This is a flake after all
          experimental-features = [ "nix-command" "flakes" ];
          max-jobs = "auto";
          system-features = [ "kvm" "big-parallel" ];
          trusted-users = [ "root" "nico" "deploy" ];
        };
        nixPath = [ "nixpkgs=${sources.nixpkgs}" ];
      };

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      # Clean results periodically
      systemd.services.nix-clean-result = {
        serviceConfig.Type = "oneshot";
        description = "Auto clean all result symlinks created by nixos-rebuild test";
        script = ''
          "${config.nix.package.out}/bin/nix-store" --gc --print-roots | "${pkgs.gawk}/bin/awk" 'match($0, /^(.*\/result) -> \/nix\/store\/[^-]+-nixos-system/, a) { print a[1] }' | xargs -r -d\\n rm
        '';
        before = [ "nix-gc.service" ];
        wantedBy = [ "nix-gc.service" ];
      };

      nixpkgs.config.permittedInsecurePackages = [
        "openssh-with-hpn-9.2p1"
      ];

      # Print a diff when running system updates
      system.activationScripts.diff = ''
        if [[ -e /run/current-system ]]; then
          (
            for i in {1..3}; do
              result=$(${config.nix.package}/bin/nix store diff-closures /run/current-system "$systemConfig" 2>&1)
              if [ $? -eq 0 ]; then
                printf '%s' "$result"
                break
              fi
            done
          )
        fi
      '';

      # Automatic system upgrades
      system.autoUpgrade = {
        enable = true;
        dates = "hourly";
        flags = [ "--refresh" ];
        flake = "github:dr460nf1r3/device-configurations";
      };
    };
}