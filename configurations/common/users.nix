{
  keys,
  config,
  home-manager,
  ...
}: {
  # All users are immuntable; if a password is required it needs to be set via passwordFile
  users.mutableUsers = true;

  # This is needed for early set up of user accounts
  #sops.secrets."passwords/iggut" = {
  #  neededForUsers = false;
  #};
  #sops.secrets."passwords/root" = {
  #  neededForUsers = false;
  #};

  # My user
  users.users.iggut = {
    extraGroups =
      [
        "audio"
        "systemd-journal"
        "video"
        "wheel"
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
    #openssh.authorizedKeys.keyFiles = [ keys.iggut ];
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
  #sops.secrets."api_keys/cachix" = {
  #  mode = "0600";
  #  owner = config.users.users.iggut.name;
  #  path = "/home/iggut/.config/cachix/cachix.dhall";
  #};
}
