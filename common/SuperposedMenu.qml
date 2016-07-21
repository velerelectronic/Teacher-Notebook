import QtQuick 2.5
import QtQml.Models 2.2
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

Common.SuperposedWidget {
    id: superposedMenu

    minimumHeight: menuList.contentItem.height

    glowColor: 'black'

    signal closeRequested()

    property string headerTitle
    default property alias entries: menuEntriesModel.children

    onCloseRequested: hideWidget()

    ListView {
        id: menuList
        anchors.fill: parent

        headerPositioning: ListView.OverlayHeader

        interactive: false

        header: Rectangle {
            width: menuList.width
            height: units.fingerUnit * 2

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
                    text: headerTitle
                }

                Common.ImageButton {
                    image: 'road-sign-147409'
                    Layout.fillHeight: true
                    onClicked: superposedMenu.closeRequested()
                }
            }

        }

        model: ObjectModel {
            id: menuEntriesModel
        }

        spacing: units.nailUnit
    }
}
