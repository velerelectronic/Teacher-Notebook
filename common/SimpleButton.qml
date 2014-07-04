import QtQuick 2.0

Rectangle {
    id: simpleButton
    property alias label: contents.text
    property alias pointSize: contents.font.pointSize
    signal clicked()
    signal pressAndHold()

    width: contents.width
    height: contents.height
    color: 'green'

    Text {
        id: contents
        anchors.top: parent.top
        anchors.left: parent.left
    }
    MouseArea {
        anchors.fill: parent
        onClicked: simpleButton.clicked()
        onPressAndHold: simpleButton.pressAndHold()
    }
}
