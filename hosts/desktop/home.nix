{ pkgs, inputs, ... }: {

  home.username      = "kagan";
  home.homeDirectory = "/home/kagan";
  home.stateVersion  = "25.05";

  # Noctalia Shell — noctalia flake'ten paketi ekle
  home.packages = [
    inputs.noctalia.packages.${pkgs.system}.default
  ];

  # MangoWM konfigürasyonu — Home Manager modülü üzerinden
  wayland.windowManager.mango = {
    enable = true;
    settings = ''
      # Görünüm
      borderpx=2
      focuscolor=0x9b8dc8ff
      border_radius=8
      shadows=1
      blur=0

      # Animasyonlar
      animations=1
      animation_duration_open=250
      animation_duration_close=400

      # XWayland — Steam, Wine, Electron uygulamaları için şart
      xwayland=1

      # Klavye layout
      xkb_rules_layout=tr
    '';
    autostart_sh = ''
      # Noctalia Shell — bar, panel, bildirim katmanı
      noctalia &

      # Bildirim daemon
      swaync &

      # Duvar kağıdı — koyu arka plan
      swaybg -c "#1a1b26" &

      # Ekran kilidi — 5 dakika boşta kaldıktan sonra
      swayidle -w timeout 300 'swaylock -f' &

      # Clipboard geçmişi
      wl-paste --type text --watch cliphist store &
      wl-paste --type image --watch cliphist store &

      # Polkit agent — GUI şifre isteği (sudo gibi şeyler için)
      /run/current-system/sw/bin/polkit-gnome-authentication-agent-1 &
    '';
  };

  # Kitty terminal konfigürasyonu
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    settings = {
      background_opacity      = "0.95";
      confirm_os_window_close = 0;
      enable_audio_bell       = false;
      scrollback_lines        = 10000;
    };
  };

  # Git
  programs.git = {
    enable    = true;
    userName  = "kagan";
    userEmail = "email@example.com";
  };

  programs.home-manager.enable = true;
}
