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

    property bool embedded: false
    property int requiredHeight: inspectorGrid.contentItem.height
    onRequiredHeightChanged: console.log('collectioninspector required height', requiredHeight)

    signal saveDataRequested
    signal copyDataRequested
    signal discardDataRequested(bool changes)
    signal closePageRequested()
    signal openMenu(int initialHeight, var menu, var options)
    signal updatedContents(var identifier)

    property int totalCollectionHeight: inspectorGrid.height

    property var identifier

    states: [
        State {
            name: 'show'
        },
        State {
            name: 'edit'
        }
    ]

    state: (inspectorGrid.currentIndex>=0)?'edit':'show'

    function saveItem() {
        collapseEditors();
        messageSave.open();
    }

    function closeItem() {
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

        property int captionsWidth: units.fingerUnit

        highlightMoveDuration: 200
        highlightRangeMode: ListView.ApplyRange
        spacing: units.nailUnit

        currentIndex: -1
        interactive: (!embedded) && (currentIndex < 0)

        model: VisualItemModel { id: visualModel }

        function askEnableEditMode(index) {
            currentIndex = index;
            return true;
        }

        function discardChanges() {
            currentIndex = -1;
        }

        function openMenuFunction(initialHeight, menu, options) {
            collectionInspector.openMenu(initialHeight, menu, options);
        }

        function openEditMode(index) {
            if (currentIndex<0) {
                currentIndex = index;
            }
        }

        function openViewMode() {
            currentIndex = -1;
        }


        function updatedContents() {
            console.log('in collection inspector', collectionInspector.identifier);
            openViewMode();
            collectionInspector.updatedContents(collectionInspector.identifier);
        }

        function editorCompletelyOpened(index) {
            positionViewAtIndex(index,ListView.Beginning);
        }

    }

    onModelChanged: {
        for (var i=0; i<model.count; i++) {
            var obj = model.children[i];
            obj.width = Qt.binding(function () { return inspectorGrid.width; });
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


    function coalesce(value1,value2) {
        return (typeof value1 !== 'undefined')?value1:value2;
    }

}
