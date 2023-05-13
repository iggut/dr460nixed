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
    device = "/dev/disk/by-uuid/67feb171-80aa-4ab6-b09a-1f325d28d309";
    fsType = "btrfs";
    options = ["subvol=@nixos" "compress=zstd" "noatime"];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/67feb171-80aa-4ab6-b09a-1f325d28d309";
    fsType = "btrfs";
    options = ["subvol=@home" "compress=zstd" "noatime"];
  };
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/67feb171-80aa-4ab6-b09a-1f325d28d309";
    fsType = "btrfs";
    options = ["subvol=@nix" "compress=zstd" "noatime"];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/862E-0D8E";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/dd5bdf2d-a81a-4971-9c7f-ca4897399f90";}
  ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
