import QtQuick 2.6
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common

ListView {
    id: openedPagesList

    signal pageSelected(int index)

    Common.UseUnits {
        id: units
    }

    spacing: units.nailUnit

    delegate: Rectangle {
        width: openedPagesList.width
        height: units.fingerUnit * 1.5
        color: '#AAFFAA'

        Text {
            anchors.fill: parent
            padding: units.nailUnit

            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: units.readUnit
            text: model.caption
        }

        MouseArea {
            anchors.fill: parent
            onClicked: pageSelected(model.index)
        }
    }
}
