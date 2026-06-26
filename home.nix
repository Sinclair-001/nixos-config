# /etc/nixos/modules/home.nix (heroic kısmı gaming.nix'e taşındı)
{ config, pkgs, inputs, ... }:

let
  nixcli = pkgs.writeShellScriptBin "nixcli" ''
    #!/usr/bin/env bash
    set -euo pipefail
    FLAKE_DIR="/etc/nixos"
    HOST="nixos"
    VERSION="1.0.0"
    print_help() {
      echo "nixcli — NixOS Yönetim Aracı v''${VERSION}"
      echo ""
      echo "Kullanım: nixcli [komut]"
      echo ""
      echo "Sistem Komutları:"
      echo "  rebuild        — Sistemi yeniden derle ve hemen uygula"
      echo "  rebuild-boot   — Yeniden derle; değişiklikler bir sonraki açılışta etkin"
      echo "  update         — Tüm flake girdilerini güncelle ve yeniden derle"
      echo ""
      echo "Bakım Komutları:"
      echo "  cleanup        — Eski nesilleri ve Nix store çöpünü temizle"
      echo "  list-gens      — Sistem nesillerini listele"
      echo "  trim           — SSD TRIM işlemini çalıştır (fstrim)"
      echo ""
      echo "  help           — Bu yardım mesajını göster"
      echo ""
      echo "Flake Dizini : ''${FLAKE_DIR}"
      echo "Hedef Host   : ''${HOST}"
    }
    if [ "$#" -eq 0 ]; then
      print_help
      exit 0
    fi
    case "$1" in
      rebuild)
        echo "→ Rebuild başlatılıyor: ''${FLAKE_DIR}#''${HOST}"
        sudo nixos-rebuild switch --flake "''${FLAKE_DIR}#''${HOST}"
        echo "✓ Rebuild tamamlandı."
        ;;
      rebuild-boot)
        echo "→ Boot rebuild başlatılıyor: ''${FLAKE_DIR}#''${HOST}"
        sudo nixos-rebuild boot --flake "''${FLAKE_DIR}#''${HOST}"
        echo "✓ Rebuild tamamlandı — değişiklikler bir sonraki açılışta etkinleşecek."
        ;;
      update)
        echo "→ Flake girdileri güncelleniyor..."
        sudo nix flake update "''${FLAKE_DIR}"
        echo "→ Sistem yeniden derleniyor..."
        sudo nixos-rebuild switch --flake "''${FLAKE_DIR}#''${HOST}"
        echo "✓ Güncelleme ve rebuild tamamlandı."
        ;;
      cleanup)
        echo "→ Eski nesiller ve Nix store çöpü temizleniyor..."
        sudo nix-collect-garbage -d
        nix-collect-garbage -d
        echo "✓ Temizlik tamamlandı."
        ;;
      list-gens)
        echo "--- Sistem Nesilleri ---"
        nix profile history --profile /nix/var/nix/profiles/system | head -25 || true
        ;;
      trim)
        echo "TRIM işlemi başlatılacak. Birkaç dakika sürebilir."
        read -p "Devam etmek istiyor musun? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          sudo fstrim -v /
          echo "✓ TRIM tamamlandı."
        else
          echo "İşlem iptal edildi."
        fi
        ;;
      help|--help|-h)
        print_help
        ;;
      *)
        echo "Hata: Bilinmeyen komut '$1'" >&2
        print_help
        exit 1
        ;;
    esac
  '';
in

{
  home.username      = "kagan";
  home.homeDirectory = "/home/kagan";
  home.stateVersion  = "25.11";

  home.enableNixpkgsReleaseCheck = false;

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    cliphist
    wl-clipboard
    swaybg
    nixcli
    dconf
    bat
    ripgrep
    fd
    jq
    unzip
    p7zip
    btop
    fastfetch
  ];

  wayland.windowManager.mango = {
    enable          = true;
    systemd.enable  = true;

    settings = {
      monitorrule = [
        "name:^DP-1$,width:1920,height:1080,refresh:164,x:0,y:0,scale:1,vrr:1,rr:0"
      ];
      blur                   = 1;
      blur_layer             = 0;
      blur_optimized         = 1;
      blur_params_num_passes = 2;
      blur_params_radius     = 8;
      blur_params_noise      = 0.01;
      blur_params_brightness = 0.9;
      blur_params_contrast   = 0.9;
      blur_params_saturation = 1.2;
      shadows              = 0;
      layer_shadows        = 0;
      shadow_only_floating = 1;
      shadows_size         = 10;
      shadows_blur         = 15;
      shadows_position_x   = 0;
      shadows_position_y   = 0;
      border_radius         = 6;
      no_radius_when_single = 0;
      focused_opacity       = 1.0;
      unfocused_opacity     = 1.0;
      rootcolor   = "0x201b14ff";
      bordercolor = "0x444444ff";
      focuscolor  = "0xc9b890ff";
      urgentcolor = "0xad401fff";
      animations             = 1;
      layer_animations       = 1;
      animation_type_open    = "slide";
      animation_type_close   = "slide";
      animation_fade_in      = 1;
      animation_fade_out     = 1;
      tag_animation_direction = 1;
      zoom_initial_ratio     = 0.4;
      zoom_end_ratio         = 0.8;
      fadein_begin_opacity   = 0.5;
      fadeout_begin_opacity  = 0.8;
      animation_duration_move  = 200;
      animation_duration_open  = 250;
      animation_duration_tag   = 350;
      animation_duration_close = 300;
      animation_duration_focus = 0;
      animation_curve_open          = "0.46,1.0,0.29,1";
      animation_curve_move          = "0.46,1.0,0.29,1";
      animation_curve_tag           = "0.46,1.0,0.29,1";
      animation_curve_close         = "0.08,0.92,0,1";
      animation_curve_focus         = "0.46,1.0,0.29,1";
      animation_curve_opafadeout    = "0.5,0.5,0.5,0.5";
      animation_curve_opafadein     = "0.46,1.0,0.29,1";
      scroller_structs                  = 20;
      scroller_default_proportion       = 0.8;
      scroller_focus_center             = 0;
      scroller_prefer_center            = 0;
      edge_scroller_pointer_focus       = 1;
      scroller_default_proportion_single = 1.0;
      scroller_proportion_preset        = "0.5,0.8,1.0";
      new_is_master    = 1;
      default_mfact    = 0.55;
      default_nmaster  = 1;
      smartgaps        = 0;
      hotarea_size   = 10;
      enable_hotarea = 1;
      ov_tab_mode    = 0;
      overviewgappi  = 5;
      overviewgappo  = 30;
      axis_bind_apply_timeout    = 100;
      focus_on_activate          = 1;
      idleinhibit_ignore_visible = 0;
      sloppyfocus                = 1;
      warpcursor                 = 1;
      focus_cross_monitor        = 0;
      focus_cross_tag            = 0;
      enable_floating_snap       = 0;
      snap_distance              = 30;
      cursor_size                = 24;
      drag_tile_to_tile          = 1;
      repeat_rate    = 75;
      repeat_delay   = 750;
      numlockon      = 0;
      xkb_rules_layout = "us";
      disable_trackpad           = 0;
      tap_to_click               = 1;
      tap_and_drag               = 1;
      drag_lock                  = 1;
      trackpad_natural_scrolling = 0;
      disable_while_typing       = 1;
      left_handed                = 0;
      middle_button_emulation    = 0;
      swipe_min_threshold        = 1;
      mouse_natural_scrolling    = 0;
      gappih             = 3;
      gappiv             = 3;
      gappoh             = 6;
      gappov             = 6;
      scratchpad_width_ratio  = 0.8;
      scratchpad_height_ratio = 0.9;
      borderpx           = 2;
      tagrule = [
        "id:1,layout_name:scroller"
        "id:2,layout_name:vertical_scroller"
        "id:3,layout_name:tile"
        "id:4,layout_name:tile"
        "id:5,layout_name:tile"
        "id:6,layout_name:tile"
        "id:7,layout_name:tile"
        "id:8,layout_name:tile"
        "id:9,layout_name:tile"
      ];
    };

    extraConfig = ''
      bind=SUPER,r,reload_config
      bind=Alt,space,spawn,rofi -show drun
      bind=Alt,Return,spawn,kitty
      bind=SUPER,m,quit
      bind=ALT,q,killclient,
      bind=SUPER,space,spawn,noctalia msg panel-toggle launcher
      bind=SUPER,v,spawn,noctalia msg panel-toggle clipboard
      bind=SUPER,s,spawn,noctalia msg panel-toggle session
      bind=SUPER,w,spawn,noctalia msg panel-toggle wallpaper
      bind=SUPER+ALT,w,spawn,noctalia msg wallpaper-random
      bind=SUPER+SHIFT,w,spawn,noctalia msg wallpaper-set color:#201b14
      bind=SUPER+CTRL,w,spawn,noctalia msg panel-toggle control-center
      bind=SUPER,Print,spawn_shell,grim - | wl-copy
      bind=SUPER+SHIFT,s,spawn_shell,grim -g "$(slurp)" - | wl-copy
      bind=SUPER+SHIFT,Print,spawn_shell,grim ~/Pictures/$(date +%Y%m%d_%H%M%S).png
      bind=ALT,b,spawn,zen-browser
      bind=SUPER,e,spawn,dolphin
      bind=SUPER,Tab,focusstack,next
      bind=ALT,Left,focusdir,left
      bind=ALT,Right,focusdir,right
      bind=ALT,Up,focusdir,up
      bind=ALT,Down,focusdir,down
      bind=SUPER+SHIFT,Up,exchange_client,up
      bind=SUPER+SHIFT,Down,exchange_client,down
      bind=SUPER+SHIFT,Left,exchange_client,left
      bind=SUPER+SHIFT,Right,exchange_client,right
      bind=SUPER,g,toggleglobal,
      bind=ALT,Tab,toggleoverview,
      bind=ALT,backslash,togglefloating,
      bind=ALT,a,togglemaximizescreen,
      bind=ALT,f,togglefullscreen,
      bind=ALT+SHIFT,f,togglefakefullscreen,
      bind=SUPER,i,minimized,
      bind=SUPER,o,toggleoverlay,
      bind=SUPER+SHIFT,I,restore_minimized
      bind=ALT,z,toggle_scratchpad
      bind=ALT,e,set_proportion,1.0
      bind=ALT,x,switch_proportion_preset,
      bind=SUPER,n,switch_layout
      bind=SUPER,Left,viewtoleft,0
      bind=CTRL,Left,viewtoleft_have_client,0
      bind=SUPER,Right,viewtoright,0
      bind=CTRL,Right,viewtoright_have_client,0
      bind=CTRL+SUPER,Left,tagtoleft,0
      bind=CTRL+SUPER,Right,tagtoright,0
      bind=Ctrl,1,view,1,0
      bind=Ctrl,2,view,2,0
      bind=Ctrl,3,view,3,0
      bind=Ctrl,4,view,4,0
      bind=Ctrl,5,view,5,0
      bind=Ctrl,6,view,6,0
      bind=Ctrl,7,view,7,0
      bind=Ctrl,8,view,8,0
      bind=Ctrl,9,view,9,0
      bind=Alt,1,tag,1,0
      bind=Alt,2,tag,2,0
      bind=Alt,3,tag,3,0
      bind=Alt,4,tag,4,0
      bind=Alt,5,tag,5,0
      bind=Alt,6,tag,6,0
      bind=Alt,7,tag,7,0
      bind=Alt,8,tag,8,0
      bind=Alt,9,tag,9,0
      bind=alt+shift,Left,focusmon,left
      bind=alt+shift,Right,focusmon,right
      bind=SUPER+Alt,Left,tagmon,left
      bind=SUPER+Alt,Right,tagmon,right
      bind=ALT+SHIFT,X,incgaps,1
      bind=ALT+SHIFT,Z,incgaps,-1
      bind=ALT+SHIFT,R,togglegaps
      bind=CTRL+SHIFT,Up,movewin,Z+0,-50
      bind=CTRL+SHIFT,Down,movewin,+0,+50
      bind=CTRL+SHIFT,Left,movewin,-50,+0
      bind=CTRL+SHIFT,Right,movewin,+50,+0
      bind=CTRL+ALT,Up,resizewin,+0,-50
      bind=CTRL+ALT,Down,resizewin,+0,+50
      bind=CTRL+ALT,Left,resizewin,-50,+0
      bind=CTRL+ALT,Right,resizewin,+50,+0
      mousebind=SUPER,btn_left,moveresize,curmove
      mousebind=SUPER,btn_middle,togglemaximizescreen,0
      mousebind=SUPER,btn_right,moveresize,curresize
      axisbind=SUPER,UP,viewtoleft_have_client
      axisbind=SUPER,DOWN,viewtoright_have_client
      layerrule=animation_type_open:zoom,layer_name:rofi
      layerrule=animation_type_close:zoom,layer_name:rofi
    '';

    autostart_sh = ''
      pkill kded6
      ${pkgs.swaybg}/bin/swaybg -c '#0d1117' &
      ${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1 &
      ${pkgs.wl-clipboard}/bin/wl-paste --type text  --watch ${pkgs.cliphist}/bin/cliphist store &
      ${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store &
      env QT_QPA_PLATFORMTHEME= noctalia &
    '';
  };

  imports = [
    #inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };
      wallpaper = {
        enabled = true;
        default.path = "/path/to/wallpapers/wallpaper.png";
      };
    };
  };

  programs.zed-editor = {
    enable = true;

    # Zed'in ihtiyaç duyduğu eklentiler otomatik kurulur
    extensions = [
      "nix"
      "toml"
      "git firefly" # Git değişikliklerini güzel gösterir
    ];

    # LSP ve format araçlarını sadece Zed ortamına enjekte ediyoruz
    extraPackages = with pkgs; [
      nixd             # Gelişmiş Nix dil sunucusu
      nixfmt-rfc-style # Resmi Nix formatlayıcı
      statix           # Hatalı/kötü Nix yazımlarını yakalar
      deadnix          # Kullanılmayan kodları bulur
    ];

    # Zed'in settings.json dosyası (Nix formatında)
    userSettings = {
      autosave = "off"; # Yanlışlıkla hatalı kaydetmeyi önler
      restore_on_startup = "last_workspace";

      # Görsellik ve Okunabilirlik
      indent_guides = { enabled = true; };
      inlay_hints = { enabled = true; };

      # Vim modunu seviyorsan "true" yapabilirsin
      vim_mode = false;

      languages = {
        Nix = {
          language_servers = [ "nixd" ];
          format_on_save = "on";
          formatter = {
            external = {
              command = "nixfmt";
            };
          };
        };
      };
    };
  };

  xdg.configFile."gtk-3.0/settings.ini" = {
    force = true;
    text = ''
      [Settings]
      gtk-theme-name=adw-gtk3-dark
      gtk-icon-theme-name=Papirus-Dark
      gtk-cursor-theme-name=Bibata-Modern-Ice
      gtk-cursor-theme-size=24
      gtk-font-name=Adwaita Sans 11
      gtk-application-prefer-dark-theme=1
    '';
  };

  xdg.configFile."gtk-4.0/settings.ini" = {
    force = true;
    text = ''
      [Settings]
      gtk-theme-name=adw-gtk3-dark
      gtk-icon-theme-name=Papirus-Dark
      gtk-cursor-theme-name=Bibata-Modern-Ice
      gtk-cursor-theme-size=24
      gtk-font-name=Adwaita Sans 11
      gtk-application-prefer-dark-theme=1
    '';
  };

  home.file.".gtkrc-2.0" = {
    force = true;
    text = ''
      gtk-theme-name="adw-gtk3-dark"
      gtk-icon-theme-name="Papirus-Dark"
      gtk-cursor-theme-name="Bibata-Modern-Ice"
      gtk-cursor-theme-size=24
      gtk-font-name="Adwaita Sans 11"
    '';
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name         = "Fusion";
  };

  xdg.configFile."qt5ct/qt5ct.conf" = {
    force = true;
    text = ''
      [Appearance]
      style=Fusion
      icon_theme=Papirus-Dark
      [Fonts]
      general="Adwaita Sans,11,-1,5,50,0,0,0,0,0"
      fixed="JetBrainsMono Nerd Font,12,-1,5,50,0,0,0,0,0"
    '';
  };

  xdg.configFile."qt6ct/qt6ct.conf" = {
    force = true;
    text = ''
      [Appearance]
      style=Fusion
      icon_theme=Papirus-Dark
      [Fonts]
      general="Adwaita Sans,11,-1,5,50,0,0,0,0,0,Regular"
      fixed="JetBrainsMono Nerd Font,12,-1,5,50,0,0,0,0,0,Regular"
    '';
  };

  xdg.mime.enable = true;
  xdg.configFile."mimeapps.list" = {
    force = true;
    text = ''
      [Default Applications]
      x-scheme-handler/http=zen-browser.desktop
      x-scheme-handler/https=zen-browser.desktop
      text/html=zen-browser.desktop
      application/pdf=okular.desktop
    '';
  };

  home.file.".themes".source =
    config.lib.file.mkOutOfStoreSymlink "/run/current-system/sw/share/themes";
  home.file.".icons".source =
    config.lib.file.mkOutOfStoreSymlink "/run/current-system/sw/share/icons";

  home.activation.setDconfTheme =
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      DCONF="${pkgs.dconf}/bin/dconf"
      $DCONF write /org/gnome/desktop/interface/icon-theme    "'Papirus-Dark'"
      $DCONF write /org/gnome/desktop/interface/gtk-theme     "'adw-gtk3-dark'"
      $DCONF write /org/gnome/desktop/interface/cursor-theme  "'Bibata-Modern-Ice'"
      $DCONF write /org/gnome/desktop/interface/cursor-size   "uint32 24"
      $DCONF write /org/gnome/desktop/interface/color-scheme  "'prefer-dark'"
      $DCONF write /org/gnome/desktop/interface/font-name     "'Adwaita Sans 11'"
    '';

  programs.fish = {
    enable = true;
    shellAliases = {
      ls  = "eza --icons=always --group-directories-first";
      ll  = "eza -lh --no-user --icons=always --group-directories-first";
      la  = "eza -lah --icons=always";
      lt  = "eza --tree --level=2 --icons=always";
      llt = "eza -lh --tree --level=2 --icons=always";
      v   = "nvim";
      sv  = "sudo nvim";
      c   = "clear";
      cat = "bat";
      rebuild = "nixcli rebuild";
      update  = "nixcli update";
      cleanup = "nixcli cleanup";

      # nh alias'ları (yeni ekleyin)
      nhs   = "nh os switch";           # sistemi yeniden derle ve hemen uygula
      nhb   = "nh os boot";             # derle, bir sonraki boot'ta uygula
      nhc   = "nh clean all";           # tüm eski nesilleri ve çöpü temizle (dikkatli kullan)
      nhc5  = "nh clean keep 5";        # son 5 nesil dışındakileri temizle
      nhs7  = "nh clean keep-days 7";   # son 7 gün içindeki nesilleri tut, eskileri sil
      nhse  = "nh search";              # paket ara (hızlı)
      nhup  = "nh os switch --update";  # önce flake güncelle, sonra rebuild
      nhlog = "nh os boot --log";       # rebuild loglarını göster
    };
    interactiveShellInit = ''
      set fish_greeting ""
      if not set -q FASTFETCH_LAUNCHED
        set -gx FASTFETCH_LAUNCHED 1
        ${pkgs.fastfetch}/bin/fastfetch
      end
    '';
  };

  programs.eza = {
    enable                = true;
    icons                 = "auto";
    enableFishIntegration = true;
    git                   = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };

  programs.kitty = {
    enable = true;
    settings = {
      font_family           = "JetBrainsMono Nerd Font";
      font_size             = 12;
      window_padding_width    = 6;
      confirm_os_window_close = 0;
      hide_window_decorations = "yes";
      scrollback_lines  = 10000;
      enable_audio_bell = false;
      mouse_hide_wait   = 3.0;
      cursor_trail          = 1;
      cursor_blink_interval = "0.5";
      tab_bar_style       = "powerline";
      tab_powerline_style = "slanted";
      tab_bar_edge        = "top";
      active_tab_font_style   = "bold";
      inactive_tab_font_style = "normal";
      enabled_layouts = "splits,stack";
    };
    extraConfig = ''
      map ctrl+shift+v  paste_from_clipboard
      map shift+insert  paste_from_selection
      map ctrl+shift+up    scroll_line_up
      map ctrl+shift+down  scroll_line_down
      map ctrl+shift+k     scroll_line_up
      map ctrl+shift+j     scroll_line_down
      map ctrl+shift+page_up   scroll_page_up
      map ctrl+shift+page_down scroll_page_down
      map ctrl+shift+home  scroll_home
      map ctrl+shift+end   scroll_end
      map ctrl+shift+enter  launch --location=hsplit
      map ctrl+shift+s      launch --location=vsplit
      map ctrl+shift+]      next_window
      map ctrl+shift+[      previous_window
      map ctrl+shift+w      close_window
      map ctrl+shift+right  next_tab
      map ctrl+shift+left   previous_tab
      map ctrl+shift+t      new_tab
      map ctrl+shift+q      close_tab
      map ctrl+shift+l      next_layout
      map ctrl+equal     increase_font_size
      map ctrl+minus     decrease_font_size
      map ctrl+backspace restore_font_size
    '';
  };

  programs.btop = {
    enable = true;
    settings = {
      vim_keys         = true;
      update_ms        = 1000;
      proc_sorting     = "cpu direct";
      proc_reversed    = true;
      theme_background = false;
    };
  };

  fonts.fontconfig.enable = true;

  xdg.configFile."MangoHud/MangoHud.conf" = {
    force = true;
    text = ''
      toggle_hud=F12
      position=top-left
      font_size=22
      background_alpha=0.4
      round_corners=5
      fps
      fps_sampling_period=500
      fps_color_change
      fps_value=60,144
      frametime
      frame_timing=1
      present_mode
      gpu_stats
      gpu_temp
      gpu_load_change
      gpu_load_value=50,90
      vram
      cpu_stats
      cpu_temp
      cpu_load_change
      cpu_load_value=50,90
      ram
      wine
    '';
  };

  xdg.configFile."gamemode.ini" = {
    force = true;
    text = ''
      [general]
      reaper_freq=5
      [cpu]
      governor=performance
      [gpu]
      apply_gpu_optimisations=accept-responsibility
      nv_powermizer_mode=1
      [io]
      iosched=none
      [custom]
      start=notify-send "🎮 GameMode başladı" --urgency=low
      end=notify-send "🎮 GameMode bitti" --urgency=low
    '';
  };
}
