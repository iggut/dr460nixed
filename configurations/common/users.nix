{
  keys,
  config,
  home-manager,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  # All users are immuntable; if a password is required it needs to be set via passwordFile
  users.mutableUsers = false;

  # This is needed for early set up of user accounts
  sops.secrets."passwords/iggut" = {
    neededForUsers = true;
  };
  sops.secrets."passwords/root" = {
    neededForUsers = true;
  };

  # This is for easy configuration roll-out
  users.users.deploy = {
    extraGroups = ["wheel"];
    home = "/home/deploy";
    isNormalUser = true;
    openssh.authorizedKeys = {
      keyFiles = [keys.iggut];
      keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBa5YB2FSxQZLFn2OraC0U+UGVaurOgQThC+yYz+3OE+"];
    };
    password = "*";
    uid = 2000;
  };
  # Lock root password
  users.users.root = {
    #passwordFile = config.sops.secrets."passwords/root".path;
  };
  # My user
  users.users.iggut = {
    extraGroups =
      [
        "audio"
        "systemd-journal"
        "video"
        "wheel"
      ]
      ++ ifTheyExist [
        "adbusers"
        "chaotic_op"
        "deluge"
        "disk"
        "docker"
        "flatpak"
        "git"
        "kvm"
        "libvirtd"
        "mysql"
        "network"
        "networkmanager"
        "podman"
        "wireshark"
      ];
    home = "/home/iggut";
    isNormalUser = true;
    openssh.authorizedKeys.keyFiles = [keys.iggut];
    password = "tempPASS";
    #passwordFile = config.sops.secrets."passwords/iggut".path;
    uid = 1000;
  };

  # Load my home-manager configurations
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."iggut" = import ../home/common.nix;
  };

  # Allow pushing to Cachix
  sops.secrets."api_keys/cachix" = {
    mode = "0600";
    owner = config.users.users.iggut.name;
    path = "/home/iggut/.config/cachix/cachix.dhall";
  };
}
