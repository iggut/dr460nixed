{ config
, lib
, pkgs
, ...
}:
with lib;
let
  cfg = config.dr460nixed.hardening;
  cfgDesktops = config.dr460nixed.desktops.enable;
in
{
  options.dr460nixed.hardening = {
    enable = mkOption
      {
        default = true;
        type = types.bool;
        description = mdDoc ''
          Whether the operating system should be hardened.
        '';
      };
  };

  config = mkIf cfg.enable {
    boot.kernel.sysctl = {
      # The Magic SysRq key is a key combo that allows users connected to the
      # system console of a Linux kernel to perform some low-level commands.
      # Disable it, since we don't need it, and is a potential security concern.
      "kernel.sysrq" = 0;
      # Restrict ptrace() usage to processes with a pre-defined relationship
      # (e.g., parent/child)
      "kernel.yama.ptrace_scope" = 2;
      # Hide kptrs even for processes with CAP_SYSLOG
      "kernel.kptr_restrict" = 2;
      # Disable ftrace debugging
      "kernel.ftrace_enabled" = false;
    };

    boot.blacklistedKernelModules = [
      # Obscure network protocols
      "ax25"
      "netrom"
      "rose"
      # Old or rare or insufficiently audited filesystems
      "adfs"
      "affs"
      "befs"
      "bfs"
      "btusb"
      "cifs"
      "cramfs"
      "cramfs"
      "efs"
      "erofs"
      "exofs"
      "f2fs"
      "freevxfs"
      "freevxfs"
      "gfs2"
      "hfs"
      "hfsplus"
      "hpfs"
      "jffs2"
      "jfs"
      "ksmbd"
      "minix"
      "nfs"
      "nfsv3"
      "nfsv4"
      "nilfs2"
      "omfs"
      "qnx4"
      "qnx6"
      "sysv"
      "udf"
      "vivid"
    ];

    # Disable coredumps
    systemd.coredump.enable = false;



    # The hardening profile enables Apparmor by default, we don't want this to happen
    security.apparmor.enable = false;

    # Timeout TTY after 1 hour
    programs.bash.interactiveShellInit = "if [[ $(tty) =~ /dev\\/tty[1-6] ]]; then TMOUT=3600; fi";

    # Don't lock kernel modules, this is also enabled by the hardening profile by default
    security.lockKernelModules = false;

    # Run security analysis
    environment.systemPackages = with pkgs; [ lynis ];



    # Enable Firejail
    programs.firejail = mkIf cfgDesktops {
      enable = true;
      wrappedBinaries = {
        chromium = {
          executable = "${pkgs.chromium}/bin/chromium";
          profile = "${pkgs.firejail}/etc/firejail/chromium.profile";
          extraArgs = [
            "--dbus-user.talk=org.freedesktop.Notifications"
            "--env=GTK_THEME=Sweet-dark:dark"
            "--ignore=private-dev"
          ];
        };
      };
    };


  };
}
