import QtQuick 2.5
import 'qrc:///common' as Common

Rectangle {
    id: menuEntry

    signal clicked()

    property string text: ''

    //width: parent.width
    height: units.fingerUnit * 1.5

    Common.UseUnits {
        id: units
    }

    Text {
        anchors.fill: parent
        anchors.margins: units.nailUnit
        text: menuEntry.text
        verticalAlignment: Text.AlignVCenter
    }

    MouseArea {
        anchors.fill: parent
        onClicked: menuEntry.clicked()
    }
}
