import QtQuick 2.0

Rectangle {
    id: boxedText

    property string borderColor: 'black'
    property alias textColor: mainText.color
    property alias fontSize: mainText.font.pixelSize
    property alias text: mainText.text
    property int margins: 0

    border.color: borderColor
    Text {
        id: mainText
        anchors.fill: parent
        anchors.margins: margins

        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
