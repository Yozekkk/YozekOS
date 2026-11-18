# Архитектура YozekOS

## Путь запуска

```text
сеанс Niri → ~/.config/niri/config.kdl
            → systemctl --user start yozekos-shell.service
            → quickshell -n -p ~/.config/quickshell/rice-desktop
            → shell.qml → панель, виджеты, уведомления, меню
            → yozekos-wallpaper.service → rice-walls → awww
```

`yozekos/config/niri/config.kdl` — переносимый снимок работающей конфигурации Niri. Установщик копирует его в пользовательский каталог, сохраняя прежний файл. Автозапуск привязан к Niri. Сервис Quickshell использует шаблон с путями, подставляемыми при установке, поэтому имя домашнего каталога и путь к Quickshell не зашиты в Git.

## Компоненты

| Каталог | Роль |
| --- | --- |
| `yozekos/quickshell/rice-desktop` | Главная оболочка: `shell.qml`, `Bar.qml`, `Dock.qml`, `Launcher.qml`, `DynIsland.qml`, `NotifServer.qml`, `ControlCenter.qml`, `ShotPreview.qml`, системные виджеты. |
| `yozekos/quickshell/rice-settings` | Окно настроек; запись параметров через скрипты `yozekos/bin`. |
| `yozekos/quickshell/rice-lockscreen`, `hyprquickpaper` | Дополнительные QML-экраны и выбор обоев. |
| `yozekos/quickshell/shared` | Общие QML-компоненты, в том числе шрифты. |
| `yozekos/bin` | Команды `yozekos`, `rice-*`, `record`, `screenshot`, оболочки для звука, сети и темы. |
| `yozekos/capture` | GTK layer-shell выбор области, форматы и предпросмотр; Satty выполняет редактирование. |
| `yozekos/config/matugen` | Палитры и генерация цветов. |
| `yozekos/defaults` | Начальные значения JSON; пользовательские значения лежат вне репозитория. |
| `yozekos/sddm`, `fonts`, `yozekos/sounds` | Необязательный экран входа, лицензированные шрифты и звуки. |
| `nix/module.nix` | Декларативные системные зависимости NixOS. |

Quickshell получает данные о рабочих пространствах и окнах через Niri, о медиа — через playerctl/PipeWire, о сети — через NetworkManager, о Bluetooth — через BlueZ. QML использует команды из `~/.local/bin`, установленные ссылками на репозиторий. Унаследованный путь `~/.config/rice` сохранён как ссылка на `~/.config/yozekos` для совместимости с исходными скриптами DarkShadowShell. Массовое переименование импортов изменило бы поведение, поэтому оно не выполнялось.

## Данные и границы

Исходный код и начальные настройки находятся в Git. Личные параметры, журналы, кэши, выбранные обои и большие сторонние коллекции остаются в домашнем каталоге. `scripts/install-user.py` ведёт манифест установленных путей и копии конфликтующих файлов; его режим удаления сравнивает текущее содержимое с тем, что он установил.
