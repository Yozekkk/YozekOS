{ pkgs }:
let py = pkgs.python3.withPackages (ps: [ ps.pillow ]);
in pkgs.runCommand "yozekos-angelos-pixel-cursors" {
  nativeBuildInputs = [ py ];
  YOZEKOS_PIXEL_SOURCE = ../yozekos/pixel-cursors.tar.gz;
} ''
  export HOME="$TMPDIR/home"
  mkdir -p "$HOME"
  python3 ${../yozekos/cursors.py} install angelos
  python3 ${../yozekos/cursors.py} install glitter
  python3 ${../yozekos/cursors.py} install pixel-amethyst
  python3 ${../yozekos/cursors.py} install pixel-golden
  mkdir -p "$out/share/icons"
  cp -r "$HOME/.local/share/icons/." "$out/share/icons/"
  for theme in "$out"/share/icons/*; do
    cp ${../yozekos/LICENSE.PIXEL-CURSORS} "$theme/LICENSE.GPL-3.0"
  done
''
