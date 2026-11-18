{ config, lib, pkgs, ... }:
let
  cfg = config.programs.yozekos;
  pixelFonts = pkgs.runCommand "yozekos-pixel-fonts" { } ''
    mkdir -p "$out/share/fonts/truetype"
    cp ${../fonts/pixel}/*.ttf "$out/share/fonts/truetype/"
  '';
  captureRegion = import ./capture.nix { inherit pkgs; };
  sddmTheme = import ./sddm-theme.nix { inherit pkgs; };
  pixelCursors = import ./cursors.nix { inherit pkgs; };
  maybe = path: let p = lib.attrByPath (lib.splitString "." path) null pkgs;
                in lib.optional (p != null) p;
in {
  options.programs.yozekos = {
    enable = lib.mkEnableOption "YozekOS Niri shell support";
    fonts.enable = lib.mkOption {
      type = lib.types.bool; default = true;
      description = "Install AngelOS pixel fonts and use them for generic sans and mono families.";
    };
    liveWallpapers.enable = lib.mkOption {
      type = lib.types.bool; default = true;
      description = "Install one video wallpaper engine for optional live wallpaper playback.";
    };
    sddm.enable = lib.mkOption {
      type = lib.types.bool; default = false;
      description = "Install the YozekOS adaptation of the AngelOS pixel SDDM theme.";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.niri.enable = lib.mkDefault true;
    environment.systemPackages = [ pixelFonts pixelCursors captureRegion pkgs.satty ]
      ++ lib.optional cfg.sddm.enable sddmTheme
      ++ maybe "quickshell" ++ maybe "kitty" ++ maybe "kdePackages.dolphin"
      ++ maybe "playerctl" ++ maybe "brightnessctl" ++ maybe "pamixer"
      ++ maybe "jq" ++ maybe "python3" ++ maybe "grim" ++ maybe "slurp"
      ++ maybe "wl-clipboard" ++ maybe "swaylock" ++ maybe "swaybg"
      ++ maybe "awww" ++ maybe "cliphist" ++ maybe "imagemagick"
      ++ maybe "ffmpeg" ++ maybe "wf-recorder" ++ maybe "upower" ++ maybe "pavucontrol"
      ++ maybe "networkmanager" ++ maybe "bluez" ++ maybe "wireplumber"
      ++ maybe "swayidle" ++ maybe "polkit_gnome" ++ maybe "fuzzel"
      ++ maybe "starship" ++ maybe "zoxide" ++ maybe "yazi"
      ++ maybe "matugen" ++ maybe "kdePackages.qtmultimedia"
      ++ lib.optionals cfg.liveWallpapers.enable (maybe "mpvpaper");
    fonts.packages = lib.optionals cfg.fonts.enable ([ pixelFonts ] ++ maybe "nerd-fonts.symbols-only");
    fonts.fontconfig.defaultFonts = lib.mkIf cfg.fonts.enable {
      sansSerif = [ "CozetteVector" "Noto Sans" "Noto Color Emoji" ];
      monospace = [ "Pixeloid Mono" "Noto Sans Mono" "Noto Color Emoji" ];
      serif = [ "Pixeloid Sans" "Noto Serif" "Noto Color Emoji" ];
    };
    fonts.fontconfig.localConf = lib.mkIf cfg.fonts.enable (builtins.readFile ../yozekos/fontconfig.conf);
    # Plasma 6 defines Breeze at normal priority. Enabling this option explicitly
    # chooses the YozekOS greeter while leaving Plasma as an available session.
    services.displayManager.sddm.theme = lib.mkIf (cfg.sddm.enable && config.services.displayManager.sddm.enable) (lib.mkForce "yozekos");
    services.displayManager.sddm.settings.Theme = lib.mkIf (cfg.sddm.enable && config.services.displayManager.sddm.enable) {
      CursorTheme = "angelOS-Pixel";
      CursorSize = 24;
    };
    environment.sessionVariables = { XCURSOR_THEME = "angelOS-Pixel"; XCURSOR_SIZE = "24"; };
    environment.etc."xdg/kdeglobals" = lib.mkIf cfg.fonts.enable {
      text = ''
        [General]
        font=CozetteVector,10,-1,5,50,0,0,0,0,0
        fixed=Pixeloid Mono,10,-1,5,50,0,0,0,0,0
        menuFont=CozetteVector,10,-1,5,50,0,0,0,0,0
        toolBarFont=CozetteVector,10,-1,5,50,0,0,0,0,0
        smallestReadableFont=CozetteVector,9,-1,5,50,0,0,0,0,0
      '';
    };
  };
}
