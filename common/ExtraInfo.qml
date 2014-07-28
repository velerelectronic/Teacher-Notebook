import QtQuick 2.2

Rectangle {
    property int minHeight
    property int contentHeight
    property bool available: true

    color: 'yellow'
    visible: available && (minHeight < contentHeight)
    border.color: 'black'
    anchors.top: parent.top
    anchors.margins: units.nailUnit
    anchors.right: parent.right
    height: minHeight - anchors.margins * 2
    width: height

    Text {
        anchors.fill: parent
        anchors.margins: units.nailUnit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: units.readUnit
        text: qsTr('Més')
    }
}
