import Quickshell
import Quickshell.Io
import QtQuick

// All controls write the capture selector's live configuration.
Item {
    id: page
    property var ctl
    property var cfg: ({})
    property string folderKey: "shotDir"
    function v(k, fallback) { return cfg[k] === undefined ? fallback : cfg[k] }
    function setv(k, value) {
        if (save.running) return
        save.command = ["bash", "-c", "\"$HOME/.local/bin/yozekos-capture-settings\" set \"$1\" \"$2\"", "_", k, String(value)]
        save.running = true
    }
    Process {
        id: load
        command: ["bash", "-c", "\"$HOME/.local/bin/yozekos-capture-settings\" state"]
        running: true
        stdout: StdioCollector { onStreamFinished: { try { page.cfg = JSON.parse(text) } catch (e) { } } }
    }
    Process {
        id: save
        onExited: function(code) { page.ctl.status = code === 0 ? I18n.t("Applied") : I18n.t("That did not work"); load.running = true }
    }
    Process {
        id: choose
        stdout: StdioCollector { onStreamFinished: { const p = text.trim(); if (p) page.setv(page.folderKey, p) } }
    }
    onVisibleChanged: if (visible && !load.running) load.running = true
    PageScroll {
        anchors.fill: parent
        T { kind: "title"; text: "Скриншоты и запись"; font.pixelSize: 20; font.bold: true }
        T { kind: "reading"; text: "Print / Super+Shift+S — область · Ctrl+Shift+2 — экран · Ctrl+Shift+3 — окно"; color: M3.inkDim }
        SegRow {
            label: "Оформление выделения"
            desc: "Оригинальные варианты интерфейса AngelOS"
            options: [{label: "Ropes", value: "ropes"}, {label: "Window", value: "window"}, {label: "Stream", value: "stream"}]
            current: page.v("skin", "window")
            onChosen: function(x) { page.setv("skin", x) }
        }
        SegRow {
            label: "Формат снимка"
            options: [{label: "PNG", value: "png"}, {label: "JPEG", value: "jpg"}, {label: "WebP", value: "webp"}]
            current: page.v("shotFormat", "png")
            onChosen: function(x) { page.setv("shotFormat", x) }
        }
        SliderRow {
            label: "Качество JPEG / WebP"
            from: 1; to: 100; step: 1; decimals: 0
            value: page.v("shotQuality", 90)
            onCommitted: function(x) { page.setv("shotQuality", Math.round(x)) }
        }
        SliderRow {
            label: "Задержка перед снимком"
            desc: "Секунды после выбора области"
            from: 0; to: 30; step: 1; decimals: 0
            value: page.v("shotDelay", 0)
            onCommitted: function(x) { page.setv("shotDelay", Math.round(x)) }
        }
        ToggleRow { label: "Копировать снимок в буфер"; checked: page.v("shotCopy", true); onToggled: function(x) { page.setv("shotCopy", x ? "on" : "off") } }
        ToggleRow { label: "Показывать предпросмотр"; checked: page.v("shotPreview", true); onToggled: function(x) { page.setv("shotPreview", x ? "on" : "off") } }
        ToggleRow { label: "Звук снимка"; checked: page.v("shotSound", false); onToggled: function(x) { page.setv("shotSound", x ? "on" : "off") } }
        T { kind: "title"; text: "Папка снимков"; font.pixelSize: 16; font.bold: true; topPadding: 12 }
        T { kind: "reading"; text: page.v("shotDir", "~/Pictures/Screenshots"); color: M3.inkDim; wrapMode: Text.WrapAnywhere; width: parent.width }
        Rectangle {
            width: 190; height: 36; radius: 3; color: M3.surfaceHigh; border.width: 1; border.color: M3.outlineVariant
            T { anchors.centerIn: parent; text: "Выбрать папку" }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: {
                page.folderKey = "shotDir"
                choose.command = ["bash", "-c", "zenity --file-selection --directory --title='YozekOS: снимки' 2>/dev/null || kdialog --getexistingdirectory ~ 2>/dev/null"]
                choose.running = true
            } }
        }
        T { kind: "title"; text: "Папка видеозаписей"; font.pixelSize: 16; font.bold: true; topPadding: 12 }
        T { kind: "reading"; text: page.v("recordDir", "~/Videos/Recordings"); color: M3.inkDim; wrapMode: Text.WrapAnywhere; width: parent.width }
        Rectangle {
            width: 190; height: 36; radius: 3; color: M3.surfaceHigh; border.width: 1; border.color: M3.outlineVariant
            T { anchors.centerIn: parent; text: "Выбрать папку" }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: {
                page.folderKey = "recordDir"
                choose.command = ["bash", "-c", "zenity --file-selection --directory --title='YozekOS: видеозаписи' 2>/dev/null || kdialog --getexistingdirectory ~ 2>/dev/null"]
                choose.running = true
            } }
        }
        Rectangle {
            width: 210; height: 36; radius: 3; color: M3.surfaceHigh; border.width: 1; border.color: M3.outlineVariant
            T { anchors.centerIn: parent; text: "Настройки видеозаписи" }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: page.ctl.page = 5 }
        }
    }
}
