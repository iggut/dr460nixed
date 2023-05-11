{
  pkgs,
  lib,
  ...
}: {
  isoImage.volumeID = lib.mkForce "id-live";
  isoImage.isoName = lib.mkForce "id-live.iso";

  imports = [
    ../../configurations/common.nix
  ];

  # Enable a few selected custom settings
  dr460nixed = {
    common.enable = true;
    desktops.enable = true;
    shells.enable = true;
    boot.enable = true;
  };

  # This seems to be needed for not getting "root account locked"
  users.mutableUsers = lib.mkForce true;

  # Use the latest Linux kernel
  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    zfs.enableUnstable = true;
  };

  # Increase timeout
  boot.loader.timeout = lib.mkForce 10;

  # Needed for https://github.com/NixOS/nixpkgs/issues/58959
  boot.supportedFilesystems = lib.mkForce ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" "zfs"];

  # This is a live USB
  networking.hostName = "live-usb";

  # Otherwise set to "no" by my config
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";

  # Allow the usage of Calamares
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }q
    });
  '';

  # Enable the X server with all the drivers
  services.xserver = {
    displayManager = {
      autoLogin = {
        enable = true;
        user = "iggut";
      };
    };
    videoDrivers = ["nvidia" "amdgpu" "vesa" "modesetting"];
  };

  # Override default iso configuration
  networking.wireless.enable = lib.mkForce false;

  # Enable virtualization support
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
}
