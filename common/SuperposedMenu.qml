import QtQuick 2.5
import QtQml.Models 2.2
import 'qrc:///common' as Common

Common.SuperposedWidget {
    id: superposedMenu

    minimumHeight: menuList.contentItem.height

    glowColor: 'black'

    property string headerTitle
    default property alias entries: menuEntriesModel.children

    ListView {
        id: menuList
        anchors.fill: parent

        headerPositioning: ListView.OverlayHeader

        interactive: false

        header: Rectangle {
            width: menuList.width
            height: units.fingerUnit

            Text {
                anchors.fill: parent
                font.bold: true
                font.pixelSize: units.readUnit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: headerTitle
            }
        }

        model: ObjectModel {
            id: menuEntriesModel
        }

        spacing: units.nailUnit
    }
}
