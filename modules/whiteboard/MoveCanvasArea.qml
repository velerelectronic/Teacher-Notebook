import QtQuick 2.7

Rectangle {
    id: moveCanvasArea

    opacity: 0.5
    color: 'gray'

    signal clicked()

    MouseArea {
        anchors.fill: parent
        onClicked: moveCanvasArea.clicked()
    }
}
