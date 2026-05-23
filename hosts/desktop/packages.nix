{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Temel araçlar
    git
    wget
    curl
    unzip
    p7zip
    htop
    btop
    sbctl    # Lanzaboote / Secure Boot key yönetimi
    ntfs3g   # Windows NTFS partition okuma/yazma

    # Tarayıcı
    zen-browser
    firefox

    # Terminal
    kitty
    foot     # MangoWM varsayılan terminal (hafif)

    # Wayland araçları
    wl-clipboard            # kopyala-yapıştır
    cliphist                # clipboard geçmişi
    grim                    # ekran görüntüsü
    slurp                   # bölge seçimi
    wlr-randr               # monitor yönetimi
    wlogout                 # oturum kapatma menüsü
    swaylock-effects        # ekran kilidi
    swayidle                # boşta ekran kilidi
    swaync                  # bildirim daemon
    swaybg                  # duvar kağıdı
    wlsunset                # gece modu / blue light filter
    rofi-wayland            # uygulama başlatıcı

    # Polkit agent — GUI şifre isteği
    polkit_gnome

    # Gaming
    mangohud                # in-game FPS/GPU overlay
    protonup-qt             # Proton-GE yönetimi
    lutris                  # oyun launcher (Wuthering Waves vs.)
    heroic                  # Epic/GOG launcher
    bottles                 # Wine prefix yöneticisi
    winetricks
    wineWowPackages.staging
    vulkan-tools

    # KDE araçlar
    kdePackages.ark         # arşiv yöneticisi
    kdePackages.kate        # metin editörü
    kdePackages.kcalc       # hesap makinesi
    kdePackages.spectacle   # ekran görüntüsü (KDE)
    kdePackages.gwenview    # resim görüntüleyici
    kdePackages.dolphin     # dosya yöneticisi
  ];
}
