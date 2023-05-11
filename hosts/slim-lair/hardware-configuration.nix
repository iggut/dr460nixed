{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.extraModulePackages = [];
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usbhid"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/d05f4b88-767b-4080-baef-4b33c003b691";
    fsType = "btrfs";
    options = ["subvol=@nixos" "compress=zstd" "noatime"];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/d05f4b88-767b-4080-baef-4b33c003b691";
    fsType = "btrfs";
    options = ["subvol=@home" "compress=zstd" "noatime"];
  };
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/d05f4b88-767b-4080-baef-4b33c003b691";
    fsType = "btrfs";
    options = ["subvol=@nix" "compress=zstd" "noatime"];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E16B-40F6";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/82be5447-8e53-43f1-b806-82f36f0a5926";}
  ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
