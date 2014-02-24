import QtQuick 2.0
import QtQuick.Layouts 1.1

Rectangle {
    id: editBox
    state: 'hidden'
    clip: true

    signal cancel
    signal deleteItems

    states: [
        State {
            name: 'hidden'
            PropertyChanges { target: editBox; height: 0 }
        },
        State {
            name: 'show'
            PropertyChanges { target: editBox; height: childrenRect.height }
        }
    ]
    onStateChanged: console.log(height);

    transitions: [
        Transition {
            from: 'hidden'
            to: 'show'
            PropertyAnimation {
                properties: 'height'
                easing.type: Easing.Linear
            }
        },
        Transition {
            from: 'show'
            to: 'hidden'
            PropertyAnimation {
                properties: 'height'
                easing.type: Easing.Linear
            }
        }
    ]

    RowLayout {
        anchors { left: parent.left; right: parent.right }
        height: childrenRect.height

        SimpleButton {
            label: 'Cancelar'
            pointSize: 18
            onClicked: {
                editBox.cancel();
                editBox.state = 'hidden';
            }
            color: 'white'
        }

        Text {
            font.pointSize: 18
            text: 'Selecciona'
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        SimpleButton {
            label: 'Esborra'
            pointSize: 18
            color: 'white'
            onClicked: editBox.deleteItems();
        }
    }
}
