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

    contentItem: Rectangle {
        color: 'pink'
        implicitHeight: Math.min(parentHeight * 0.8, menuList.contentItem.height + units.fingerUnit * 2)
        implicitWidth: superposedMenu.parentWidth

        ColumnLayout {
            anchors.fill: parent

            ListView {
                id: menuList
                Layout.fillHeight: true
                Layout.fillWidth: true

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

            Item {
                Layout.preferredHeight: units.fingerUnit * 2
                Layout.fillWidth: true
                RowLayout {
                    anchors.fill: parent
                    spacing: units.fingerUnit

                    Button {
                        text: qsTr('Accepta')
                        onClicked: {
                            superposedMenu.close();
                            superposedMenu.accepted();
                        }
                    }

                    Button {
                        text: qsTr('Tanca')
                        onClicked: {
                            superposedMenu.close();
                            superposedMenu.rejected();
                        }
                    }
                }
            }
        }
    }
}
