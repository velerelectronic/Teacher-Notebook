import QtQuick 2.2
import PersonalTypes 1.0
import QtQuick.Controls 1.1

Rectangle {
    id: editor
    height: llista.height

    property alias dataModel: llista.model
    property bool editable: false

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
            editable: editor.editable
            onUpdatedTitle: llista.model.updateObject(model.index,newtitle);
            onEraseContent: llista.model.removeObject(model.index);
        }

        footer: Item {
            visible: editor.editable
            width: llista.width
            height: units.fingerUnit * 1.5
            Button {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: units.nailUnit
                text: qsTr('Afegeix')
                onClicked: llista.model.insertObject(llista.model.count,qsTr('Nou element'));
            }
        }
    }
}
