{ pkgs, lib, ... }: {

  # ============================================================
  # AŞAMA 1 — İlk kurulum: systemd-boot aktif, lanzaboote kapalı
  # Gerçek sisteme kurulumdan sonra değiştirme — önce test et
  # ============================================================
  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint     = "/boot";
  boot.lanzaboote.enable               = false;

  # ============================================================
  # AŞAMA 2 — İlk başarılı boot'tan sonra:
  # Yukarıdaki 4 satırı kaldır, aşağıdaki bloğun # işaretlerini sil
  # ============================================================
  # boot.loader.systemd-boot.enable = lib.mkForce false;
  # boot.lanzaboote = {
  #   enable    = true;
  #   pkiBundle = "/etc/secureboot";
  # };

  # Gaming odaklı zen kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "quiet"
    "loglevel=3"
  ];

  boot.initrd.availableKernelModules = [
    "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"
  ];

  boot.initrd.kernelModules = [ "btrfs" ];

  boot.kernelModules = [
    "kvm-amd"
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  boot.initrd.supportedFilesystems = [ "btrfs" ];
  boot.supportedFilesystems        = [ "btrfs" "ntfs" ];

  # zram swap — 16GB RAM için 4GB sanal swap
  zramSwap = {
    enable        = true;
    memoryPercent = 25;
  };
}
