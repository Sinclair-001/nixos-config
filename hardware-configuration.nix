{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules          = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelModules                 = [ "kvm-amd" ];

  # ─── AMD CPU ──────────────────────────────────────────────────────────────
  boot.kernelParams = [ "amd_pstate=active" ];

  boot.kernel.sysctl = {
    "kernel.numa_balancing" = 0;  # Ryzen chiplet mimarisinde stutter önler
  };

  # ─── NVMe I/O Scheduler ───────────────────────────────────────────────────
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
  '';

  # ─── Dosya Sistemleri ─────────────────────────────────────────────────────
  fileSystems."/" = {
    device  = "/dev/disk/by-uuid/70802e11-f16c-48c7-8f4a-d23173895d1d";
    fsType  = "btrfs";
    options = [ "subvol=@" "compress=zstd:1" "noatime" "space_cache=v2" "discard=async" ];
  };
  fileSystems."/home" = {
    device  = "/dev/disk/by-uuid/70802e11-f16c-48c7-8f4a-d23173895d1d";
    fsType  = "btrfs";
    options = [ "subvol=@home" "compress=zstd:1" "noatime" "space_cache=v2" "discard=async" ];
  };
  fileSystems."/boot" = {
    device  = "/dev/disk/by-uuid/2B43-450B";
    fsType  = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];
  nixpkgs.hostPlatform        = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
