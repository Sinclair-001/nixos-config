# /etc/nixos/modules/desktop.nix
{ pkgs, lib, inputs, system, ... }:
{
  services.displayManager.ly.enable      = true;
  services.desktopManager.plasma6.enable = true;
  services.flatpak.enable                = true;
  programs.mango.enable                  = true;
  services.dbus.enable                   = true;

  xdg.portal = {
    enable = true;
    extraPortals = lib.mkForce [
      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-wlr
    ];
    config = {
      plasma6.default = lib.mkForce [ "kde" ];
      mango = {
        default                                     = lib.mkForce [ "wlr" "kde" ];
        "org.freedesktop.impl.portal.Screenshot"    = lib.mkForce [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenCast"    = lib.mkForce [ "wlr" ];
        "org.freedesktop.impl.portal.FileChooser"   = lib.mkForce [ "kde" ];
        "org.freedesktop.impl.portal.Inhibit"       = lib.mkForce [ "kde" ];
        "org.freedesktop.impl.portal.Settings"      = lib.mkForce [ "kde" ];
        "org.freedesktop.impl.portal.AppChooser"    = lib.mkForce [ "kde" ];
        "org.freedesktop.impl.portal.Access"        = lib.mkForce [ "kde" ];
        "org.freedesktop.impl.portal.Account"       = lib.mkForce [ "kde" ];
        "org.freedesktop.impl.portal.Notification"  = lib.mkForce [ "kde" ];
        "org.freedesktop.impl.portal.Print"         = lib.mkForce [ "kde" ];
        "org.freedesktop.impl.portal.RemoteDesktop" = lib.mkForce [ "wlr" ];
      };
      wlroots = {
        default                                  = lib.mkForce [ "wlr" "kde" ];
        "org.freedesktop.impl.portal.Screenshot" = lib.mkForce [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenCast" = lib.mkForce [ "wlr" ];
      };
      common.default = lib.mkForce [ "wlr" "kde" ];
    };
  };

  systemd.user.services.xdg-desktop-portal-gtk.enable = false;

  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      adwaita-fonts
      font-awesome
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "Adwaita Sans"  "Noto Sans"  ];
      serif     = [ "Adwaita Serif" "Noto Serif" ];
    };
  };

  environment.systemPackages = with pkgs; [
    nodejs
    proton-vpn
    vesktop
    git vim neovim rofi brave wayland glib sbctl
    cliphist foot kitty fuzzel swaybg wl-clipboard localsend
    obsidian helium vlc loupe
    grim slurp

    # Zen-Browser – XWayland modunda (NVIDIA+Wayland'de stabil)
    (pkgs.symlinkJoin {
      name = "zen-browser";
      paths = [ inputs.zen-browser.packages.${system}.default ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/zen-beta \
          --set MOZ_ENABLE_WAYLAND 1 \
          --set GDK_BACKEND wayland \
          --set MOZ_DISABLE_RDD_SANDBOX 1
      '';
    })

    kdePackages.kirigami kdePackages.qqc2-desktop-style
    kdePackages.layer-shell-qt kdePackages.qtwayland kdePackages.qtsvg
    qt6.qtbase libsForQt5.qt5ct qt6Packages.qt6ct
    libX11 libxcb xcb-util-cursor
    adwaita-icon-theme hicolor-icon-theme kdePackages.breeze-icons
    bibata-cursors capitaine-cursors
    adw-gtk3 gruvbox-dark-gtk tokyonight-gtk-theme nordic graphite-gtk-theme
    papirus-icon-theme gruvbox-plus-icons tela-icon-theme material-black-colors
    gtk3 gobject-introspection python3 nwg-look
  ];

  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=adw-gtk3-dark
    gtk-icon-theme-name=Papirus-Dark
    gtk-cursor-theme-name=Bibata-Modern-Ice
    gtk-cursor-theme-size=24
    gtk-font-name=Adwaita Sans 11
    gtk-application-prefer-dark-theme=1
  '';

  environment.variables.GTK_DATA_PREFIX = "/run/current-system/sw";

  environment.sessionVariables = {
    QT_QPA_PLATFORM              = "wayland;xcb";
    QT_QPA_PLATFORMTHEME         = "kde";
    NIXPKGS_QT6_QML_IMPORT_PATH = "/run/current-system/sw/lib/qt-6/qml";
    XDG_DATA_DIRS = [
      "/run/current-system/sw/share"
      "/etc/profiles/per-user/kagan/share"
      "$HOME/.local/share"
    ];
    XCURSOR_THEME    = "Bibata-Modern-Ice";
    XCURSOR_SIZE     = "24";
    XDG_SESSION_TYPE = "wayland";
    GI_TYPELIB_PATH  = lib.makeSearchPath "lib/girepository-1.0" (with pkgs; [
      gtk3 gobject-introspection pango gdk-pixbuf glib
    ]);
  };
}
