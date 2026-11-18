import Quickshell
import Quickshell.Wayland
import QtQuick

// Event driven task buttons. Niri's window IDs survive title and workspace changes.
Item {
    id: tasks
    required property var panel
    required property var pal
    readonly property Item menuItem: menu
    readonly property bool shown: entries.length > 0
    readonly property int iconSize: panel.bc.task_icon_size || 20
    readonly property int buttonSize: Math.max(28, Math.min(panel.barH - 4, iconSize + 10))
    readonly property string style: panel.bc.task_style || "square"
    readonly property var windows: {
        Wm.tick; Wm.titleTick
        const all = Object.keys(Wm.nWin).map(k => Wm.nWin[k]).filter(w => w && w.id !== undefined)
        const current = Wm.nWs.find(w => w.is_focused)
        const out = panel.screen ? panel.screen.name : ""
        return all.filter(function(w) {
            const ws = Wm.nWs.find(x => x.id === w.workspace_id)
            if (panel.bc.task_all_workspaces === false && current && w.workspace_id !== current.id) return false
            if (panel.bc.task_all_monitors === false && ws && ws.output !== out) return false
            return true
        }).sort((a, b) => Number(a.id) - Number(b.id))
    }
    readonly property var entries: {
        if (panel.bc.task_mode !== "grouped") return windows.map(w => ({key: String(w.id), app: w.app_id || "", ids: [w.id], title: w.title || "", active: w.id === Wm.nFocusWin}))
        const byApp = {}, result = []
        for (const w of windows) {
            const app = w.app_id || "unknown-" + w.id
            if (!byApp[app]) { byApp[app] = {key: app, app: app, ids: [], title: w.title || "", active: false}; result.push(byApp[app]) }
            byApp[app].ids.push(w.id)
            if (w.id === Wm.nFocusWin) byApp[app].active = true
        }
        return result
    }
    height: panel.barH
    width: buttons.implicitWidth

    Row {
        id: buttons
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3
        Repeater {
            model: tasks.entries
            delegate: Item {
                id: button
                required property var modelData
                readonly property var entry: DesktopEntries.heuristicLookup(modelData.app)
                readonly property string iconName: entry && entry.icon ? entry.icon : modelData.app.toLowerCase()
                width: tasks.buttonSize
                height: tasks.buttonSize
                Rectangle {
                    anchors.fill: parent
                    radius: tasks.style === "flat" ? 0 : (tasks.style === "rounded" ? 7 : 2)
                    color: tasks.style === "flat" ? "transparent" : (button.modelData.active ? pal.container : (pointer.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.055)))
                    border.width: tasks.style === "flat" ? 0 : 1
                    border.color: button.modelData.active ? pal.primary : Qt.rgba(1, 1, 1, 0.12)
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                Image {
                    anchors.centerIn: parent
                    width: tasks.iconSize; height: tasks.iconSize
                    source: Icons.get(button.iconName, "application-x-executable")
                    sourceSize.width: tasks.iconSize * 2; sourceSize.height: tasks.iconSize * 2
                    asynchronous: true; cache: true; fillMode: Image.PreserveAspectFit
                    smooth: false
                }
                Rectangle {
                    visible: button.modelData.active
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 1
                    width: 9; height: 2; radius: 0
                    color: pal.primary
                }
                Rectangle {
                    visible: button.modelData.ids.length > 1
                    x: parent.width - 7; y: 2; width: 4; height: 4; radius: 0
                    color: pal.primary
                }
                HoverHandler { id: pointer }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: function(mouse) {
                        const ids = button.modelData.ids
                        if (mouse.button === Qt.RightButton) {
                            tasks.selected = button.modelData
                            tasks.menuOpen = true
                        } else if (ids.length > 1) {
                            tasks.selected = button.modelData
                            tasks.menuOpen = true
                        } else {
                            Quickshell.execDetached(["niri", "msg", "action", "focus-window", "--id", String(ids[0])])
                        }
                    }
                }
            }
        }
    }

    property var selected: null
    property bool menuOpen: false
    // The task list lives in a bar surface only one bar high. An expanding
    // menu needs its own layer surface or Wayland clips it above the bar.
    PanelWindow {
        id: menuWindow
        screen: tasks.panel.screen
        visible: tasks.menuOpen && tasks.selected !== null
        anchors { left: true; right: true; bottom: true }
        implicitHeight: 240
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "yozekos-task-menu"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        mask: Region { item: menu }
        Item { focus: true; Keys.onEscapePressed: tasks.menuOpen = false }
    Rectangle {
        id: menu
        readonly property point taskPos: tasks.mapToItem(tasks.panel.contentItem, 0, 0)
        x: Math.max(0, Math.min(menuWindow.width - width, taskPos.x))
        y: menuWindow.height - panel.barH - height - 14
        width: 250
        height: menuCol.implicitHeight + 12
        radius: 4
        color: "#202026"
        border.width: 1
        border.color: pal.primary
        Column {
            id: menuCol
            x: 6; y: 6; width: parent.width - 12; spacing: 2
            Repeater {
                model: tasks.selected ? tasks.selected.ids : []
                delegate: Item {
                    id: option
                    required property var modelData
                    readonly property var window: Wm.nWin[modelData]
                    width: menuCol.width; height: 30
                    Rectangle { anchors.fill: parent; radius: 2; color: optMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent" }
                    Text { x: 7; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 42
                        text: option.window ? (option.window.title || option.window.app_id || "Window") : "Window"
                        color: "#f4f0ec"; font.family: Fonts.main; font.pixelSize: 12; elide: Text.ElideRight }
                    MouseArea { id: optMouse; x: 0; width: parent.width - 32; height: parent.height; hoverEnabled: true; onClicked: {
                        Quickshell.execDetached(["niri", "msg", "action", "focus-window", "--id", String(option.modelData)])
                        tasks.menuOpen = false
                    } }
                    Text { x: parent.width - 22; anchors.verticalCenter: parent.verticalCenter; text: "×"; color: "#f4b4b4"; font.pixelSize: 17 }
                    MouseArea { x: parent.width - 32; width: 32; height: parent.height; cursorShape: Qt.PointingHandCursor; onClicked: {
                        Quickshell.execDetached(["niri", "msg", "action", "close-window", "--id", String(option.modelData)])
                        tasks.menuOpen = false
                    } }
                }
            }
            Rectangle { width: menuCol.width; height: 1; color: "#55515d" }
            Rectangle {
                width: menuCol.width; height: 28; radius: 2
                color: pinMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
                Text { x: 7; anchors.verticalCenter: parent.verticalCenter; text: "Pin application"; color: "#f4f0ec"; font.family: Fonts.main; font.pixelSize: 12 }
                MouseArea { id: pinMouse; anchors.fill: parent; hoverEnabled: true; onClicked: {
                    const app = tasks.selected ? DesktopEntries.heuristicLookup(tasks.selected.app) : null
                    if (app && app.id) Quickshell.execDetached([Quickshell.env("HOME") + "/.local/bin/yozekos-launcher-state", "toggle", app.id])
                    tasks.menuOpen = false
                } }
            }
            Rectangle {
                width: menuCol.width; height: 28; radius: 2
                color: newMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
                Text { x: 7; anchors.verticalCenter: parent.verticalCenter; text: "Open new window"; color: "#f4f0ec"; font.family: Fonts.main; font.pixelSize: 12 }
                MouseArea { id: newMouse; anchors.fill: parent; hoverEnabled: true; onClicked: {
                    const app = tasks.selected ? DesktopEntries.heuristicLookup(tasks.selected.app) : null
                    if (app) app.execute()
                    tasks.menuOpen = false
                } }
            }
        }
    }
    }
}
