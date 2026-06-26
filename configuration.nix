{ pkgs, lib, inputs, ... }:
{
  networking.hostName = "nixos";
  time.timeZone       = "Europe/Istanbul";
  i18n.defaultLocale  = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "tr_TR.UTF-8";
    LC_IDENTIFICATION = "tr_TR.UTF-8";
    LC_MEASUREMENT    = "tr_TR.UTF-8";
    LC_MONETARY       = "tr_TR.UTF-8";
    LC_NAME           = "tr_TR.UTF-8";
    LC_NUMERIC        = "tr_TR.UTF-8";
    LC_PAPER          = "tr_TR.UTF-8";
    LC_TELEPHONE      = "tr_TR.UTF-8";
    LC_TIME           = "tr_TR.UTF-8";
  };

  # ─── Noctalia ─────────────────────────────────────────────────────────────
  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  services.xserver.xkb          = { layout = "us"; variant = ""; };
  console.keyMap                 = "us";
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.timeout            = 20;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "quiet"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
  ];
  boot.consoleLogLevel = 3;

  system.activationScripts.bootConfig = {
    deps = [ "specialfs" ];
    text =
      let
        sed      = "${pkgs.gnused}/bin/sed";
        find     = "${pkgs.findutils}/bin/find";
        basename = "${pkgs.coreutils}/bin/basename";
      in
      ''
        LOADER_CONF="/boot/loader/loader.conf"
        if [ -f "/boot/EFI/Microsoft/Boot/bootmgfw.efi" ]; then
          WIN_EFI="/boot/EFI/Microsoft/Boot/bootmgfw.efi"
          WIN_ENTRY_PATH="/EFI/Microsoft/Boot/bootmgfw.efi"
        elif [ -f "/boot/EFI/Win/bootmgfw.efi" ]; then
          WIN_EFI="/boot/EFI/Win/bootmgfw.efi"
          WIN_ENTRY_PATH="/EFI/Win/bootmgfw.efi"
        else
          WIN_EFI=""
        fi
        ENTRIES_DIR="/boot/loader/entries"
        ${find} "$ENTRIES_DIR" -name 'windows*' -delete 2>/dev/null || true
        ${find} "$ENTRIES_DIR" -name 'auto-windows*' -delete 2>/dev/null || true
        ${find} "$ENTRIES_DIR" -name 'Windows*' -delete 2>/dev/null || true
        if [ -n "$WIN_EFI" ] && [ -f "$WIN_EFI" ]; then
          mkdir -p "$ENTRIES_DIR"
          printf 'title Windows 11\nefi %s\n' "$WIN_ENTRY_PATH" > "$ENTRIES_DIR/windows.conf"
        fi
        HIGHEST_GEN=0
        NEWEST_ENTRY=""
        for entry in "$ENTRIES_DIR"/nixos-generation-*.conf; do
          [ -f "$entry" ] || continue
          base=$(${basename} "$entry" .conf)
          gen=$(echo "$base" | ${sed} 's/nixos-generation-\([0-9]*\).*/\1/')
          [ -n "$gen" ] || continue
          if [ "$gen" -gt "$HIGHEST_GEN" ] 2>/dev/null; then
            HIGHEST_GEN="$gen"
            NEWEST_ENTRY="$base"
          fi
        done
        if [ -f "$LOADER_CONF" ]; then
          ${sed} -i '/^auto-entries/d' "$LOADER_CONF"
          ${sed} -i '/^default /d' "$LOADER_CONF"
          ${sed} -i '/^timeout /d' "$LOADER_CONF"
          echo "auto-entries 0" >> "$LOADER_CONF"
          echo "timeout 15" >> "$LOADER_CONF"
          if [ -n "$NEWEST_ENTRY" ]; then
            echo "default $NEWEST_ENTRY" >> "$LOADER_CONF"
          fi
        fi
      '';
  };
}
