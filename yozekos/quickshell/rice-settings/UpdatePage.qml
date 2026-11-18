import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: page
    property var ctl
    property string version: ""
    property string generations: ""

    Process {
        id: info
        command: ["bash", "-c", "nixos-version; nix-env --profile /nix/var/nix/profiles/system --list-generations 2>/dev/null | tail -n 4"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                page.version = lines.shift() || "unknown"
                page.generations = lines.join("\n")
            }
        }
    }
    Column {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 22
        T { kind: "title"; text: "YozekOS System Updates"; font.pixelSize: 24 }
        T { text: "NixOS " + page.version; font.pixelSize: 15 }
        T { text: "System updates use the machine's NixOS configuration. A rebuild requests administrator authentication.";
            width: parent.width; wrapMode: Text.WordWrap; font.pixelSize: 14 }
        T { text: "Recent system generations:"; font.pixelSize: 14 }
        T { kind: "mono"; text: page.generations || "Checking..."; font.pixelSize: 13; width: parent.width; wrapMode: Text.WordWrap }
        Btn {
            text: "Open configuration"
            icon: ""
            onClicked: Quickshell.execDetached(["xdg-open", "/etc/nixos/configuration.nix"])
        }
        Btn {
            text: "Build and switch NixOS"
            icon: ""
            onClicked: Quickshell.execDetached(["kitty", "-e", "bash", "-lc", "sudo nixos-rebuild build --no-flake && sudo nixos-rebuild switch --no-flake; read -r -p 'Press Enter to close'"])
        }
        T { text: "A new boot and shell check are required before old generations can be pruned.";
            width: parent.width; wrapMode: Text.WordWrap; font.pixelSize: 13 }
    }
}
