{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.dr460nixed.desktops;
in {
  options.dr460nixed.desktops = {
    enable =
      mkOption
      {
        default = false;
        type = types.bool;
        description = mdDoc ''
          Whether to enable basic dr460nized desktop theming.
        '';
      };
  };

  config = mkIf cfg.enable {
    services.xserver = {
      desktopManager.plasma5.enable = true;
      displayManager = {
        sddm = {
          autoNumlock = true;
          enable = true;
          settings = {
            General = {Font = "Fira Sans";};
            # Autologin = { User = "iggut"; Session = "plasma"; };
          };
          theme = "Sweet";
        };
      };
      enable = true;
      excludePackages = [pkgs.xterm];
    };

    # Allow GTK applications to disable an appmenu on KDE
    chaotic.appmenu-gtk3-module.enable = true;

    # Currently needed to obtain nightly Rustdesk
    services.flatpak.enable = true;

    # Remove a few applications that aren't needed
    environment.plasma5.excludePackages = with pkgs;
    with libsForQt5; [
      oxygen
      plasma-browser-integration
    ];

    # Additional KDE packages not included by default
    environment.systemPackages = with pkgs; [
      applet-window-appmenu
      applet-window-title
      beautyline-icons
      dr460nized-kde-theme
      firedragon
      jamesdsp
      libinput-gestures
      libsForQt5.applet-window-buttons
      libsForQt5.kdegraphics-thumbnailers
      libsForQt5.kimageformats
      libsForQt5.qtstyleplugin-kvantum
      resvg
      sshfs
      sweet
      sweet-nova
      vlc
      xdg-desktop-portal
    ];

    # Define the default fonts Fira Sans & Jetbrains Mono Nerd Fonts
    fonts = {
      enableDefaultFonts = false;
      fonts = with pkgs; [
        fira
        (nerdfonts.override {
          fonts = [
            "JetBrainsMono"
          ];
        })
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
      ];
      fontconfig = {
        cache32Bit = true;
        defaultFonts = {
          emoji = ["Noto Color Emoji"];
          monospace = ["JetBrains Mono Nerd Font" "Noto Fonts Emoji"];
          sansSerif = ["Fira" "Noto Fonts Emoji"];
          serif = ["Fira" "Noto Fonts Emoji"];
        };
        # This fixes emoji stuff
        enable = true;
      };
      fontDir = {
        enable = true;
        decompressFonts = true;
      };
    };

    # KDE Connect to connect my phone & Partition Manager
    programs = {
      kdeconnect.enable = true;
      partition-manager.enable = true;
    };

    # Enable Kvantum for theming
    environment.variables = {
      ALSOFT_DRIVERS = "pipewire";
      MOZ_USE_XINPUT2 = "1";
      QT_STYLE_OVERRIDE = "kvantum";
      SDL_AUDIODRIVER = "pipewire";
    };

    # Power profiles daemon
    services.power-profiles-daemon.enable = true;

    # LAN discovery
    services.avahi = {
      enable = true;
      nssmdns = true;
    };

    # Bluetooth
    hardware.bluetooth.enable = true;

    # GPU acceleration
    hardware.opengl = {
      driSupport = true;
      driSupport32Bit = true;
      enable = true;
    };

    # Enable the sound in general
    sound.enable = true;

    # Disable PulseAudio
    hardware.pulseaudio.enable = false;

    # Enable the realtime kit
    security.rtkit.enable = true;

    # Pipewire & wireplumber configuration
    services.pipewire = {
      alsa.enable = true;
      alsa.support32Bit = true;
      enable = true;
      pulse.enable = true;
      systemWide = false;
      wireplumber.enable = true;
    };

    # # Kernel paramters & settings
    boot.kernelParams = [
      "mitigations=off"
      "nopti"
      "nowatchdog"
      "split_lock_detect=off" # https://www.phoronix.com/news/Linux-Splitlock-Hurts-Gaming
      "systemd.gpt_auto=0" # https://github.com/NixOS/nixpkgs/issues/35681#issuecomment-370202008
      "tsx=on"
    ];
  };
}
