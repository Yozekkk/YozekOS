#!/usr/bin/env python3
"""Install the YozekOS user files without changing the running desktop."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / "yozekos"
HOME = Path.home()
STATE = HOME / ".local/state/yozekos/installer"
MANIFEST = STATE / "manifest.json"


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def current(path: Path) -> dict | None:
    if path.is_symlink():
        return {"kind": "link", "target": os.readlink(path)}
    if path.is_file():
        return {"kind": "file", "sha256": digest(path.read_bytes())}
    if path.is_dir():
        return {"kind": "directory"}
    return None


def file_entry(path: Path, data: bytes) -> tuple[Path, dict, bytes]:
    return path, {"kind": "file", "sha256": digest(data)}, data


def link_entry(path: Path, target: Path) -> tuple[Path, dict, None]:
    return path, {"kind": "link", "target": str(target)}, None


def detect_mechanism() -> str:
    if shutil.which("home-manager") or (HOME / ".config/home-manager").exists():
        return "Home Manager обнаружен; системные пакеты добавьте в его конфигурацию или модуль NixOS."
    return "Обычная конфигурация NixOS; подключите nix/module.nix по docs/installation.md."


def requirements() -> None:
    required = ("niri", "quickshell", "python3", "systemctl", "fc-cache")
    desktop = ("awww", "wpctl", "playerctl", "brightnessctl", "nmcli", "bluetoothctl", "grim", "wl-copy", "satty", "swaylock", "kitty")
    missing = [p for p in required if not shutil.which(p)]
    optional = [p for p in desktop if not shutil.which(p)]
    print("Зависимости:", detect_mechanism())
    print("  обязательные отсутствуют:", ", ".join(missing) if missing else "нет")
    print("  функции ограничены без:", ", ".join(optional) if optional else "нет")
    if missing:
        print("Установите обязательные пакеты через NixOS/Home Manager перед первым запуском.")


def planned_entries() -> list[tuple[Path, dict, bytes | None]]:
    entries = []
    def add(entry):
        entries.append(entry)
    config = HOME / ".config"
    add(file_entry(config / "niri/config.kdl", (APP / "config/niri/config.kdl").read_bytes()))
    add(link_entry(config / "rice", config / "yozekos"))
    add(link_entry(config / "matugen", APP / "config/matugen"))
    for name in ("rice-desktop", "rice-settings", "rice-lockscreen", "hyprquickpaper"):
        add(link_entry(config / "quickshell" / name, APP / "quickshell" / name))
    add(link_entry(HOME / ".local/share/yozekos/sounds", APP / "sounds"))
    builtin_walls = HOME / "Pictures/YozekOS/Wallpapers/Built-in"
    add(link_entry(builtin_walls, APP / "sddm/theme/walls"))
    wallpaper_config = config / "yozekos/wallpapers.json"
    if current(wallpaper_config) is None:
        add(file_entry(wallpaper_config, (json.dumps({"folders": [str(builtin_walls)]}, indent=2) + "\n").encode()))
    for source in sorted((APP / "bin").iterdir()):
        if source.is_file() and os.access(source, os.X_OK):
            add(link_entry(HOME / ".local/bin" / source.name, source))
    add(link_entry(HOME / ".local/bin/yozekos", APP / "yozekos"))
    add(file_entry(config / "fontconfig/conf.d/50-yozekos.conf", (APP / "fontconfig.conf").read_bytes()))
    for source in sorted((APP / "config/kitty").iterdir()):
        data = source.read_text().replace("@HOME@", str(HOME)).encode()
        add(file_entry(config / "kitty" / source.name, data))
    starship = config / "starship.toml"
    if current(starship) is None:
        add(file_entry(starship, (APP / "config/starship.toml").read_bytes()))
    quickshell = shutil.which("quickshell") or "quickshell"
    for name in ("yozekos-shell", "yozekos-wallpaper"):
        template = (APP / f"{name}.service").read_text()
        template = template.replace("@QUICKSHELL@", quickshell).replace("@HOME@", str(HOME))
        add(file_entry(config / "systemd/user" / f"{name}.service", template.encode()))
    for font in sorted((ROOT / "fonts/pixel").glob("*.ttf")):
        add(file_entry(HOME / ".local/share/fonts/yozekos" / font.name, font.read_bytes()))
    for source in sorted((APP / "defaults").glob("*.json")):
        dest = config / "yozekos" / source.name
        if current(dest) is None:
            add(file_entry(dest, source.read_bytes()))
    return entries


def load_manifest() -> dict:
    if MANIFEST.exists():
        return json.loads(MANIFEST.read_text())
    return {"version": 1, "entries": {}}


def remove_path(path: Path) -> None:
    if path.is_dir() and not path.is_symlink():
        shutil.rmtree(path)
    elif path.exists() or path.is_symlink():
        path.unlink()


def install(dry_run: bool, yes: bool) -> None:
    requirements()
    if "ID=nixos" not in Path("/etc/os-release").read_text().splitlines():
        raise SystemExit("Этот установщик проверен только для NixOS.")
    entries = planned_entries()
    manifest = load_manifest()
    changes = []
    conflicts = []
    for path, wanted, data in entries:
        found = current(path)
        if found == wanted:
            continue
        key = str(path.relative_to(HOME))
        owned = manifest["entries"].get(key, {}).get("installed") == found
        changes.append((path, wanted, data, found, owned))
        if found is not None and not owned:
            conflicts.append(path)
    print(f"План: {len(changes)} изменений; {len(conflicts)} существующих пользовательских путей потребуют резервной копии.")
    for path, wanted, _, found, _ in changes:
        print(f"  {'заменить' if found else 'создать'} {path} → {wanted['kind']}")
    if dry_run or not changes:
        return
    if conflicts and not yes:
        if not sys.stdin.isatty():
            raise SystemExit("Есть конфликты. Сначала проверьте --dry-run; для согласия укажите --yes.")
        answer = input("Сохранить существующие файлы в резервную копию и продолжить? [д/Н] ").strip().lower()
        if answer not in ("д", "да", "y", "yes"):
            raise SystemExit("Установка отменена; файлы не изменены.")
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    backup_root = STATE / "backups" / stamp
    for path, wanted, data, found, owned in changes:
        key = str(path.relative_to(HOME))
        old_record = manifest["entries"].get(key)
        if found is not None:
            backup = backup_root / key
            backup.parent.mkdir(parents=True, exist_ok=True)
            if path.is_symlink():
                backup.symlink_to(os.readlink(path))
            elif path.is_dir():
                shutil.copytree(path, backup, symlinks=True)
            else:
                shutil.copy2(path, backup)
            print("  резервная копия:", backup)
        else:
            backup = None
        if old_record is None:
            old_record = {"original": found, "backup": str(backup) if backup else None}
        path.parent.mkdir(parents=True, exist_ok=True)
        remove_path(path)
        if wanted["kind"] == "link":
            path.symlink_to(wanted["target"])
        else:
            path.write_bytes(data)
        old_record["installed"] = wanted
        manifest["entries"][key] = old_record
        STATE.mkdir(parents=True, exist_ok=True)
        MANIFEST.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
    if shutil.which("niri"):
        subprocess.run(["niri", "validate", "-c", str(HOME / ".config/niri/config.kdl")], check=True)
    for command in (["fc-cache", "-f", str(HOME / ".local/share/fonts/yozekos")], ["systemctl", "--user", "daemon-reload"]):
        if shutil.which(command[0]):
            subprocess.run(command, check=True)
    print("Готово. В сессии Niri запустите: systemctl --user start yozekos-shell.service")
    print("Для обновления оболочки: yozekos restart. Текущая сессия не перезапускалась.")


def uninstall(dry_run: bool) -> None:
    manifest = load_manifest()
    if not manifest["entries"]:
        print("Установка YozekOS этим установщиком не найдена.")
        return
    for key, entry in list(manifest["entries"].items()):
        path = HOME / key
        if current(path) != entry["installed"]:
            print("Пропущен изменённый пользователем путь:", path)
            continue
        print("  удалить свой файл и восстановить прежний:", path)
        if dry_run:
            continue
        remove_path(path)
        backup = Path(entry["backup"]) if entry["backup"] else None
        if backup and (backup.exists() or backup.is_symlink()):
            path.parent.mkdir(parents=True, exist_ok=True)
            if backup.is_symlink():
                path.symlink_to(os.readlink(backup))
            elif backup.is_dir():
                shutil.copytree(backup, path, symlinks=True)
            else:
                shutil.copy2(backup, path)
        del manifest["entries"][key]
        MANIFEST.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
    if not dry_run and shutil.which("systemctl"):
        subprocess.run(["systemctl", "--user", "daemon-reload"], check=False)
    print("Рабочие файлы с изменённым содержимым не удаляются.")


def main() -> None:
    parser = argparse.ArgumentParser(description="Безопасная установка пользовательской части YozekOS")
    parser.add_argument("--dry-run", action="store_true", help="показать изменения без записи")
    parser.add_argument("--yes", action="store_true", help="согласиться на резервное копирование и замену конфликтов")
    parser.add_argument("--uninstall", action="store_true", help="удалить только файлы, установленные этой программой")
    args = parser.parse_args()
    if args.uninstall:
        uninstall(args.dry_run)
    else:
        install(args.dry_run, args.yes)


if __name__ == "__main__":
    main()
