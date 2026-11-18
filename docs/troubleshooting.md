# Диагностика

## Панель не появилась

Проверьте сеанс и сервис:

```bash
printf '%s\n' "$XDG_CURRENT_DESKTOP"
systemctl --user status yozekos-shell.service --no-pager
journalctl --user -u yozekos-shell.service -b --no-pager -n 80
yozekos doctor
```

Нужен сеанс Niri и установленный Quickshell. Сервис имеет условие `XDG_CURRENT_DESKTOP=niri`; в Plasma он не запускается. Убедитесь, что `~/.config/quickshell/rice-desktop` указывает на существующий checkout.

## Ошибка Niri

```bash
niri validate -c ~/.config/niri/config.kdl
niri msg outputs
```

Если изменялись правила мониторов или клавиши, исправьте KDL по сообщению валидатора. Резервная копия конфигурации после установки находится в `~/.local/state/yozekos/installer/backups/`.

## Ошибка QML или отсутствующий модуль

Смотрите журнал сервиса. Проверьте `quickshell --version` и наличие файлов `yozekos/quickshell/rice-desktop/shell.qml` и `yozekos/quickshell/shared/`. Для запуска в отдельной диагностической команде используйте `quickshell -n -p ~/.config/quickshell/rice-desktop`; не запускайте вторую копию одновременно с рабочим сервисом.

## Нет обоев, сети или Bluetooth

Проверьте `systemctl --user status yozekos-wallpaper.service`, наличие `awww`, `nmcli` и `bluetoothctl`. Для сети нужен работающий NetworkManager, для Bluetooth — BlueZ; это системные службы NixOS. Установщик не включает их без вашего решения. При отсутствии коллекций обоев остаются встроенные изображения.

## Скриншот не сохраняется

Проверьте `command -v grim wl-copy satty` и `yozekos-capture-settings show`. Для выбора области используйте Print или Super+Shift+S. Если редактор Satty отсутствует, сохранение и предпросмотр могут работать, но кнопка редактирования не откроет его.

## Установка остановилась на конфликте

Сначала `./install.sh --dry-run`. Существующие файлы заменяются только после подтверждения; копии сохраняются в каталоге состояния установщика. `./install.sh --uninstall --dry-run` показывает, что может быть восстановлено. Если файл был изменён после установки, автоматическое удаление его пропустит.
