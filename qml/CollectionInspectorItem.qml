import QtQuick 2.5
import QtQuick.Layouts 1.1
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
        }
    ]
    state: 'viewMode'

    property var view: ListView.view
    property alias caption: captionText.text
    property real totalHeight

    property real requiredVisorHeight: (typeof mainVisor.item.requiredHeight === 'number')?mainVisor.item.requiredHeight:units.fingerUnit
    property real requiredEditorHeight: ((mainEditor.item !== null) && (typeof mainEditor.item.requiredHeight === 'number'))?mainEditor.item.requiredHeight:0

    property alias visorComponent: mainVisor.sourceComponent
    property alias editorComponent: mainEditor.sourceComponent

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

    height: captionHeight + totalHeight + units.nailUnit + editorItemLayout.anchors.margins * 2

    Behavior on height {
        PropertyAnimation {
            duration: 200
        }
    }

    signal editModeEntered
    signal viewModeEntered

    function enableShowMode() {
        mainVisor.item.shownContent = mainEditor.item.editedContent;
        editedContent = mainEditor.item.editedContent;
        collectionInspectorItem.state = 'viewMode';
        viewModeEntered();
    }

    function enableEditMode() {
        mainEditor.item.editedContent = mainVisor.item.shownContent;
        collectionInspectorItem.state = 'editMode';
        editModeEntered();
    }

    function showEditedContent(newContent) {
        mainVisor.item.shownContent = newContent;
        mainEditor.item.editedContent = newContent;
    }

    MouseArea {
        anchors.fill: parent
        enabled: (mainEditor.sourceComponent !== null) || (enableSendClick)
        onClicked: {
            if (enableSendClick) {
                sendClick();
            }

            if (mainEditor.sourceComponent !== null) {
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

    GridLayout {
        id: editorItemLayout
        anchors.fill: parent
        anchors.margins: units.nailUnit
        columns: 2
        rows: 2
        columnSpacing: units.nailUnit
        rowSpacing: units.nailUnit
        clip: true

        Text {
            id: captionText
            Layout.preferredHeight: contentHeight
            Layout.fillWidth: true
            Layout.columnSpan: 2
            font.pixelSize: units.readUnit
            font.bold: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Rectangle {
            Layout.preferredHeight: totalHeight
            Layout.preferredWidth: units.fingerUnit
            color: (mainEditor.status == Loader.Null)?'transparent':((collectionInspectorItem.state === 'viewMode')?'#FAAC58':'#FFFF00')

            MouseArea {
                anchors.fill: parent
                enabled: collectionInspectorItem.state == 'editMode'
                onClicked: enableShowMode()
            }
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
