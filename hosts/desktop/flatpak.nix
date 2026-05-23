{ pkgs, ... }: {

  # Flatpak — sandbox'lı uygulama yönetimi
  services.flatpak.enable = true;

  # Distrobox — containerized Linux ortamları
  # Arch, Ubuntu vs. container içinde çalıştır, GUI host'ta açılır
  environment.systemPackages = with pkgs; [
    distrobox
    podman
  ];

  virtualisation.podman = {
    enable       = true;
    dockerCompat = false;
  };
}
