import QtQuick 2.2
import PersonalTypes 1.0

Rectangle {
    id: editor
    property var dataModel

    color: 'pink'

    Component.onCompleted: {
        console.log('Data model: ' + JSON.stringify(dataModel));
    }

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
