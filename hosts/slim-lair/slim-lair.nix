{
  config,
  lib,
  pkgs,
  ...
}: {
  # Individual settings
  imports = [
    ../../configurations/common.nix
    ../../configurations/services/chaotic.nix
    ./hardware-configuration.nix
  ];

  # Use Lanzaboote for secure boot
  boot = {
    supportedFilesystems = ["btrfs"];
    # Needed to get the touchpad to work
    blacklistedKernelModules = ["elan_i2c"];
    # The new AMD Pstate driver & needed modules
    #extraModulePackages = with config.boot.kernelPackages; [ acpi_call zenpower ];
    kernelModules = [
      "acpi_call"
      "vfio_pci"
      "vfio_iommu_type1"
      "vfio"
      "amdgpu"
    ];
    kernelPackages = pkgs.linuxPackages_cachyos;
    #kernelParams = [ "initcall_blacklist=acpi_cpufreq_init" ];
    kernelParams = [
      "intel_iommu=on"
      "kvm.ignore_msrs=1"
      "vfio-pci.ids=10de:2482,10de:228b"
    ];
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
  networking.hostName = "slim-lair";

  # SSD
  services.fstrim.enable = true;

  # AMD device
  services.hardware.bolt.enable = false;
  services.xserver.videoDrivers = [ "amdgpu" ];

  # enables AMDVLK & OpenCL support
  hardware.opengl.extraPackages = with pkgs; [
    amdvlk
  ];
  hardware.opengl.extraPackages32 = with pkgs; [
    driversi686Linux.amdvlk
  ];

  # Bleeding edge Mesa - broken on master
  chaotic.mesa-git.enable = true;

  # Enable a few selected custom settings
  dr460nixed = {
    chromium = true;
    desktops.enable = true;
    development.enable = true;
    gaming.enable = true;
    garuda-chroot = {
      enable = false;
      root = "/var/lib/machines/garuda";
    };
    performance-tweaks.enable = true;
    school = true;
    yubikey = false;
  };

  # BTRFS stuff
  services.beesd.filesystems = {
    root = {
      spec = "LABEL=OS";
      hashTableSizeMB = 2048;
      verbosity = "crit";
      extraOptions = [ "--loadavg-target" "1.0" ];
    };
  };
  services.btrfs.autoScrub.enable = true;

  # Needed for Looking-Glass-Client
  systemd.tmpfiles.rules = ["f /dev/shm/looking-glass 0666 iggut kvm -"];

  # Currently plagued by https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
 

  # RADV video decode & general usage
  environment.variables = {
    AMD_VULKAN_ICD = "RADV";
    RADV_VIDEO_DECODE = "1";
  };

  # Enable the touchpad & secure boot, as well as add the ipman script
  environment.systemPackages = with pkgs; [ libinput radeontop zenmonitor ];

  # Home-manager desktop configuration
  home-manager.users."iggut" = import ../../configurations/home/desktops.nix;

  # A few secrets
  #.secrets."machine-id/slim-lair" = {
  #  path = "/etc/machine-id";
  #  mode = "0600";
  #};
  #sops.secrets."ssh_keys/id_rsa" = {
  #  mode = "0600";
  #  owner = config.users.users.iggut.name;
  #  path = "/home/iggut/.ssh/id_rsa";
  #};

  # NixOS stuff
  system.stateVersion = "22.11";
}
