import QtQuick 2.3

Item {
    id: superposedButton

    property alias fontSize: text.font.pixelSize
    property int size: 100
    property alias label: text.text
    property int margins: 100
    signal clicked

    width: size
    height: size

    Rectangle {
        anchors.fill: parent
        anchors.margins: margins

        radius: width / 2
        color: 'green'

        Text {
            id: text
            anchors.fill: parent
            text: '+'
            color: 'white'
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: superposedButton.clicked()
        }
    }

}
