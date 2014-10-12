import QtQuick 2.3
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

Item {
    property alias model: labelList.model
    property var field
    property alias text: textField.text

    height: groupColumn.height // groupField.height + labelList.height

    Common.UseUnits {
        id: units
    }

    ColumnLayout {
        id: groupColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: units.nailUnit

        Item {
            id: groupField
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit
            RowLayout {
                anchors.fill: parent
                TextField {
                    id: textField
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
                Button {
                    id: emptyButton
                    Layout.fillHeight: true
                    text: qsTr('Buida')
                    onClicked: textField.text = ''
                }
            }
        }

        ListView {
            id: labelList
            Layout.preferredHeight: units.fingerUnit
            Layout.fillWidth: true
            orientation: ListView.Horizontal
            clip: true
            spacing: units.nailUnit

            delegate: Rectangle {
                height: labelList.height
                width: labelText.contentWidth + 2 * radius
                border.color: 'green'
                color: 'yellow'
                radius: height / 2
                Text {
                    id: labelText
                    anchors.fill: parent
                    anchors.leftMargin: parent.radius
                    anchors.rightMargin: parent.radius
                    font.pixelSize: units.readUnit
                    verticalAlignment: Text.AlignVCenter
                    text: modelData
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: textField.text = modelData
                }
            }
        }
    }

}

