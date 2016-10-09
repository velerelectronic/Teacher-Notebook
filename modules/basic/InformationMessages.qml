import QtQuick 2.7
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

ListView {
    id: informationMessages

    height: contentItem.height

    Common.UseUnits {
        id: units
    }

    model: ListModel {
        id: messagesModel
    }

    LayoutMirroring.enabled: true

    verticalLayoutDirection: ListView.BottomToTop

    delegate: Rectangle {
        id: singleMessage

        width: informationMessages.width
        height: Math.max(crossText.height, mainText.height, units.fingerUnit) + 2 * units.nailUnit
        color: 'gray'
        RowLayout {
            anchors.fill: parent
            anchors.margins: units.nailUnit
            spacing: units.nailUnit

            Text {
                id: crossText

                Layout.preferredHeight: contentHeight
                Layout.preferredWidth: contentWidth
                font.pixelSize: units.glanceUnit
                verticalAlignment: Text.AlignVCenter
                color: 'white'
                text: 'X'
                MouseArea {
                    anchors.fill: parent
                    onClicked: singleMessage.removeMessage()
                }
            }

            Text {
                id: mainText

                Layout.preferredHeight: contentHeight
                Layout.fillWidth: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: units.readUnit
                color: 'white'
                verticalAlignment: Text.AlignVCenter
                text: model.text
                MouseArea {
                    anchors.fill: parent
                    onClicked: messageTimer.stop()
                }
            }
        }

        Timer {
            id: messageTimer

            interval: 5000
            running: true
            onTriggered: singleMessage.removeMessage()
        }

        function removeMessage() {
            messagesModel.remove(model.index);
        }
    }

    function publishMessage(message) {
        messagesModel.append({text: message});
    }

}
