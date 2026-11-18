#!/usr/bin/env python3
"""Install the original AngelOS wallpaper packs once with a partial sparse checkout.

The collection remains a single shallow Git checkout, so a later --update downloads
only changed objects. User pictures in Custom and Live are never modified.
"""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess

REPO = "https://github.com/MixaDoDs/PixelStreetArt_Wallpapers.git"
PACKS = ["Hell", "wallpapers", "Lain", "Pixel", "pixel-art-green-wallpapers"]
ESTIMATED_MB = 875  # AngelOS installer: 410 + 187 + 275 + 1 MB; two extra pictures.
ROOT = Path.home() / "Pictures/YozekOS/Wallpapers"
DEST = ROOT / "AngelOS"
CONFIG = Path.home() / ".config/yozekos/wallpaper-collections.json"
STATE = ROOT / ".angelos-collections-state.json"
DEFAULT_MARKER = ROOT / ".initial-wallpaper-selected"
BUILTIN = Path(__file__).resolve().parents[1] / "yozekos/sddm/theme/walls"


def run(*args, cwd=None, timeout=600):
    command = list(args)
    if command and command[0] == "git":
        command[1:1] = ["-c", "http.version=HTTP/1.1", "-c", "http.lowSpeedLimit=1024", "-c", "http.lowSpeedTime=90"]
    return subprocess.run(command, cwd=cwd, check=True, timeout=timeout,
                          env=dict(os.environ, GIT_TERMINAL_PROMPT="0"))


def configuration():
    try:
        data = json.loads(CONFIG.read_text())
        if isinstance(data, dict):
            return data
    except (OSError, ValueError):
        pass
    return {"auto_download": True, "packs": PACKS}


def save_configuration(data):
    CONFIG.parent.mkdir(parents=True, exist_ok=True)
    temp = CONFIG.with_suffix(".tmp")
    temp.write_text(json.dumps(data, indent=2) + "\n")
    os.replace(temp, CONFIG)


def selected(raw):
    if raw in ("none", "off", "0"):
        return []
    if raw in ("all", "on", "1", ""):
        return PACKS
    chosen = [s.strip() for s in raw.split(",") if s.strip()]
    bad = set(chosen) - set(PACKS)
    if bad:
        raise ValueError("Unknown collection: " + ", ".join(sorted(bad)))
    return list(dict.fromkeys(chosen))


def register():
    ROOT.mkdir(parents=True, exist_ok=True)
    for name in ("Custom", "Live"):
        (ROOT / name).mkdir(exist_ok=True)
    builtin = ROOT / "Built-in"
    if not builtin.exists() and not builtin.is_symlink():
        builtin.symlink_to(BUILTIN, target_is_directory=True)
    manager = shutil.which("rice-walls") or str(Path.home() / ".local/bin/rice-walls")
    if Path(manager).exists():
        for folder in (ROOT, DEST):
            if folder.is_dir():
                subprocess.run([manager, "folder", "add", str(folder)], check=False,
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def select_initial_wallpaper():
    """Use an original Pixel image once, while keeping any user's choice."""
    if DEFAULT_MARKER.exists():
        return
    manager = shutil.which("rice-walls") or str(Path.home() / ".local/bin/rice-walls")
    if not Path(manager).exists():
        return
    current = ""
    try:
        state = subprocess.check_output([manager, "list"], text=True, timeout=30)
        current = json.loads(state).get("current", "")
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, ValueError, OSError):
        return
    if current and "/Built-in/" not in current:
        DEFAULT_MARKER.write_text("Existing wallpaper choice preserved\n")
        return
    pixel = DEST / "Pixel"
    chosen = pixel / "wallhaven-d8gwvj.png"
    if not chosen.is_file():
        chosen = next((p for p in sorted(pixel.glob("*")) if p.suffix.lower() in (".png", ".jpg", ".jpeg", ".webp")), None)
    if chosen is None:
        return
    if subprocess.run([manager, "set", str(chosen)], check=False, timeout=120).returncode == 0:
        DEFAULT_MARKER.write_text(str(chosen) + "\n")


def installed():
    if not (DEST / ".git").is_dir():
        return None
    try:
        revision = subprocess.check_output(["git", "-C", str(DEST), "rev-parse", "HEAD"], text=True).strip()
    except subprocess.CalledProcessError:
        return None
    return revision


def completed_packs():
    try:
        data = json.loads(STATE.read_text())
        if data.get("revision") == installed():
            return [p for p in data.get("packs", []) if p in PACKS and (DEST / p).is_dir()]
    except (OSError, ValueError, AttributeError):
        pass
    return []


def record_completed(packs):
    STATE.parent.mkdir(parents=True, exist_ok=True)
    temp = STATE.with_suffix(".tmp")
    temp.write_text(json.dumps({"revision": installed(), "packs": packs}, indent=2) + "\n")
    os.replace(temp, STATE)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", nargs="?", choices=("install", "update", "status", "configure"), default="install")
    parser.add_argument("--packs", default=None, help="all, none, or comma-separated real collection names")
    args = parser.parse_args()
    conf = configuration()
    if args.action == "configure":
        if args.packs is None:
            parser.error("configure requires --packs")
        conf["packs"] = selected(args.packs)
        conf["auto_download"] = bool(conf["packs"])
        save_configuration(conf)
        print(json.dumps(conf))
        return
    packs = selected(args.packs) if args.packs is not None else [p for p in conf.get("packs", PACKS) if p in PACKS]
    if args.action == "status":
        register()
        print(json.dumps({"revision": installed(), "installed_packs": completed_packs(), "packs": packs, "estimated_mb": ESTIMATED_MB,
                          "root": str(ROOT), "auto_download": conf.get("auto_download", True)}))
        return
    register()
    if args.packs is None and not conf.get("auto_download", True):
        print("YozekOS: automatic wallpaper download disabled")
        return
    if not packs:
        print("YozekOS: no wallpaper packs selected; built-in pictures remain available")
        return
    print(f"YozekOS: {len(packs)} original wallpaper collections; about {ESTIMATED_MB} MB for all packs", flush=True)
    if DEST.exists() and installed() is None:
        raise SystemExit(f"{DEST} already exists and is not our Git collection; refusing to replace it")
    if installed() is None:
        ROOT.mkdir(parents=True, exist_ok=True)
        run("git", "clone", "--depth", "1", "--filter=blob:none", "--sparse", REPO, str(DEST))
    else:
        if args.action == "update":
            dirty = subprocess.check_output(["git", "-C", str(DEST), "status", "--porcelain"], text=True)
            if dirty.strip():
                raise SystemExit("Collection contains local changes; refusing to update user files")
            before = installed()
            run("git", "pull", "--ff-only", cwd=DEST, timeout=2400)
            if installed() != before:
                record_completed([])
    actual = subprocess.check_output(["git", "-C", str(DEST), "ls-tree", "--name-only", "HEAD"], text=True).splitlines()
    missing = set(packs) - set(actual)
    if missing:
        raise ValueError("Collection folders absent upstream: " + ", ".join(sorted(missing)))
    done = completed_packs()
    for pack in packs:
        if pack in done:
            continue
        print(f"YozekOS: downloading {pack}; completed {len(done)}/{len(packs)}", flush=True)
        # One pack per request bounds the amount lost on an interrupted transfer.
        # The checkout stays in place, so a later install resumes without cloning.
        for attempt in range(3):
            try:
                run("git", "sparse-checkout", "add", pack, cwd=DEST, timeout=2400)
                break
            except (subprocess.CalledProcessError, subprocess.TimeoutExpired):
                if attempt == 2:
                    raise
                print(f"YozekOS: retrying {pack} ({attempt + 1}/2)", flush=True)
        if not (DEST / pack).is_dir():
            raise SystemExit(f"Collection {pack} is missing after checkout")
        done.append(pack)
        record_completed(done)
    register()
    count = len([p for p in packs if p in completed_packs()])
    if count != len(packs):
        raise SystemExit(f"Only {count}/{len(packs)} collections checked out")
    select_initial_wallpaper()
    print(json.dumps({"installed": count, "revision": installed(), "root": str(DEST)}))


if __name__ == "__main__":
    main()
