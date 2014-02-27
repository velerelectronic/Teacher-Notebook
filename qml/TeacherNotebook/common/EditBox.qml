import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import '../common' as Common

Rectangle {
    id: editBox
    height: childrenRect.height
    clip: true

    signal cancel
    signal deleteItems
    property int maxHeight: 0

    Common.UseUnits { id: units }

    states: [
        State {
            name: 'hidden'
            PropertyChanges { target: editBox; height: 0 }
        },
        State {
            name: 'show'
            PropertyChanges { target: editBox; height: editBox.maxHeight }
        }
    ]
    state: 'hidden'

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
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: units.fingerUnit

        Button {
            height: parent.height
            text: qsTr('Cancelar')
            onClicked: {
                editBox.cancel();
                editBox.state = 'hidden';
            }
        }

        Text {
            Layout.fillWidth: true
            height: parent.height
            font.pixelSize: units.nailUnit
            text: qsTr('Selecciona')
            horizontalAlignment: Text.AlignHCenter
        }

        Button {
            height: parent.height
            text: qsTr('Esborra')
            onClicked: editBox.deleteItems();
        }
    }
}
