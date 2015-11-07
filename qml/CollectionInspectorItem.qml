import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.2
import QtQml.Models 2.2

import 'qrc:///common' as Common

Common.AbstractEditor {
    id: collectionInspectorItem
    objectName: 'collectionInspectorItem'
    color: 'white'

    property alias captionHeight: captionText.height
    signal saveContents()

    property int totalCollectionHeight: 0

    states: [
        State {
            name: 'viewMode'
            PropertyChanges {
                target: collectionInspectorItem
                totalHeight: requiredVisorHeight
            }
            PropertyChanges {
                target: mainVisor
                opacity: 1
                enabled: true
            }

            PropertyChanges {
                target: mainEditor
                opacity: 0
                enabled: false
            }
            PropertyChanges {
                target: editorItemLayout
                visible: true
                enabled: true
            }
        },
        State {
            name: 'editMode'
            PropertyChanges {
                target: collectionInspectorItem
                totalHeight: requiredEditorHeight
            }
            PropertyChanges {
                target: mainVisor
                opacity: 0
                enabled: false
            }
            PropertyChanges {
                target: mainEditor
                opacity: 1
                enabled: true
            }
            PropertyChanges {
                target: editorItemLayout
                visible: false
                enabled: false
            }
        }
    ]
    state: (ListView.isCurrentItem)?'editMode':'viewMode'

    Component.onCompleted: console.log('This index', collectionInspectorItem.index)

    property ListView view: ListView.view
    property int index: ObjectModel.index

    property alias caption: captionText.text
    property real totalHeight
    property real maximumHeight: totalHeight

    property real requiredVisorHeight: (typeof mainVisor.item.requiredHeight === 'number')?mainVisor.item.requiredHeight:units.fingerUnit
    property real requiredEditorHeight: totalCollectionHeight // units.fingerUnit + (((mainEditorLoader.item !== null) && (typeof mainEditorLoader.item.requiredHeight == 'number'))?mainEditorLoader.item.requiredHeight:0)

    property alias visorComponent: mainVisor.sourceComponent
    property Component editorComponent: null

    property var originalContent

    property bool enableSendClick: false

    signal sendClick

    function sendOriginalContentToVisor() {
        if (mainVisor.status == Loader.Ready) {
            console.log("collection inspector item " + typeof originalContent);
            mainVisor.item.shownContent = originalContent;
        }
    }

    onOriginalContentChanged: {
        sendOriginalContentToVisor();
    }

    property var editedContent: originalContent

    height: captionHeight + totalHeight + units.nailUnit + editorItemRectangle.anchors.margins * 2 + editorItemLayout.anchors.margins * 2

    Behavior on height {
        PropertyAnimation {
            duration: 200
        }
    }

    signal editModeEntered
    signal viewModeEntered

    function openEditMode() {
        console.log('Current index', view.currentIndex);
        if (view.currentIndex < 0) {
            mainEditorLoader.sourceComponent = editorComponent;
            editedContent = originalContent;
            view.currentIndex = collectionInspectorItem.index;
            editModeEntered();
        }
    }

    function openViewMode() {
        mainEditorLoader.sourceComponent = null; // <-------
        view.currentIndex = -1;
    }

    function askDiscardChanges() {
        if (state == 'editMode') {
            if (mainVisor.item.shownContent !== mainEditorLoader.item.editedContent)
                askDiscardDialog.open();
            else
                discardChanges();
        }
    }

    function openMenu(initialHeight, menu) {
        view.openMenuFunction(initialHeight, menu);
    }

    MessageDialog {
        id: askDiscardDialog
        title: qsTr('Descartar els canvis?')
        text: title
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: discardChanges()
    }

    function saveChanges() {
        editedContent = mainEditorLoader.item.editedContent;
        collectionInspectorItem.saveContents();
    }

    function notifySavedContents() {
        mainVisor.item.shownContent = editedContent;
        view.currentIndex = -1;
    }

    function discardChanges() {
        mainEditorLoader.sourceComponent = null;
        openViewMode();
    }

    function enableShowMode() {
        mainVisor.item.shownContent = mainEditorLoader.item.editedContent;
        editedContent = mainEditorLoader.item.editedContent;
        viewModeEntered();
    }

    function enableEditMode() {
        view.currentIndex = collectionInspectorItem.index;
        mainEditorLoader.item.editedContent = mainVisor.item.shownContent;
    }

    function showEditedContent(newContent) {
        mainVisor.item.shownContent = newContent;
        mainEditorLoader.item.editedContent = newContent;
    }

    MouseArea {
        anchors.fill: parent
        enabled: (collectionInspectorItem.editorComponent !== null) || (enableSendClick)
        onClicked: {
            if (enableSendClick) {
                sendClick();
            }

            if (mainEditorLoader.sourceComponent !== null) {
                console.log('open view mode');
                openViewMode();
            } else {
                console.log('open edit mode');
                openEditMode();
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: collectionInspectorItem.state == 'editMode'
        propagateComposedEvents: false
        onPressed: mouse.accepted = true
    }

    Rectangle {
        id: editorItemRectangle
        anchors.fill: parent
        anchors.margins: units.nailUnit

        GridLayout {
            id: editorItemLayout
            anchors.fill: parent
            anchors.margins: units.nailUnit
            columns: 2
            rows: 2
            flow: GridLayout.TopToBottom
            columnSpacing: units.nailUnit
            rowSpacing: units.nailUnit
            clip: true

            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: units.fingerUnit
                Layout.rowSpan: 2
                color: (editorComponent === null)?'#DDDDDD':((collectionInspectorItem.state === 'viewMode')?'#FAAC58':'#FFFF00')

                ColumnLayout {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }

                    spacing: units.nailUnit
                    enabled: collectionInspectorItem.state == 'editMode'
                    visible: enabled

                }

                /*
                MouseArea {
                    anchors.fill: parent
                    enabled: collectionInspectorItem.state == 'editMode'
                    onClicked: enableShowMode()
                }
                */
            }

            Text {
                id: captionText
                Layout.preferredHeight: contentHeight
                Layout.fillWidth: true
                font.pixelSize: units.readUnit
                font.bold: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: totalHeight

                Loader {
                    id: mainVisor
                    anchors.fill: parent
                    onLoaded: {
                        sendOriginalContentToVisor();
                    }
                }
            }

        }
        ColumnLayout {
            id: mainEditor
            anchors.fill: parent
            spacing: units.nailUnit

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: units.fingerUnit * 1.5
                color: 'yellow'

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 0
                    spacing: units.nailUnit

                    Common.ImageButton {
                        Layout.preferredWidth: units.fingerUnit
                        Layout.fillHeight: true
                        image: 'floppy-35952'
                        onClicked: saveChanges()
                    }

                    Common.ImageButton {
                        Layout.preferredWidth: units.fingerUnit
                        Layout.fillHeight: true
                        image: 'road-sign-147409'
                        onClicked: discardChanges()
                    }
                }
            }

            Loader {
                id: mainEditorLoader
                Layout.fillWidth: true
                Layout.fillHeight: true

                Behavior on opacity {
                    NumberAnimation {
                        duration: 100
                    }
                }

                sourceComponent: null

                onLoaded: {
                    if (typeof originalContent !== 'undefined') {
                        item.editedContent = editedContent;
                    }
                }
            }

        }
    }
}
