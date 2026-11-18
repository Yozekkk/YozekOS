# Горячие клавиши Niri

Таблица построена по активным привязкам `yozekos/config/niri/config.kdl`. `Mod` означает клавишу Super. Дополнительные личные сочетания могут отличаться.

| Клавиши | Действие |
| --- | --- |
| `Mod+Shift+Slash` | Действие Niri: `show-hotkey-overlay` |
| `Mod+Return` | Открыть терминал: `spawn "rice-term"` |
| `Mod+T` | Открыть терминал: `spawn "kitty"` |
| `Mod+E` | Открыть файловый менеджер: `spawn "rice-files"` |
| `Mod+D` | Открыть меню приложений: `spawn "yozekos" "launcher"` |
| `Mod+Q` | Открыть терминал: `spawn "kitty"` |
| `Mod+U` | Открыть настройки YozekOS: `spawn "yozekos" "settings"` |
| `Mod+R` | Открыть меню приложений: `spawn "yozekos" "launcher"` |
| `Mod+L` | Заблокировать экран: `spawn "swaylock" "-f"` |
| `Mod+Shift+D` | Выполнить команду: `spawn "fuzzel"` |
| `Mod+Space` | Открыть меню приложений: `spawn "yozekos" "launcher"` |
| `Mod+N` | Центр уведомлений: `spawn "yozekos" "notifications"` |
| `Mod+W` | Галерея обоев: `spawn "yozekos" "wallpaper"` |
| `Mod+B` | Открыть настройки YozekOS: `spawn "yozekos" "settings"` |
| `Mod+S` | Открыть настройки YozekOS: `spawn "yozekos" "settings"` |
| `Mod+Shift+S` | Выбор области для снимка: `spawn "yozekos-capture-region"` |
| `XF86AudioRaiseVolume` | Управление звуком: `spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"` |
| `XF86AudioLowerVolume` | Управление звуком: `spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"` |
| `XF86AudioMute` | Управление звуком: `spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"` |
| `XF86AudioMicMute` | Управление звуком: `spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"` |
| `XF86AudioPlay` | Управление воспроизведением: `spawn-sh "playerctl play-pause"` |
| `XF86AudioStop` | Управление воспроизведением: `spawn-sh "playerctl stop"` |
| `XF86AudioPrev` | Управление воспроизведением: `spawn-sh "playerctl previous"` |
| `XF86AudioNext` | Управление воспроизведением: `spawn-sh "playerctl next"` |
| `XF86MonBrightnessUp` | Изменить яркость: `spawn "brightnessctl" "--class=backlight" "set" "+10%"` |
| `XF86MonBrightnessDown` | Изменить яркость: `spawn "brightnessctl" "--class=backlight" "set" "10%-"` |
| `Mod+O` | Обзор пространств Niri: `toggle-overview` |
| `Mod+Tab` | Обзор пространств Niri: `toggle-overview` |
| `Mod+Shift+Q` | Закрыть окно: `close-window` |
| `Mod+Left` | Фокус на столбец слева: `focus-column-left` |
| `Mod+Down` | Фокус на окно ниже: `focus-window-down` |
| `Mod+Up` | Фокус на окно выше: `focus-window-up` |
| `Mod+Right` | Фокус на столбец справа: `focus-column-right` |
| `Mod+H` | Фокус на столбец слева: `focus-column-left` |
| `Mod+J` | Фокус на окно ниже: `focus-window-down` |
| `Mod+K` | Фокус на окно выше: `focus-window-up` |
| `Mod+Ctrl+Left` | Переместить столбец влево: `move-column-left` |
| `Mod+Ctrl+Down` | Переместить окно ниже: `move-window-down` |
| `Mod+Ctrl+Up` | Переместить окно выше: `move-window-up` |
| `Mod+Ctrl+Right` | Переместить столбец вправо: `move-column-right` |
| `Mod+Ctrl+H` | Переместить столбец влево: `move-column-left` |
| `Mod+Shift+H` | Переместить столбец влево: `move-column-left` |
| `Mod+Ctrl+J` | Переместить окно ниже: `move-window-down` |
| `Mod+Shift+J` | Переместить окно ниже: `move-window-down` |
| `Mod+Ctrl+K` | Переместить окно выше: `move-window-up` |
| `Mod+Shift+K` | Переместить окно выше: `move-window-up` |
| `Mod+Ctrl+L` | Переместить столбец вправо: `move-column-right` |
| `Mod+Shift+L` | Заблокировать экран: `spawn "swaylock" "-f"` |
| `Mod+Home` | Действие Niri: `focus-column-first` |
| `Mod+End` | Действие Niri: `focus-column-last` |
| `Mod+Ctrl+Home` | Действие Niri: `move-column-to-first` |
| `Mod+Ctrl+End` | Действие Niri: `move-column-to-last` |
| `Mod+Shift+Left` | Действие Niri: `focus-monitor-left` |
| `Mod+Shift+Down` | Действие Niri: `focus-monitor-down` |
| `Mod+Shift+Up` | Действие Niri: `focus-monitor-up` |
| `Mod+Shift+Right` | Действие Niri: `focus-monitor-right` |
| `Mod+Shift+Ctrl+Left` | Действие Niri: `move-column-to-monitor-left` |
| `Mod+Shift+Ctrl+Down` | Действие Niri: `move-column-to-monitor-down` |
| `Mod+Shift+Ctrl+Up` | Действие Niri: `move-column-to-monitor-up` |
| `Mod+Shift+Ctrl+Right` | Действие Niri: `move-column-to-monitor-right` |
| `Mod+Shift+Ctrl+H` | Действие Niri: `move-column-to-monitor-left` |
| `Mod+Shift+Ctrl+J` | Действие Niri: `move-column-to-monitor-down` |
| `Mod+Shift+Ctrl+K` | Действие Niri: `move-column-to-monitor-up` |
| `Mod+Shift+Ctrl+L` | Действие Niri: `move-column-to-monitor-right` |
| `Mod+Page_Down` | Следующее рабочее пространство: `focus-workspace-down` |
| `Mod+Page_Up` | Предыдущее рабочее пространство: `focus-workspace-up` |
| `Mod+Alt+U` | Следующее рабочее пространство: `focus-workspace-down` |
| `Mod+I` | Предыдущее рабочее пространство: `focus-workspace-up` |
| `Mod+Ctrl+Page_Down` | Действие Niri: `move-column-to-workspace-down` |
| `Mod+Ctrl+Page_Up` | Действие Niri: `move-column-to-workspace-up` |
| `Mod+Ctrl+U` | Действие Niri: `move-column-to-workspace-down` |
| `Mod+Ctrl+I` | Действие Niri: `move-column-to-workspace-up` |
| `Mod+Shift+Page_Down` | Действие Niri: `move-workspace-down` |
| `Mod+Shift+Page_Up` | Действие Niri: `move-workspace-up` |
| `Mod+Shift+U` | Действие Niri: `move-workspace-down` |
| `Mod+Shift+I` | Действие Niri: `move-workspace-up` |
| `Mod+WheelScrollDown` | Следующее рабочее пространство: `focus-workspace-down` |
| `Mod+WheelScrollUp` | Предыдущее рабочее пространство: `focus-workspace-up` |
| `Mod+Ctrl+WheelScrollDown` | Действие Niri: `move-column-to-workspace-down` |
| `Mod+Ctrl+WheelScrollUp` | Действие Niri: `move-column-to-workspace-up` |
| `Mod+WheelScrollRight` | Фокус на столбец справа: `focus-column-right` |
| `Mod+WheelScrollLeft` | Фокус на столбец слева: `focus-column-left` |
| `Mod+Ctrl+WheelScrollRight` | Переместить столбец вправо: `move-column-right` |
| `Mod+Ctrl+WheelScrollLeft` | Переместить столбец влево: `move-column-left` |
| `Mod+Shift+WheelScrollDown` | Фокус на столбец справа: `focus-column-right` |
| `Mod+Shift+WheelScrollUp` | Фокус на столбец слева: `focus-column-left` |
| `Mod+Ctrl+Shift+WheelScrollDown` | Переместить столбец вправо: `move-column-right` |
| `Mod+Ctrl+Shift+WheelScrollUp` | Переместить столбец влево: `move-column-left` |
| `Mod+1` | Перейти в пространство 1: `focus-workspace 1` |
| `Mod+2` | Перейти в пространство 2: `focus-workspace 2` |
| `Mod+3` | Перейти в пространство 3: `focus-workspace 3` |
| `Mod+4` | Перейти в пространство 4: `focus-workspace 4` |
| `Mod+5` | Перейти в пространство 5: `focus-workspace 5` |
| `Mod+6` | Перейти в пространство 6: `focus-workspace 6` |
| `Mod+7` | Перейти в пространство 7: `focus-workspace 7` |
| `Mod+8` | Перейти в пространство 8: `focus-workspace 8` |
| `Mod+9` | Перейти в пространство 9: `focus-workspace 9` |
| `Mod+Ctrl+1` | Переместить столбец в пространство 1: `move-column-to-workspace 1` |
| `Mod+Shift+1` | Переместить окно в пространство 1: `move-window-to-workspace 1` |
| `Mod+Ctrl+2` | Переместить столбец в пространство 2: `move-column-to-workspace 2` |
| `Mod+Shift+2` | Переместить окно в пространство 2: `move-window-to-workspace 2` |
| `Mod+Ctrl+3` | Переместить столбец в пространство 3: `move-column-to-workspace 3` |
| `Mod+Shift+3` | Переместить окно в пространство 3: `move-window-to-workspace 3` |
| `Mod+Ctrl+4` | Переместить столбец в пространство 4: `move-column-to-workspace 4` |
| `Mod+Shift+4` | Переместить окно в пространство 4: `move-window-to-workspace 4` |
| `Mod+Ctrl+5` | Переместить столбец в пространство 5: `move-column-to-workspace 5` |
| `Mod+Shift+5` | Переместить окно в пространство 5: `move-window-to-workspace 5` |
| `Mod+Ctrl+6` | Переместить столбец в пространство 6: `move-column-to-workspace 6` |
| `Mod+Shift+6` | Переместить окно в пространство 6: `move-window-to-workspace 6` |
| `Mod+Ctrl+7` | Переместить столбец в пространство 7: `move-column-to-workspace 7` |
| `Mod+Shift+7` | Переместить окно в пространство 7: `move-window-to-workspace 7` |
| `Mod+Ctrl+8` | Переместить столбец в пространство 8: `move-column-to-workspace 8` |
| `Mod+Shift+8` | Переместить окно в пространство 8: `move-window-to-workspace 8` |
| `Mod+Ctrl+9` | Переместить столбец в пространство 9: `move-column-to-workspace 9` |
| `Mod+Shift+9` | Переместить окно в пространство 9: `move-window-to-workspace 9` |
| `Mod+BracketLeft` | Ввести или вывести окно слева: `consume-or-expel-window-left` |
| `Mod+BracketRight` | Ввести или вывести окно справа: `consume-or-expel-window-right` |
| `Mod+Comma` | Добавить окно в столбец: `consume-window-into-column` |
| `Mod+Period` | Извлечь окно из столбца: `expel-window-from-column` |
| `Mod+Alt+R` | Следующая ширина столбца: `switch-preset-column-width` |
| `Mod+Alt+Y` | Открыть терминал: `spawn "kitty" "--title" "Yazi" "yazi"` |
| `Mod+Shift+R` | Запись области экрана: `spawn "record"` |
| `Mod+Ctrl+Shift+R` | Следующая высота окна: `switch-preset-window-height` |
| `Mod+Ctrl+R` | Сбросить высоту окна: `reset-window-height` |
| `Mod+M` | Развернуть окно: `maximize-window-to-edges` |
| `Mod+Ctrl+F` | Растянуть столбец: `expand-column-to-available-width` |
| `Mod+F` | Полный экран: `fullscreen-window` |
| `Mod+C` | Центрировать столбец: `center-column` |
| `Mod+Ctrl+C` | Центрировать видимые столбцы: `center-visible-columns` |
| `Mod+Minus` | Действие Niri: `set-column-width "-10%"` |
| `Mod+Equal` | Действие Niri: `set-column-width "+10%"` |
| `Mod+Shift+Minus` | Действие Niri: `set-window-height "-10%"` |
| `Mod+Shift+Equal` | Действие Niri: `set-window-height "+10%"` |
| `Mod+V` | Выполнить команду: `spawn "rice-clip" "toggle"` |
| `Mod+Shift+F` | Переключить плавающее окно: `toggle-window-floating` |
| `Mod+Shift+V` | Переключить фокус между слоями: `switch-focus-between-floating-and-tiling` |
| `Mod+Shift+W` | Вкладки в столбце: `toggle-column-tabbed-display` |
| `Print` | Выбор области для снимка: `spawn "yozekos-capture-region"` |
| `Ctrl+Shift+2` | Снимок экрана: `screenshot-screen` |
| `Ctrl+Shift+3` | Снимок окна: `screenshot-window` |
| `Ctrl+Print` | Снимок экрана: `screenshot-screen` |
| `Alt+Print` | Снимок окна: `screenshot-window` |
| `Mod+Escape` | Переключить блокировку сочетаний: `toggle-keyboard-shortcuts-inhibit` |
| `Mod+Shift+E` | Выход из Niri с подтверждением: `quit` |
| `Ctrl+Alt+Delete` | Выход из Niri с подтверждением: `quit` |
| `Mod+Shift+P` | Выключить мониторы: `power-off-monitors` |
