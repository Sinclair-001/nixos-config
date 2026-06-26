{ ... }:
{
  # ─── TCP BBR Congestion Control ───────────────────────────────────────────
  # Windows'ta varsayılan olan modern algoritma, Linux'ta manuel açılması lazım
  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl = {
    "net.core.default_qdisc"              = "fq";
    "net.ipv4.tcp_congestion_control"     = "bbr";

    # ─── Socket Buffer Boyutları (128 MB) ─────────────────────────────────
    # Yüksek bant genişliğinde darboğazı kaldırır
    "net.core.rmem_max"                   = 134217728;
    "net.core.wmem_max"                   = 134217728;
    "net.core.rmem_default"               = 262144;
    "net.core.wmem_default"               = 262144;
    "net.ipv4.tcp_rmem"                   = "4096 87380 134217728";
    "net.ipv4.tcp_wmem"                   = "4096 65536 134217728";

    # ─── TCP Optimizasyonları ──────────────────────────────────────────────
    "net.ipv4.tcp_fastopen"               = 3;   # SYN + SYN-ACK hızlandırma
    "net.ipv4.tcp_slow_start_after_idle"  = 0;   # Bağlantı soğumasını engelle
    "net.ipv4.tcp_mtu_probing"            = 1;   # MTU otomatik keşif
    "net.core.netdev_max_backlog"         = 16384;

    # ─── UDP / QUIC (oyun istemcileri için) ───────────────────────────────
    "net.core.netdev_budget"              = 600;
    "net.ipv4.udp_rmem_min"              = 8192;
    "net.ipv4.udp_wmem_min"              = 8192;
  };

  # ─── DNS ──────────────────────────────────────────────────────────────────
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  # ─── Firewall ─────────────────────────────────────────────────────────────
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };

  # ─── Zapret ───────────────────────────────────────────────────────────────
  services.zapret = {
    enable = true;
    configureFirewall = true;
    httpSupport  = true;
    udpSupport   = true;
    udpPorts     = [ "443" ];
    params = [
      "--dpi-desync=fake,multisplit"
      "--dpi-desync-fooling=badseq"
      "--dpi-desync-split-pos=1,midsld"
      "--dpi-desync-ttl=4"
      "--dpi-desync-repeats=5"
    ];
  };
}
