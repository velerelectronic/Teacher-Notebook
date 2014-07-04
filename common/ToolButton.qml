import QtQuick 2.0

Rectangle {
    id: button
    property alias text: buttonText.text
    property alias textSize: buttonText.font.pixelSize

    signal clicked()

    width: 100
    height: 100
    Text {
        id: buttonText
        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    MouseArea {
        anchors.fill: parent
        onClicked: button.clicked()
    }
}
