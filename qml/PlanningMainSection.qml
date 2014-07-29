import QtQuick 2.2

Rectangle {
    color: 'white'
    property alias title: textTtitle.text
    default property alias subObjects: widgetsModel.children

    Rectangle {
        id: titleText
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: childrenRect.height + 2 * units.nailUnit
        color: 'green'

        Text {
            id: textTtitle
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: contentHeight
            anchors.margins: units.nailUnit
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: 'white'
            font.pixelSize: units.readUnit
        }
    }
    ListView {
        id: mainItem
        anchors.top: titleText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true
        model: widgetsModel
    }
    VisualItemModel {
        id: widgetsModel
    }
}
