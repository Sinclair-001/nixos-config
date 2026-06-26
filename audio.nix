{ pkgs, ... }:

{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    wireplumber.extraConfig = {
      "10-low-latency" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "node.name" = "~alsa_input.*"; }
              { "node.name" = "~alsa_output.*"; }
            ];
            actions.update-props = {
              "audio.rate" = 48000;
              "api.alsa.period-size" = 128;
              "api.alsa.headroom" = 256;
            };
          }
        ];
      };
    };
  };

  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    easyeffects
    pavucontrol
    helvum
  ];
}
