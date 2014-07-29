import QtQuick 2.2
import PersonalTypes 1.0
import QtQuick.Controls 1.1

Rectangle {
    id: editor
    height: llista.height

    property alias dataModel: llista.model
    signal updatedList

    ListView {
        id: llista
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: contentItem.height
        interactive: false

//        model: editor.dataModel
        delegate: XmlTextEditor {
            width: llista.width
            title: model.display
            onUpdatedTitle: {
                console.log('XmlListEditor: updating title');
                editor.updatedList();
            }
        }

        footer: Item {
            width: parent.width
            height: units.fingerUnit * 1.5
            Button {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: units.nailUnit
                text: qsTr('Afegeix')
            }
        }
    }
}
