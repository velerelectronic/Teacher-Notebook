import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.1
import 'qrc:///common' as Common


Common.AbstractEditor {
    id: collectionInspector

    property string pageTitle: qsTr('Abstract Collection Inspector')
    property alias pageBackground: backgroundImage.source
    property alias model: inspectorGrid.model

    property alias buttons: buttonsModel

    signal saveDataRequested
    signal copyDataRequested
    signal discardDataRequested(bool changes)
    signal closePageRequested()

    color: '#5FB404'

    ListModel {
        id: buttonsModel

        Component.onCompleted: {
            append({image: 'floppy-35952', method: 'saveItem', title: qsTr('Desa els canvis')});
            append({image: 'road-sign-147409', method: 'closeItem', title: qsTr('Tanca sense desar els canvis')});
            append({image: 'clone-153447', method: 'duplicateItem', title: qsTr('Fes un duplicat de les dades')});
        }
    }

    function saveItem() {
        collapseEditors();
        messageSave.open();
    }

    function closeItem() {
        collapseEditors();
        if (collectionInspector.changes)
            messageDiscard.open();
        else
            closePageRequested();
    }

    function duplicateItem() {
        collapseEditors();
        messageCopy.open();
    }

    Image {
        id: backgroundImage
        anchors.fill: parent
    }

    ListView {
        id: inspectorGrid
        anchors.fill: parent
        anchors.margins: units.nailUnit
        clip: true

        property int captionsWidth: units.fingerUnit

        spacing: units.nailUnit

        model: VisualItemModel { }

        function requestShowMode() {
            collapseEditors();
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: false
        propagateComposedEvents: true
        onClicked: {
            console.log('Collapsing');
            collapseEditors();
//            mouse.accepted = false;
//            mouse.accepted = false;
        }
    }

    MessageDialog {
        id: messageSave
        title: qsTr('Desar canvis');
        text: qsTr('Es desaran els canvis. Vols continuar?')
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: collectionInspector.saveDataRequested()
    }
    MessageDialog {
        id: messageDiscard
        title: qsTr('Descartar canvis');
        text: qsTr('Es descartaran els canvis. N\'estàs segur?')
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: {
            var changes = collectionInspector.changes;
            collectionInspector.setChanges(false);
            collectionInspector.discardDataRequested(changes);
        }
    }
    MessageDialog {
        id: messageCopy
        title: qsTr('Duplicar');
        text: qsTr('Es duplicaran totes les dades a un nou element. Vols continuar?')
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: collectionInspector.copyDataRequested();
    }

    function collapseEditors() {
        Qt.inputMethod.hide();
        for (var i=0; i<inspectorGrid.contentItem.children.length; i++) {
            var widget = inspectorGrid.contentItem.children[i];
            console.log(widget.objectName);
            if (widget.objectName === 'collectionInspectorItem') {
                if (widget.state === 'editMode')
                    widget.enableShowMode();
            }
        }
    }

    function coalesce(value1,value2) {
        return (typeof value1 !== 'undefined')?value1:value2;
    }
}
