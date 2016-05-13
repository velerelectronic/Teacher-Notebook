import QtQuick 2.5
import QtQuick.Layouts 1.1

Rectangle {
    default property alias items: basicAreaItem.children

    property int areaHeight: basicAreaItem.childrenRect.height
    property int requiredHeight: basicAreaText.height + areaHeight + padding * 3
    property int padding

    height: requiredHeight

    property string caption
    property int captionSize

    objectName: 'BasicSection'

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: padding
        spacing: padding

        Text {
            id: basicAreaText

            Layout.preferredHeight: contentHeight
            Layout.fillWidth: true

            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: captionSize
            font.bold: true
            text: caption
        }

        Item {
            id: basicAreaItem

            Layout.fillHeight: true
            Layout.fillWidth: true
        }

    }

}
