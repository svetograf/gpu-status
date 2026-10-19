import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    readonly property string statusCmd: "cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status"
    readonly property string fuserCmd: "fuser -v /dev/nvidia* 2>&1"

    property string gpuStatus: "unknown"
    property string processes: ""
    readonly property bool active: gpuStatus === "active"

    preferredRepresentation: compactRepresentation
    Plasmoid.status: PlasmaCore.Types.ActiveStatus
    Plasmoid.icon: "nvidia"

    toolTipMainText: "NVIDIA GPU: " + gpuStatus
    toolTipSubText: processes.length > 0 ? processes : "No processes using /dev/nvidia*"
    toolTipTextFormat: Text.PlainText

    P5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: (source, data) => {
            const out = (data["stdout"] || "").trim()
            if (source === root.statusCmd) {
                root.gpuStatus = out || "unknown"
            } else if (source === root.fuserCmd) {
                root.processes = out
            }
            disconnectSource(source)
        }
        function run(cmd) { connectSource(cmd) }
    }

    function refresh() {
        executable.run(statusCmd)
        executable.run(fuserCmd)
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    compactRepresentation: MouseArea {
        Layout.minimumWidth: label.implicitWidth
        Layout.preferredWidth: Math.max(height, label.implicitWidth)
        onClicked: root.refresh()

        PlasmaComponents.Label {
            id: label
            anchors.fill: parent
            text: root.active ? "nv" : "in"
            color: root.active ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
            font.bold: root.active
            font.pixelSize: Math.round(parent.height * 0.6)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    fullRepresentation: PlasmaComponents.Label {
        text: root.processes.length > 0 ? root.processes : "No processes using /dev/nvidia*"
        font.family: "monospace"
        padding: Kirigami.Units.largeSpacing
    }
}
