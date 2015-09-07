import QtQuick 2.2
import 'qrc:///common' as Common


Rectangle {
    id: bigButton
    Common.UseUnits { id: units }
    height: units.fingerUnit * 2
    border.color: "green"
    color: "#d5ffcc"
    property alias title: titleText.text
    signal clicked()

    Text {
        id: titleText
        anchors.fill: parent
        anchors.margins: units.nailUnit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: units.readUnit
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }
    MouseArea {
        anchors.fill: parent
        onClicked: bigButton.clicked()
    }
}
