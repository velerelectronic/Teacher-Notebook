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

    signal editorCompletelyOpened()

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
            PropertyChanges {
                target: mainEditorLoader
                sourceComponent: undefined
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
            PropertyChanges {
                target: mainEditorLoader
                sourceComponent: editorComponent
            }
        }
    ]
    state: (ListView.isCurrentItem)?'editMode':'viewMode'

    Component.onCompleted: console.log('This index', collectionInspectorItem.index)

    property ListView view: ListView.view
    property int index: ObjectModel.index

    property var identifier

    property alias caption: captionText.text
    property real totalHeight
    property real maximumHeight: totalHeight

    property real requiredVisorHeight: (typeof mainVisor.item.requiredHeight === 'number')?mainVisor.item.requiredHeight:units.fingerUnit
    property real requiredEditorHeight: totalCollectionHeight

    property alias visorComponent: mainVisor.sourceComponent
    property Component editorComponent: null

    property var originalContent //: mainVisor.item.shownContent

    property bool enableSendClick: false

    signal sendClick

    function sendOriginalContentToVisor() {
        if (mainVisor.status == Loader.Ready) {
            console.log("collection inspector item " + typeof originalContent);
            if (typeof (mainVisor.item.shownContent) !== 'undefined')
                mainVisor.item.shownContent = originalContent;
        }
    }

    onOriginalContentChanged: {
        sendOriginalContentToVisor();
    }

    signal saveContents()

    height: captionHeight + totalHeight + units.nailUnit + editorItemRectangle.anchors.margins * 2 + editorItemLayout.anchors.margins * 2

    Behavior on height {
        SequentialAnimation {
            PropertyAnimation {
                duration: 200
            }
            ScriptAction {
                script: {
                    collectionInspectorItem.editorCompletelyOpened();
                    view.editorCompletelyOpened(index);
                }
            }
        }
    }

    signal editModeEntered
    signal viewModeEntered

    function openEditMode() {
        if (view.currentIndex < 0) {
            view.currentIndex = collectionInspectorItem.index;
            editModeEntered();
        }
    }

    function askDiscardChanges() {
        if (state == 'editMode') {
            if (originalContent !== mainEditorLoader.item.editedContent)
                askDiscardDialog.open();
            else
                view.discardChanges();
        }
    }

    function openMenu(initialHeight, menu, options) {
        view.openMenuFunction(initialHeight, menu, options);
    }

    MessageDialog {
        id: askDiscardDialog
        title: qsTr('Descartar els canvis?')
        text: title
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: view.discardChanges()
    }

    function acceptChanges() {
        originalContent = mainEditorLoader.item.editedContent;
        collectionInspectorItem.saveContents();
    }

    function notifySavedContents() {
        view.updatedContents();
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
                view.openViewMode();
            } else {
                console.log('open edit mode');
                view.openEditMode(index);
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
                        onClicked: acceptChanges()
                    }

                    Common.ImageButton {
                        Layout.preferredWidth: units.fingerUnit
                        Layout.fillHeight: true
                        image: 'road-sign-147409'
                        onClicked: askDiscardChanges()
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
                    console.log('Loaded editor', originalContent);
                    if (typeof originalContent !== 'undefined') {
                        item.editedContent = originalContent;
                        console.log('Loaded editor 2', item.editedContent);
                    }
                }
            }

        }
    }
}
