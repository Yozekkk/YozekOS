import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

// A saved AngelOS-style region shot appears briefly on the desktop.
PanelWindow {
    id: shot
    screen: Mon.screen
    anchors { top: true; right: true }
    implicitWidth: 288
    implicitHeight: 226
    margins { top: 50; right: 20 }
    exclusiveZone: 0
    color: "transparent"
    visible: open
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "yozekos-shot-preview"
    mask: Region { item: card }
    property bool open: false
    property string path: ""
    property real started: Date.now() / 1000
    FileView {
        id: latestShot
        path: Quickshell.env("HOME") + "/.cache/yozekos/last-shot.json"
        watchChanges: true
        printErrors: false
        onLoaded: {
            try {
                const next = JSON.parse(text())
                if (next.path && Number(next.time) >= shot.started && next.path !== shot.path) {
                    shot.path = next.path
                    shot.open = true
                    hideLater.restart()
                }
            } catch (e) { }
        }
    }
    // The capture process atomically replaces this file. Inotify can continue
    // watching the old inode, so rescan once a second for the next shot.
    Timer { interval: 1000; running: true; repeat: true; onTriggered: latestShot.reload() }
    Timer { id: hideLater; interval: 6000; onTriggered: shot.open = false }
    Rectangle {
        id: card
        anchors.fill: parent
        radius: 4
        color: "#20192a"
        border.width: 2
        border.color: "#e493bf"
        opacity: shot.open ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 170 } }
        Rectangle {
            id: head
            x: 3; y: 3; width: parent.width - 6; height: 25
            color: "#9d649b"
            Text { x: 8; anchors.verticalCenter: parent.verticalCenter; text: "YozekOS · Снимок"; color: "white"; font.family: Fonts.title; font.pixelSize: 13 }
            Text { anchors.right: parent.right; anchors.rightMargin: 8; anchors.verticalCenter: parent.verticalCenter; text: "×"; color: "white"; font.family: Fonts.title; font.pixelSize: 17 }
            MouseArea { x: parent.width - 30; width: 30; height: parent.height; onClicked: shot.open = false }
        }
        Image {
            id: picture
            x: 8; y: 34; width: parent.width - 16; height: 136
            source: shot.path ? "file://" + shot.path : ""
            sourceSize.width: 540; sourceSize.height: 280
            fillMode: Image.PreserveAspectCrop
            asynchronous: true; cache: false; smooth: false
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: shot.edit() }
        }
        Row {
            x: 8; y: 178; spacing: 5
            Repeater {
                model: [ {key: "edit", label: "Редактор"}, {key: "copy", label: "Копировать"}, {key: "open", label: "Открыть"} ]
                delegate: Rectangle {
                    id: action
                    required property var modelData
                    width: modelData.key === "copy" ? 92 : 82
                    height: 31; radius: 2
                    color: mouse.containsMouse ? "#65486e" : "#3a2b49"
                    border.width: 1; border.color: "#b789bb"
                    Text { anchors.centerIn: parent; text: action.modelData.label; color: "#fff6ff"; font.family: Fonts.main; font.pixelSize: 11 }
                    MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: {
                        if (action.modelData.key === "edit") shot.edit()
                        else if (action.modelData.key === "copy") shot.copy()
                        else Quickshell.execDetached(["xdg-open", shot.path])
                    } }
                }
            }
        }
    }
    function edit() {
        if (path) Quickshell.execDetached(["satty", "--filename", path, "--output-filename", path,
                                           "--font-family", "Pixeloid Sans", "--corner-roundness", "0", "--floating-hack"])
        open = false
    }
    function copy() {
        const mime = path.toLowerCase().endsWith(".webp") ? "image/webp" : (path.toLowerCase().endsWith(".jpg") ? "image/jpeg" : "image/png")
        Quickshell.execDetached(["bash", "-c", "wl-copy --type \"$1\" < \"$2\"", "_", mime, path])
        open = false
    }
}
