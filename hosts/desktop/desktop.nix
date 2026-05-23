{ pkgs, ... }: {

  # MangoWM — mangowm flake'ten geliyor (flake.nix'te tanımlı)
  programs.mango.enable = true;

  # KDE Plasma 6 — fallback masaüstü
  services.xserver.enable               = true;
  services.desktopManager.plasma6.enable = true;

  # ly display manager — minimal, TTY tabanlı
  services.displayManager.ly.enable = true;

  # XDG Desktop Portal — ekran paylaşımı, dosya seçici
  xdg.portal = {
    enable       = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr  # MangoWM (wlroots tabanlı) için
      xdg-desktop-portal-kde  # KDE için
    ];
    config = {
      common.default = [ "wlr" ];
      KDE.default    = [ "kde" ];
    };
  };

  # PipeWire — ses sistemi
  security.rtkit.enable = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
  };

  # Polkit — GUI yetkilendirme
  security.polkit.enable = true;

  # Font'lar
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];
}
