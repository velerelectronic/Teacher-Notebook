import QtQuick 2.2

Rectangle {
    id: editor
    property var dataModel

    color: 'pink'

    ListView {
        id: llista
        anchors.fill: parent
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        model: editor.dataModel
        delegate: XmlListTextEditor {
            width: parent.width
            title: model.text
        }
    }

}
