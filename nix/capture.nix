{ pkgs }:
let
  py = pkgs.python3.withPackages (ps: [ ps.pygobject3 ps.pycairo ]);
in pkgs.writeShellApplication {
  name = "yozekos-capture-region";
  runtimeInputs = [ py pkgs.grim pkgs.wl-clipboard pkgs.libnotify pkgs.imagemagick pkgs.pipewire ];
  text = ''
    export GI_TYPELIB_PATH="${pkgs.gobject-introspection}/lib/girepository-1.0:${pkgs.glib.out}/lib/girepository-1.0:${pkgs.gdk-pixbuf.out}/lib/girepository-1.0:${pkgs.pango.out}/lib/girepository-1.0:${pkgs.harfbuzz.out}/lib/girepository-1.0:${pkgs.atk.out}/lib/girepository-1.0:${pkgs.gtk3}/lib/girepository-1.0:${pkgs.gtk-layer-shell}/lib/girepository-1.0''${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}"
    export LD_LIBRARY_PATH="${pkgs.gtk-layer-shell}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    exec ${py}/bin/python3 ${../yozekos/capture}/niri-screenshot-region.py "$@"
  '';
}
