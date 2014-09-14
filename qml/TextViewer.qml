import QtQuick 2.3
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.1
import FileIO 1.0
import 'qrc:///editors' as Editors
import 'qrc:///common' as Common

Common.AbstractEditor {
    id: textViewer
    property string pageTitle: qsTr('Visor de text');
    property string document: ''
    property alias buttons: buttonsModel

    property bool editable: false

    onEditableChanged: {
        if (editable)
            textEditor.text = mainText.text;
    }

    signal savedDocument(string document)

    Common.UseUnits { id: units }

    ListModel {
        id: buttonsModel

        Component.onCompleted: {
            buttonsModel.append({method: 'saveChanges', image: 'floppy-35952', enabled: textViewer.changes});
            buttonsModel.append({method: 'toggleEditMode', image: 'edit-153612', checkable: true});
            buttonsModel.append({method: 'duplicateItem', image: 'clone-153447'});
            buttonsModel.append({method: 'discardChanges', image: 'road-sign-147409', enabled: textViewer.changes});
        }
    }

    function toggleEditMode() {
        editable = !editable;
    }

    function saveChanges() {
        if (changes) {
            applyChanges.open();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        Text {
            id: mainText
            Layout.fillHeight: true
            Layout.fillWidth: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
        Common.TextAreaEditor {
            id: textEditor
            Layout.fillWidth: true
            Layout.preferredHeight: (editable)?(parent.height/2):0
            onTextChanged: {
                mainText.text = textEditor.text;
                textViewer.setChanges(true);
            }
        }

        Component.onCompleted: {
            mainText.text = fileio.read();
        }
    }

    FileIO {
        id: fileio
        source: document
    }

    MessageDialog {
        id: applyChanges
        title: qsTr('Canvis')
        text: qsTr('Els canvis es desaran dins «' + document + '». Vols continuar?')
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: {
            fileio.write(mainText.text);
            textViewer.setChanges(false);
            savedDocument(document);
        }
    }
}
