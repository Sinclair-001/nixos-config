{ config, pkgs, ... }: {

  # RTX 3060 Ti — Turing mimarisi, open kernel module önerilir
  hardware.graphics = {
    enable      = true;
    enable32Bit = true; # Steam + Wine + DXVK için şart
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable          = true;
    open                        = true; # Turing+ için NVIDIA'nın open kernel module'ü
    nvidiaSettings              = true;
    powerManagement.enable      = false;
    powerManagement.finegrained = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Wayland + NVIDIA için gerekli ortam değişkenleri
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME         = "nvidia";
    GBM_BACKEND               = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS   = "1";  # MangoWM cursor fix
    NIXOS_OZONE_WL            = "1";  # Electron/Chrome native Wayland
    MOZ_ENABLE_WAYLAND        = "1";  # Firefox native Wayland
    QT_QPA_PLATFORM           = "wayland";
    SDL_VIDEODRIVER           = "wayland";
    CLUTTER_BACKEND           = "wayland";
    PROTON_ENABLE_WAYLAND     = "1";  # Proton native Wayland rendering
  };
}
