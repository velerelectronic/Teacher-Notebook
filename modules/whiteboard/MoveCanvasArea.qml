import QtQuick 2.7

Rectangle {
    id: moveCanvasArea

    opacity: (enabled)?0.5:0
    color: 'gray'

    signal clicked()

    MouseArea {
        anchors.fill: parent
        onClicked: moveCanvasArea.clicked()
    }
}
