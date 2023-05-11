{
  pkgs,
  config,
  lib,
  ...
}: {
  # Individual settings
  imports = [
    ../../configurations/common.nix
    ./hardware-configuration.nix
    "${builtins.fetchGit {
      url = "https://github.com/NixOS/nixos-hardware.git";
      rev = "f38f9a4c9b2b6f89a5778465e0afd166a8300680";
    }}/lenovo/thinkpad/t470s"
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [acpi_call];
    initrd.availableKernelModules = ["xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod"];
    kernelPackages = pkgs.linuxPackages_cachyos;
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      systemd-boot = {
        consoleMode = "max";
        editor = false;
        enable = true;
      };
    };
  };

  # Hostname
  networking.hostName = "tv-nixos";

  # SSD
  services.fstrim.enable = true;

  # Enable a few selected custom settings
  dr460nixed = {
    auto-upgrade = true;
    chromium = true;
    desktops.enable = true;
    docker-compose-runner."tv-nixos" = {
      source = ../../configurations/docker-compose/tv-nixos;
    };
    performance-tweaks.enable = true;
    servers = {
      enable = true;
      monitoring = true;
    };
  };

  # Yes, autologin on this one
  services.xserver.displayManager.sddm.settings = {
    Autologin = {
      User = "iggut";
      Session = "plasma";
    };
  };

  # Provide a reverse proxy for our services
  services.nginx = {
    enable = true;
    virtualHosts."tv-nixos.emperor-mercat.ts.net" = {
      extraConfig = ''
        location = /netdata {
              return 301 /netdata/;
        }
        location ~ /netdata/(?<ndpath>.*) {
          proxy_redirect off;
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-Server $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_http_version 1.1;
          proxy_pass_request_headers on;
          proxy_set_header Connection "keep-alive";
          proxy_store off;
          proxy_pass http://127.0.0.1:19999/$ndpath$is_args$args;

          gzip on;
          gzip_proxied any;
          gzip_types *;
        }
      '';
      forceSSL = true;
      http3 = true;
      sslCertificate = config.sops.secrets."ssl/tv-nixos-cert".path;
      sslCertificateKey = config.sops.secrets."ssl/tv-nixos-key".path;
    };
  };

  # Make the SSL secret key & cert available (aquired via Tailscale)
  sops.secrets."ssl/tv-nixos-key" = {
    mode = "0600";
    owner = "nginx";
    path = "/run/secrets/ssl/tv-nixos-key";
  };
  sops.secrets."ssl/tv-nixos-cert" = {
    mode = "0600";
    owner = "nginx";
    path = "/run/secrets/ssl/tv-nixos-cert";
  };

  # Enable the touchpad
  environment.systemPackages = with pkgs; [libinput];

  # Home-manager desktop configuration
  home-manager.users."iggut" = import ../../configurations/home/desktops.nix;

  # Currently plagued by https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;

  # NixOS stuff
  system.stateVersion = "22.11";
}
