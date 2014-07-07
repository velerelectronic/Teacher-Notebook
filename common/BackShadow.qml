import QtQuick 2.2

Rectangle {
    id: backShadow
    color: 'black'
    opacity: 0
    property int duration
    signal clicked()

    states: [
        State {
            name: 'active'
            PropertyChanges {
                target: backShadow
                opacity: 0.5
            }
        },
        State {
            name: 'inactive'
            PropertyChanges {
                target: backShadow
                opacity: 0
            }
        }
    ]
    state: 'hidden'
    Behavior on opacity {
        NumberAnimation {
            duration: duration
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        enabled: (backShadow.state === 'active')
        onClicked: backShadow.clicked()
    }
}
