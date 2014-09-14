import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

Common.AbstractEditor {
    id: gridViewer
    property string pageTitle: qsTr('Graella');
    property string document
    property alias buttons: buttonsModel

    property bool editMode: false

    Common.UseUnits { id: units }

    function saveChanges() {
        messageSave.open();
    }

    function toggleEditMode() {
        editMode = !editMode;
    }

    function duplicateItem() {
        messageCopy.open();
    }

    function discardChanges() {

    }

    ListModel {
        id: buttonsModel

        Component.onCompleted: {
            buttonsModel.append({method: 'saveChanges', image: 'floppy-35952', enabled: gridViewer.changes});
            buttonsModel.append({method: 'toggleEditMode', image: 'edit-153612', checkable: true});
            buttonsModel.append({method: 'duplicateItem', image: 'clone-153447'});
            buttonsModel.append({method: 'discardChanges', image: 'road-sign-147409', enabled: gridViewer.changes});
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: units.nailUnit

        RowLayout {
            Layout.preferredHeight: units.fingerUnit
            Layout.fillWidth: true
            Button {
                text: qsTr('Nova variable')
            }
        }
        TableView {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

}
