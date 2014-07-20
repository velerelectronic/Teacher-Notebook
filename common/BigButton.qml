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
        anchors.centerIn: parent
        font.pixelSize: units.readUnit
    }
    MouseArea {
        anchors.fill: parent
        onClicked: bigButton.clicked()
    }
}
