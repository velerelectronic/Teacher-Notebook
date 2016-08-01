import QtQuick 2.2

Rectangle {
    id: loadingBox

    property string actualitzat
    height: textContents.height

    state: 'loading'
    states: [
        State {
            name: 'loading'
            PropertyChanges {
                target: loadingBox
                color: 'yellow'
                height: units.fingerUnit
            }
            PropertyChanges {
                target: textContents
                color: 'gray'
                font.pixelSize: units.readUnit
                text: qsTr('Actualitzant...')
            }
        },
        State {
            name: 'perfect'
            PropertyChanges {
                target: loadingBox
                color: 'white'
                height: units.readUnit
            }
            PropertyChanges {
                target: textContents
                color: 'gray'
                font.pixelSize: units.smallReadUnit
                text: qsTr('Actualitzat ') + loadingBox.actualitzat
            }
        },
        State {
            name: 'updateable'
            PropertyChanges {
                target: loadingBox
                color: 'white'
                height: units.readUnit
            }
            PropertyChanges {
                target: textContents
                color: 'black'
                font.pixelSize: units.glanceUnit
                text: qsTr('Estira cap avall per actualitzar.')
            }
        }
    ]

    Text {
        id: textContents
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: contentHeight
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
