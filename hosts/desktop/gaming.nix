{ pkgs, ... }: {

  # Steam — NixOS modülü tüm FHS bağımlılıklarını halleder
  programs.steam = {
    enable                       = true;
    remotePlay.openFirewall      = true;
    dedicatedServer.openFirewall = true;
    # Proton-GE declarative olarak ekle
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };

  # Gamemode — oyun sırasında CPU/GPU optimizasyonu
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device              = 0;
        nv_powermizer_mode      = 1; # NVIDIA maksimum performans modu
      };
    };
  };

  # Gamescope — Wayland compositing + upscaling
  programs.gamescope = {
    enable     = true;
    capSysNice = true;
  };
}
