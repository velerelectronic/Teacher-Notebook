import QtQuick 2.2

Rectangle {
    id: editor
    color: 'white'
    property var dataModel

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: titleText.height
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        Rectangle {
            width: editor.width
            height: childrenRect.height

            Text {
                id: titleText
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: units.nailUnit
                height: contentHeight

                text: editor.dataModel
                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
        }

    }
}
