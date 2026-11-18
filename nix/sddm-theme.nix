{ pkgs }:
pkgs.runCommand "yozekos-sddm-theme" { } ''
  mkdir -p "$out/share/sddm/themes/yozekos"
  cp -r ${../yozekos/sddm/theme}/. "$out/share/sddm/themes/yozekos/"
''
