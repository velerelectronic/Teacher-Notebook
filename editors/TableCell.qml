import QtQuick 2.0

Rectangle {
    border.color: 'green'
    property alias text: cellText.text

    Text {
        id: cellText
        anchors.fill: parent
        anchors.margins: units.nailUnit
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        font.pixelSize: units.readUnit
        clip: true
    }
}
