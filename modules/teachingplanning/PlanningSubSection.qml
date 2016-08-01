import QtQuick 2.2

Rectangle {
    color: 'white'
    height: childrenRect.height  + 2 * units.nailUnit
    property string title: ''
    default property alias subObjects: widgetsModel.children

    Text {
        id: titleText
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: units.nailUnit
        height: contentHeight
        font.pixelSize: units.readUnit
        color: 'green'
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        text: title
    }

    ListView {
        id: mainItem
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: titleText.bottom
        height: contentItem.height
        model: widgetsModel
        interactive: false
    }

    VisualItemModel {
        id: widgetsModel
    }
}
