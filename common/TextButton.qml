import QtQuick 2.5

Text {
    id: textButton

    property int fontSize

    signal clicked()

    font.pixelSize: fontSize
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter

    width: contentWidth

    MouseArea {
        anchors.fill: parent
        onClicked: textButton.clicked()
    }
}