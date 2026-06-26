# /etc/nixos/modules/core.nix
{ pkgs, inputs, system, ... }:
{
  boot.loader.systemd-boot.enable = pkgs.lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable    = true;
    pkiBundle = "/etc/secureboot";
  };

  boot.extraModprobeConfig = ''
    options btusb enable_autosuspend=0
  '';

  hardware.bluetooth = {
    enable      = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  networking.networkmanager.enable = true;

  zramSwap = {
    enable        = true;
    memoryPercent = 50;
    algorithm     = "zstd";
  };

  users.users.kagan = {
    isNormalUser = true;
    description  = "kagan";
    extraGroups  = [ "networkmanager" "wheel" "gamemode" "video" "audio" ];
  };

  nix = {
    settings = {
      experimental-features     = [ "nix-command" "flakes" ];
      auto-optimise-store       = true;
      extra-substituters        = [
        "https://noctalia.cachix.org"
        "https://nix-community.cachix.org"
      ];
      extra-trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      dates     = "daily";
      options   = "--delete-older-than 5d";
    };
  };

  services.journald.extraConfig = ''
    SystemMaxUse=500M
    SystemKeepFree=1G
    MaxFileSec=1week
  '';

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc glibc zlib zstd openssl glib dbus udev fuse3
      curl icu nss nspr krb5 libGL mesa vulkan-loader libdrm libva
      libxkbcommon
      libx11 libxext libxrender libxtst libxdamage libxcb
      libxcomposite libxfixes libxrandr
      gtk3 atk pango cairo gdk-pixbuf
      alsa-lib pulseaudio freetype fontconfig expat
    ];
  };

  environment.localBinInPath = true;

  # NH_FLAKE: nh komutlarında flake yolunu varsayılan yap
  environment.variables.NH_FLAKE = "/etc/nixos#nixos";

  environment.systemPackages = with pkgs; [
    nh                     # zaten var
    nix-output-monitor
    inputs.nix-alien.packages.${system}.nix-alien
    nix-index
  ];

  system.stateVersion = "25.11";
}
