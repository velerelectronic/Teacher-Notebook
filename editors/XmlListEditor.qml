import QtQuick 2.2
import PersonalTypes 1.0
import QtQuick.Controls 1.1
import 'qrc:///common' as Common

Common.AbstractEditor {
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
        clip: true

        delegate: XmlTextEditor {
            width: llista.width
            title: model.display
            editable: editor.editable
            onUpdatedTitle: {
                llista.model.updateObject(model.index,newtitle);
                editor.setChanges(true);
            }
            onEraseContent: {
                llista.model.removeObject(model.index);
                editor.setChanges(true);
            }
            onMoveToPrevious: {
                llista.model.moveToPrevious(model.index);
                editor.setChanges(true);
            }
            onMoveToNext: {
                llista.model.moveToNext(model.index);
                editor.setChanges(true);
            }
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
                onClicked: {
                    llista.model.insertObject(llista.model.count,qsTr('Nou element'));
                    setChanges(true);
                }
            }
        }
    }
}
