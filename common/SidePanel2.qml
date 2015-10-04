import QtQuick 2.0

Item {
    id: sidePanel

    property alias panelWidth: panelItem.width
    property alias panelHeight: panelItem.height
    property real handleSize

    property real percentageShown: (panelWidth+panelItem.x)/panelWidth

    property bool enableSidePabel: false

    default property Component mainItem

    states: [
        State {
            name: 'showPanel'
            PropertyChanges {
                target: panelLoader
                sourceComponent: mainItem
                restoreEntryValues: false
            }

            PropertyChanges {
                target: panelItem
                x: 0
            }
            PropertyChanges {
                target: shadowMouseArea
                enabled: true
            }
        },
        State {
            name: 'hidePanel'

            PropertyChanges {
                target: panelItem
                x: -panelWidth
            }
            PropertyChanges {
                target: shadowMouseArea
                enabled: false
            }
            PropertyChanges {
                target: panelLoader
                sourceComponent: undefined
            }
        }
    ]
    state: 'hidePanel'

    transitions: [
        Transition {
            from: 'showPanel'
            to: 'hidePanel'

            PropertyAnimation {
                target: panelItem
                property: "x"
                duration: 200
            }
        }
    ]

    Rectangle {
        anchors.fill: parent
        color: 'black'
        opacity: 0.5 * percentageShown
        MouseArea {
            id: shadowMouseArea
            enabled: enableSidePabel
            anchors.fill: parent

            onPressed: {
                sidePanel.state = 'hidePanel';
            }
        }
    }

    Rectangle {
        id: panelItem
        y: 0

        Behavior on x {
            NumberAnimation { duration: 200 }
        }

        color: 'red'

        MouseArea {
            anchors.fill: parent
            anchors.rightMargin: -handleSize

            enabled: enableSidePabel
            drag.target: panelItem
            drag.axis: Drag.XAxis
            drag.minimumX: -panelItem.width
            drag.maximumX: 0
            onReleased: {
                if (panelItem.x> -panelWidth / 2) {
                    sidePanel.state = 'showPanel';
                } else {
                    sidePanel.state = 'hidePanel';
                }
            }
        }
        Loader {
            id: panelLoader
            anchors.fill: parent
        }
    }
}
