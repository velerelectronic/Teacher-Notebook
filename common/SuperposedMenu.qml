import QtQuick 2.5
import QtQuick.Window 2.0
import QtQml.Models 2.2
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import 'qrc:///common' as Common

Dialog {
    id: superposedMenu

    default property alias entries: menuEntriesModel.children

    property int parentWidth: Screen.width * 0.8
    property int parentHeight: Screen.height * 0.8

    standardButtons: StandardButton.Close

    Rectangle {
        color: 'pink'
        implicitHeight: Math.min(parentHeight * 0.8, menuList.contentItem.height)
        implicitWidth: superposedMenu.parentWidth

        ListView {
            id: menuList
            anchors.fill: parent

            headerPositioning: ListView.OverlayHeader

            interactive: true
            clip: true

            boundsBehavior: ListView.StopAtBounds

            header: Rectangle {
                width: menuList.width
                height: units.fingerUnit * 2
                z: 2

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit

                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        font.bold: true
                        font.pixelSize: units.readUnit
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: superposedMenu.title
                    }
                }
            }

            model: ObjectModel {
                id: menuEntriesModel
            }

            spacing: units.nailUnit
        }
    }
}
