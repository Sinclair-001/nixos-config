{ pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelModules  = [ "ntsync" ];
  boot.kernelParams   = [ "transparent_hugepage=always" ];

  services.udev.extraRules = ''
    KERNEL=="ntsync", TAG+="uaccess"
  '';

  programs = {
    steam = {
      enable                    = true;
      remotePlay.openFirewall   = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable   = false;
    };
    gamemode = {
      enable = true;
      settings = {
        general = {
          softrealtime        = "auto";
          inhibit_screensaver = 1;
        };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          nv_powermizer_mode      = 1;  # RTX 3060 — maksimum performans
        };
      };
    };
    gamescope = {
      enable     = true;
      capSysNice = true;
    };
  };

  security.unprivilegedUsernsClone = true;

  boot.kernel.sysctl = {
    "vm.max_map_count"                 = 2147483642;  # Proton için zorunlu
    "vm.swappiness"                    = 10;
    "vm.dirty_ratio"                   = 10;
    "vm.dirty_background_ratio"        = 5;
    "vm.compaction_proactiveness"      = 0;           # Mikro taklamaları önler
    "net.ipv4.tcp_window_scaling"      = 1;
    "kernel.sched_autogroup_enabled"   = 0;
    "kernel.sched_latency_ns"          = 4000000;
    "kernel.sched_min_granularity_ns"  = 500000;
    "kernel.unprivileged_userns_clone" = 1;
    "kernel.split_lock_mitigate"       = 0;           # Bazı DX oyunları gerektirir
    "user.max_user_namespaces"         = 10000;
  };

  environment.sessionVariables = {
    # ─── Proton / Wine ──────────────────────────────────────────────────────
    PROTON_ENABLE_NVAPI     = "1";   # RTX 3060 DLSS/RTX aktif
    PROTON_USE_NTSYNC       = "1";
    PROTON_ENABLE_WAYLAND   = "1";
    WINE_FULLSCREEN_FSR     = "1";
    WINE_IPV6               = "0";
    WLR_DRM_NO_ATOMIC       = "0";

    # ─── DXVK ───────────────────────────────────────────────────────────────
    DXVK_LOG_LEVEL          = "none";
    DXVK_FRAME_RATE         = "0";

    # ─── NVIDIA Shader Cache ─────────────────────────────────────────────────
    __GL_SHADER_DISK_CACHE              = "1";
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
    __GL_SHADER_DISK_CACHE_SIZE         = "10000000000";
  };

  environment.systemPackages = with pkgs; [
    lutris
    (pkgs.symlinkJoin {
      name       = "heroic";
      paths      = [ pkgs.heroic ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild  = ''
        wrapProgram $out/bin/heroic \
          --add-flags "--ozone-platform=x11" \
          --add-flags "--disable-gpu-sandbox" \
          --add-flags "--disable-features=VizDisplayCompositor" \
          --unset NIXOS_OZONE_WL \
          --unset ELECTRON_OZONE_PLATFORM_HINT \
          --unset VK_LAYER_PATH \
          --unset WAYLAND_DISPLAY
      '';
    })
    protonplus
    mangohud
    nvtopPackages.full
    vulkan-tools
    mesa-demos
    renderdoc
    wineWow64Packages.staging
    protontricks
    winetricks
  ];
}
