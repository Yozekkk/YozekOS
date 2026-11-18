import QtQuick

// Text in Settings. Follows Settings > Appearance > Fonts > Typography: the text size, heavier headings and
// rounded letters (Google Sans Flex has a roundness axis). Live previews set scaled: false to keep their own size.
Text {
    id: t
    property string kind: "body"
    property bool scaled: kind !== "icon"
    property int basePx: 0
    property int baseW: Font.Normal
    color: M3.ink
    font.family: Fonts.family(kind)
    font.pixelSize: 14
    Component.onCompleted: {
        if (!scaled) return
        basePx = font.pixelSize
        baseW = font.weight
        font.pixelSize = Qt.binding(function() { return Fonts.fontPx(t.basePx, t.kind, Prefs.textScale) })
        if (kind === "title")
            font.weight = Qt.binding(function() { return Prefs.emphHeadings ? Math.min(Font.Black, Math.max(t.baseW + 100, Font.DemiBold)) : t.baseW })
    }
}
