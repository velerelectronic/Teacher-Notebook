import QtQuick 2.7

Rectangle {
    id: boxedText

    property string borderColor: 'black'
    property alias textColor: mainText.color
    property alias fontSize: mainText.font.pixelSize
    property alias text: mainText.text
    property alias margins: boxedText.padding
    property int padding: 0
    property int contentHeight: mainText.contentHeight + 2 * padding

    property real requiredHeight: mainText.paintedHeight + 2 * padding

    property alias elide: mainText.elide
    property bool boldFont: false
    property alias wrapMode: mainText.wrapMode
    property alias verticalAlignment: mainText.verticalAlignment
    property alias horizontalAlignment: mainText.horizontalAlignment
    property int contentWidth: margins * 2 + mainText.contentWidth

    border.color: borderColor
    Text {
        id: mainText
        anchors.fill: parent
        padding: parent.padding

        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        verticalAlignment: Text.AlignVCenter
        //elide: Text.ElideRight
        font.bold: boxedText.boldFont
    }
}
