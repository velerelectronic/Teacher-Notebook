import QtQuick 2.0

Generic {
    property string text: ''
    requiredWidth: mainText.contentWidth
    requiredHeight: mainText.contentHeight

    Text {
        id: mainText

        anchors.fill: parent
        font.pixelSize: units.readUnit * 2
        font.bold: true

        //wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        text: parent.text
    }
}
