import QtQuick 2.3
import '../common' as Common

Item {
    id: editBox
    Common.UseUnits { id: units }
    default property alias innerWidget: inside.children

    signal closeRequested

    states: [
        State {
            name: 'show'
            PropertyChanges {
                target: editBox
                visible: true
            }
        },
        State {
            name: 'hide'
            PropertyChanges {
                target: editBox
                visible: false
            }
        }

    ]
    state: 'hide'

    Rectangle {
        anchors.fill: parent
        anchors.margins: 0
        color: 'black'
        opacity: 0.5
    }
    MouseArea {
        anchors.fill: parent
        onPressed: mouse.accepted = true
        onClicked: closeRequested()
    }
    MouseArea {
        anchors.fill: inside
        onPressed: mouse.accepted = true
    }
    Item {
        id: inside
        anchors.fill: parent
        anchors.margins: units.fingerUnit
    }

}
