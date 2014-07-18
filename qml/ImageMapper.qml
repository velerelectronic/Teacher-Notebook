import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import 'qrc:///common' as Common
import 'PersonalTypes' 1.0


Rectangle {
    color: 'yellow'
    property string pageTitle: qsTr('Mapa d\'imatge')
    property string background: ''

    Common.UseUnits {
        id: units
    }

    ColumnLayout {
        anchors.fill: parent
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            Button {
                text: qsTr('Zoom')
                menu: Menu {
                    MenuItem {
                        text: qsTr('Zoom -')
                        onTriggered: mainItem.scale = (mainItem.scale>=0.2)?(mainItem.scale - 0.1):0.1
                    }
                    MenuItem {
                        text: qsTr('1:1')
                        onTriggered: mainItem.scale = 1
                    }
                    MenuItem {
                        text: qsTr('Zoom +')
                        onTriggered: mainItem.scale = (mainItem.scale<=2.9)?(mainItem.scale + 0.1):3.0
                    }
                    MenuSeparator {}
                    MenuItem {
                        text: qsTr('Ajusta a l\'amplada')
                        onTriggered: mainItem.scale = editArea.width / mainItem.width
                    }
                    MenuItem {
                        text: qsTr('Ajusta a l\'alçada')
                        onTriggered: mainItem.scale = editArea.height / mainItem.height
                    }
                }
            }

            Button {
                id: smoothnessButton
                text: qsTr('Suavitzat')
                checkable: true
            }
        }

        Flickable {
            id: editArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            contentWidth: mainItem.width
            contentHeight: mainItem.height
            topMargin: contentHeight * (mainItem.scale-1) / 2
            bottomMargin: contentHeight * (mainItem.scale-1) / 2
            leftMargin: contentWidth * (mainItem.scale-1) / 2
            rightMargin: contentWidth * (mainItem.scale-1) / 2

            Rectangle {
                id: mainItem
                height: units.fingerUnit
                width: units.fingerUnit
                color: 'white'
                property real perfectScale: 1
                transformOrigin: Item.Center

                onScaleChanged: {
                    image.sourceSize.height = mainItem.height * scale;
                    image.sourceSize.width = mainItem.width * scale;
                }

                Image {
                    id: image
                    anchors.fill: parent
                    source: background
                    cache: false

                    Text {
                        anchors.fill: parent
                        text: qsTr('Hola què tal?')
                    }
                    Component.onCompleted: {
                        mainItem.height = image.sourceSize.height;
                        mainItem.width = image.sourceSize.width;
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log(mouse.x + '-' + mouse.y);
                    }
                }
            }
        }
    }
}
