import QtQuick 2.0

Rectangle {
    id: panel

    property real minimumSize
    property real maximumSize

    states: [
        State {
            name: 'minimized'
            PropertyChanges {
                target: movingArea
                y: 0
            }
        },
        State {
            name: 'maximized'
            PropertyChanges {
                target: movingArea
                y: maximumSize-minimumSize
            }
        }
    ]
    state: 'minimized'

    height: movingArea.y + minimumSize

    MouseArea {
        id: movingArea
        anchors {
            left: parent.left
            right: parent.right
        }
        height: minimumSize

        preventStealing: true
        drag.target: movingArea
        drag.axis: Drag.YAxis
        drag.minimumY: 0
        drag.maximumY: maximumSize-minimumSize

        onReleased: {
            if (panel.height < (maximumSize+minimumSize) / 2) {
                panel.state = 'minimized';
            } else {
                panel.state = 'maximized';
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 250
            }
        }
    }

}

