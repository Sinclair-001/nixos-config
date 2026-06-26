{ config, pkgs, lib, ... }:
let
  lowLatencyLayer = pkgs.stdenv.mkDerivation rec {
    pname   = "low-latency-layer";
    version = "0.2.0";
    src     = pkgs.fetchFromGitHub {
      owner = "Korthos-Software";
      repo  = "low_latency_layer";
      rev   = "v${version}";
      hash  = "sha256-mnGAH0m19wOkWEowpcPRHXQSc6HGYW+CFYxjPF2onk4=";
    };
    nativeBuildInputs = [ pkgs.cmake ];
    buildInputs = [
      pkgs.vulkan-headers
      pkgs.vulkan-loader
      pkgs.vulkan-utility-libraries
    ];
  };
in
{
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
    extraPackages = [
      lowLatencyLayer
      pkgs.nvidia-vaapi-driver
      pkgs.libva-vdpau-driver
    ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable          = true;
    powerManagement.enable      = true;
    powerManagement.finegrained = false;
    open                        = true;   # RTX 3060 (Ampere) — open modül destekli
    nvidiaSettings              = true;
    package                     = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.systemPackages = with pkgs; [
    nvidia-vaapi-driver
    libva-vdpau-driver
    libva
    libva-utils
    lowLatencyLayer
  ];

  environment.sessionVariables = {
    # ─── Wayland / Display ──────────────────────────────────────────────────
    NIXOS_OZONE_WL              = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    XDG_CURRENT_DESKTOP         = "mango:wlroots";
    WLR_NO_HARDWARE_CURSORS     = "1";

    # ─── NVIDIA Driver ──────────────────────────────────────────────────────
    __GLX_VENDOR_LIBRARY_NAME   = "nvidia";
    __GL_MaxFramesAllowed       = "1";    # RTX 3060 — input lag azaltma

    # ─── Video Decode / Encode ───────────────────────────────────────────────
    LIBVA_DRIVER_NAME           = "nvidia";
    VDPAU_DRIVER                = "nvidia";
    QT_FFMPEG_DECODING_HW_DEVICE_TYPES = "vaapi,vdpau";
    QT_FFMPEG_ENCODING_HW_DEVICE_TYPES = "vaapi,vdpau";

    # ─── RTX 3060 — Ampere DX12 Ultimate ────────────────────────────────────
    VKD3D_FEATURE_LEVEL         = "12_2";

    # ─── Electron / Browser ──────────────────────────────────────────────────
    MOZ_DISABLE_RDD_SANDBOX     = "1";
    ELECTRON_EXTRA_LAUNCH_ARGS  = "--disable-gpu-sandbox --disable-features=VizDisplayCompositor";
  };
}
