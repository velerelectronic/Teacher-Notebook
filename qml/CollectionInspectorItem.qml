import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.2

import 'qrc:///common' as Common

Common.AbstractEditor {
    id: collectionInspectorItem
    objectName: 'collectionInspectorItem'
    color: 'white'

    property alias captionHeight: captionText.height

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
                target: glowEffect
                visible: false
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
                sourceComponent: editorComponent
            }
            PropertyChanges {
                target: glowEffect
                visible: true
            }
        }
    ]
    state: 'viewMode'

    property var view: ListView.view
    property alias caption: captionText.text
    property real totalHeight

    property real requiredVisorHeight: (typeof mainVisor.item.requiredHeight === 'number')?mainVisor.item.requiredHeight:units.fingerUnit
    property real requiredEditorHeight: ((mainEditor.item !== null) && (typeof mainEditor.item.requiredHeight === 'number'))?mainEditor.item.requiredHeight:0

    property alias visorComponent: mainVisor.sourceComponent
    property Component editorComponent: null

    property var originalContent

    property bool enableSendClick: false

    signal sendClick

    onOriginalContentChanged: {
        if (mainVisor.status == Loader.Ready) {
            console.log("collection inspector item " + typeof originalContent);
            mainVisor.item.shownContent = originalContent;
        }
        if (mainEditor.status == Loader.Ready) {
            mainEditor.item.editedContent = originalContent;
        }
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

    function askDiscardChanges() {
        if (state == 'editMode') {
            if (mainVisor.item.shownContent !== mainEditor.item.editedContent)
                askDiscardDialog.open();
            else
                discardChanges();
        }
    }

    MessageDialog {
        id: askDiscardDialog
        title: qsTr('Descartar els canvis?')
        text: title
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: discardChanges()
    }

    function discardChanges() {
        collectionInspectorItem.state = 'viewMode';
        mainEditor.sourceComponent = null;
        viewModeEntered();
    }

    function enableShowMode() {
        mainVisor.item.shownContent = mainEditor.item.editedContent;
        editedContent = mainEditor.item.editedContent;
        collectionInspectorItem.state = 'viewMode';
        viewModeEntered();
    }

    function enableEditMode() {
        collectionInspectorItem.state = 'editMode';
        mainEditor.item.editedContent = mainVisor.item.shownContent;
        editModeEntered();
    }

    function showEditedContent(newContent) {
        mainVisor.item.shownContent = newContent;
        mainEditor.item.editedContent = newContent;
    }

    RectangularGlow {
        id: glowEffect
        anchors.fill: editorItemRectangle
        glowRadius: units.nailUnit
        spread: 0.5
        color: 'gray'
    }

    MouseArea {
        anchors.fill: parent
        enabled: (collectionInspectorItem.editorComponent !== null) || (enableSendClick)
        onClicked: {
            if (enableSendClick) {
                sendClick();
            }

            if (editorComponent !== null) {
                if (collectionInspectorItem.state == 'viewMode') {
                    view.requestShowMode();
                    enableEditMode();
                } else {
                    // Do something more
                    enableShowMode();
                }

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

                    Common.ImageButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit
                        image: 'floppy-35952'
                        onClicked: enableShowMode()
                    }

                    Common.ImageButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit
                        image: 'road-sign-147409'
                        onClicked: discardChanges()
                    }
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
                        if (typeof originalContent !== 'undefined') {
                            item.shownContent = originalContent;
                        }
                    }
                }
                Loader {
                    id: mainEditor
                    anchors.fill: parent

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100
                        }
                    }

                    onLoaded: {
                        if (typeof originalContent !== 'undefined') {
                            item.editedContent = originalContent;
                        }
                    }
                }
            }

        }
    }
}
