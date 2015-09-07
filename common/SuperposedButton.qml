import QtQuick 2.3

Item {
    id: superposedButton

    property alias fontSize: text.font.pixelSize
    property int size: 100
    property alias label: text.text
    property string imageSource: ''
    property int margins: size / 4
    signal clicked
    signal pressAndHold

    width: size + 2 * margins
    height: width

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
        Image {
            id: image
            anchors.fill: parent
            anchors.margins: parent.radius / 4
            source: 'qrc:///icons/' + imageSource + '.svg'
            fillMode: Image.PreserveAspectFit
        }

        MouseArea {
            anchors.fill: parent
            onClicked: superposedButton.clicked()
            onPressAndHold: superposedButton.pressAndHold()
        }
    }

}
