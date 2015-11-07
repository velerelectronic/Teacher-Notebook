import QtQuick 2.5
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0

CollectionInspectorItem {
    id: deleteItem
    width: annotationEditor.width
    caption: ''

    property bool enableButton: false
    property string buttonCaption: qsTr('Esborrar')
    property string dialogTitle: qsTr('Esborrar')
    property string dialogText: ''
    property SqlTableModel model
    property var itemId: -1
    signal deleted()

    visorComponent: Button {
        property int requiredHeight: units.fingerUnit * 2
        text: buttonCaption
        enabled: deleteItem.enableButton
        onClicked: {
            confirmDeletion.open()
        }
    }

    MessageDialog {
        id: confirmDeletion
        title: deleteItem.dialogTitle
        text: deleteItem.dialogText
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: {
            if (model.removeObject(itemId) > 0)
                deleteItem.deleted();
        }
    }
}
