{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.dr460nixed.locales;
  cfgDesktops = config.dr460nixed.desktops;
  defaultLocale = "en_US.UTF-8";
  terminus-variant = "116n";
in {
  options.dr460nixed.locales = {
    enable =
      mkOption
      {
        default = true;
        type = types.bool;
        description = mdDoc ''
          Whether the operating system be having a default set of locales set.
        '';
      };
  };

  config = mkIf cfg.enable {
    # Timezone
    time = {
      hardwareClockInLocalTime = true;
      timeZone = "America/Toronto";
    };

    # Common locale settings
    i18n = {
      inherit defaultLocale;

      extraLocaleSettings = {
        LANG = defaultLocale;
        LC_COLLATE = defaultLocale;
        LC_CTYPE = defaultLocale;
        LC_MESSAGES = defaultLocale;

        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };

      supportedLocales = [
        "en_CA.UTF-8/UTF-8"
        "en_GB.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
      ];
    };

    # Console font
    console = {
      font = "${pkgs.terminus_font}/share/consolefonts/ter-${terminus-variant}.psf.gz";
      keyMap = "us";
    };

    # X11 keyboard layout
    services.xserver = mkIf cfgDesktops.enable {
      layout = "us";
      xkbVariant = "";
    };
  };
}
