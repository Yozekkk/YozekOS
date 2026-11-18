pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// The colors of Settings, in the spirit of Material 3: tonal surfaces and one key color taken from your theme
// (the accent of Theme / your wallpaper). Every part of Settings reads them from here.
Singleton {
    id: m
    property string seed: "#8b75ff"
    property bool light: false
    FileView {
        path: Quickshell.env("HOME") + "/.config/rice/palette-mode"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: m.light = text().trim() === "light"
    }
    // the accent of your theme (matugen writes it with every new wallpaper): read again whenever it changes, so
    // Settings takes the new colors while it is open (it kept the old ones, e.g. green on a black wallpaper)
    FileView {
        path: Quickshell.env("HOME") + "/.config/waybar/colors.css"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            const r = /@define-color accent *(#[0-9a-fA-F]{6})/.exec(text())
            if (r) m.seed = r[1]
        }
    }

    function rgb(c) { const q = Qt.color(c); return [q.r, q.g, q.b] }
    function mix(a, b, k) { const x = rgb(a), y = rgb(b); return Qt.rgba(x[0] + (y[0] - x[0]) * k, x[1] + (y[1] - x[1]) * k, x[2] + (y[2] - x[2]) * k, 1) }
    function lum(c) { const x = rgb(c); return 0.299 * x[0] + 0.587 * x[1] + 0.114 * x[2] }
    function alpha(c, a) { const x = rgb(c); return Qt.rgba(x[0], x[1], x[2], a) }
    // the key color, light enough to read on the dark surfaces
    function lift(c, target) { let k = 0; while (k < 0.9 && lum(mix(c, "#ffffff", k)) < target) k += 0.05; return mix(c, "#ffffff", k) }

    readonly property color primary: light ? mix(seed, "#000000", 0.22) : lift(seed, 0.62)
    readonly property color inkPrimary: light ? "#ffffff" : mix(seed, "#000000", 0.82)
    readonly property color primaryContainer: light ? mix(primary, "#ffffff", 0.72) : mix(primary, "#151718", 0.68)
    readonly property color inkPrimaryC: light ? "#272436" : mix(primary, "#ffffff", 0.55)
    readonly property color secondaryContainer: light ? mix(primary, "#ffffff", 0.83) : mix(primary, "#1b1d1e", 0.8)
    readonly property color inkSecondaryC: light ? "#292735" : mix(primary, "#ffffff", 0.7)
    readonly property color tertiary: lift(mix(seed, "#e8a87c", 0.55), 0.6)

    // surfaces: near black with a hint of the key color, each container a step lighter
    readonly property color surface: light ? "#f4f1fa" : mix("#111213", seed, 0.035)
    readonly property color surfaceLow: light ? "#f0ecf7" : mix("#17181a", seed, 0.04)
    readonly property color surfaceC: light ? "#ebe6f4" : mix("#1c1d20", seed, 0.05)
    readonly property color surfaceHigh: light ? "#e4def0" : mix("#25272a", seed, 0.06)
    readonly property color surfaceHighest: light ? "#dcd5ea" : mix("#2f3134", seed, 0.07)
    readonly property color ink: light ? "#24202e" : "#E5E3E3"
    readonly property color inkDim: light ? "#504a5c" : "#B6B8BA"
    readonly property color outline: light ? "#736c80" : "#8C8F92"
    readonly property color outlineVariant: light ? "#bcb4c7" : "#3B3E42"
    readonly property color error: light ? "#b3261e" : "#FFB4AB"
    // more roles for Appearance > Colors
    readonly property color secondary: mix(primary, "#c8c8c8", 0.45)
    readonly property color tertiaryContainer: light ? mix(tertiary, "#ffffff", 0.72) : mix(tertiary, "#151718", 0.68)
    readonly property color inkTertiaryC: light ? "#2a2230" : mix(tertiary, "#ffffff", 0.6)
    readonly property color errorContainer: light ? "#f9dedc" : "#93000A"
    readonly property color inkErrorC: light ? "#410e0b" : "#FFDAD6"
    readonly property color surfaceLowest: light ? "#ffffff" : mix("#0c0d0e", seed, 0.03)
    readonly property color surfaceBright: light ? "#ffffff" : mix("#38393c", seed, 0.08)
    readonly property color inverseSurface: light ? "#302a37" : "#E3E2E2"
    readonly property color inversePrimary: mix(seed, "#000000", 0.35)
    // the little stage behind live previews
    readonly property color stageTop: mix(surfaceHigh, primary, 0.14)
    readonly property color stageBottom: surfaceLow

    // shape: corner sizes
    readonly property real shapeK: Prefs.cornerScale
    readonly property int rS: Math.round(3 * shapeK)
    readonly property int rM: Math.round(5 * shapeK)
    readonly property int rL: Math.round(7 * shapeK)
    readonly property int rXL: Math.round(9 * shapeK)
    // motion: Material's emphasized curve, or a small spring (Settings > Motion)
    readonly property var emph: [0.2, 0, 0, 1, 1, 1]
    readonly property bool bouncy: Prefs.motion === "expressive"
    function d(ms) { return Math.round(ms / Prefs.motionSpeed) }
    readonly property int springy: bouncy ? Easing.OutBack : Easing.OutCubic
}
