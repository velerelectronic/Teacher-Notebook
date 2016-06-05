import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import 'qrc:///common' as Common

ListView {
    id: superposedWidgetList

    signal closeList()

    property string caption: ''
    property ObjectModel listItems: null

    Common.UseUnits {
        id: units
    }

    clip: true

    headerPositioning: ListView.OverlayHeader
    header: Rectangle {
        width: superposedWidgetList.width
        height: units.fingerUnit
        z: 2

        RowLayout {
            anchors.fill: parent
            Text {
                Layout.fillHeight: true
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: caption
            }
            Common.ImageButton {
                Layout.fillHeight: true
                Layout.preferredWidth: size
                size: units.fingerUnit
                image: 'road-sign-147409'
                onClicked: closeList()
            }
        }

    }

    model: listItems
}
