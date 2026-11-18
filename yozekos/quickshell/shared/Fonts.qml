pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// YozekOS typography uses the AngelOS families; symbols keep a dedicated glyph font.
Singleton {
    id: fonts
    readonly property var installed: Qt.fontFamilies()
    function has(name) { return installed.indexOf(name) >= 0 }
    readonly property string bodyDefault: has("CozetteVector") ? "CozetteVector" : "Noto Sans"
    readonly property string titleDefault: has("Pixeloid Sans") ? "Pixeloid Sans" : bodyDefault
    readonly property string monoDefault: has("Pixeloid Mono") ? "Pixeloid Mono" : "monospace"
    readonly property string iconDefault: has("Symbols Nerd Font") ? "Symbols Nerd Font" : monoDefault
    readonly property bool symbols: has("Material Symbols Rounded")
    property string rMain: ""
    property string rNumbers: ""
    property string rTitle: ""
    property string rReading: ""
    property string rMono: ""
    property string rIcons: ""
    function select(name, fallback) { return name && has(name) ? name : fallback }
    readonly property string main: select(rMain, bodyDefault)
    readonly property string reading: select(rReading, bodyDefault)
    readonly property string title: select(rTitle, titleDefault)
    readonly property string numbers: select(rNumbers, monoDefault)
    readonly property string mono: select(rMono, monoDefault)
    readonly property string code: mono
    readonly property string icons: select(rIcons, iconDefault)
    function family(kind) {
        switch (kind) {
        case "title": return title
        case "number": return numbers
        case "mono": case "code": return mono
        case "icon": return icons
        case "reading": return reading
        default: return main
        }
    }
    // AngelOS Theme.fontPx adapted to Qt logical sizes. Native glyph cells remain whole.
    function fontPx(base, kind, scale) {
        const name = family(kind || "body")
        const grid = name === "CozetteVector" ? 13 : (name === "Pixeloid Sans" || name === "Pixeloid Mono" ? 9 : 0)
        const wanted = Math.max(1, Number(base) * (scale || 1))
        return grid ? grid * Math.max(1, Math.round(wanted / grid)) : Math.round(wanted)
    }
    Process {
        id: reload
        command: ["bash", "-c", "cat \"$HOME/.config/rice/fonts.json\" 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let data = {}
                try { data = JSON.parse(text) } catch (error) { data = {} }
                fonts.rMain = data.main || ""
                fonts.rNumbers = data.numbers || ""
                fonts.rTitle = data.title || ""
                fonts.rReading = data.reading || ""
                fonts.rMono = data.mono || ""
                fonts.rIcons = data.icons || ""
            }
        }
    }
    Timer { interval: 1500; running: true; repeat: true; onTriggered: if (!reload.running) reload.running = true }
}
