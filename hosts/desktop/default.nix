{ ... }: {
  imports = [
    ../../hardware-configuration.nix
    ./boot.nix
    ./nvidia.nix
    ./desktop.nix
    ./gaming.nix
    ./services.nix
    ./packages.nix
    ./flatpak.nix
  ];
}
