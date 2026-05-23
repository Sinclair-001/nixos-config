{ pkgs, ... }: {

  networking.hostName              = "nixbox";
  networking.networkmanager.enable = true;

  time.timeZone      = "Europe/Istanbul";
  i18n.defaultLocale = "tr_TR.UTF-8";
  console.keyMap     = "trq";

  hardware.bluetooth = {
    enable      = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store   = true;
  };

  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 30d";
  };

  nixpkgs.config.allowUnfree = true;

  users.users.kagan = {
    isNormalUser    = true;
    description     = "Kagan";
    extraGroups     = [
      "networkmanager" "wheel"
      "video" "audio" "gamemode"
    ];
    initialPassword = "nixos"; # İlk girişten sonra passwd ile değiştir
    shell           = pkgs.bash;
  };

  system.stateVersion = "25.05";
}
