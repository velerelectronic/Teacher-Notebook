import QtQuick 2.7
import 'qrc:///common' as Common

Item {
    id: editableTextBaseItem

    property string text: ''
    property bool editable: true
    property bool hasChanged: false

    signal textChangeAccepted(string text)
    signal editorClosed()

    property string fontColor: 'black'
    property bool fontBold: false
    property int padding: 0

    property int requiredHeight
    height: requiredHeight

    states: [
        State {
            name: 'text'
            PropertyChanges {
                target: baseText
                visible: true
            }
            PropertyChanges {
                target: textEditor
                visible: false
            }
            PropertyChanges {
                target: editableTextBaseItem
                requiredHeight: Math.max(baseText.contentHeight, units.fingerUnit * 1.5)
            }
        },
        State {
            name: 'editor'
            PropertyChanges {
                target: baseText
                visible: false
            }
            PropertyChanges {
                target: textEditor
                visible: true
            }
            PropertyChanges {
                target: editableTextBaseItem
                requiredHeight: Math.max(textEditor.requiredHeight, units.fingerUnit * 2)
            }
        }
    ]

    state: 'text'

    Common.UseUnits {
        id: units
    }
    Text {
        id: baseText

        anchors.fill: parent
        padding: editableTextBaseItem.padding
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        font.pixelSize: units.readUnit
        font.bold: fontBold
        color: fontColor
        text: editableTextBaseItem.text
    }
    MouseArea {
        anchors.fill: parent
        enabled: editable
        onClicked: activateEditor()
    }

    Common.TextAreaEditor {
        id: textEditor

        anchors.fill: parent
        enabled: visible

        onAccepted: {
            editableTextBaseItem.text = textEditor.text;
            editableTextBaseItem.state = 'text';
            textChangeAccepted(textEditor.text);
            editorClosed();
        }
        onCancelled: {
            editableTextBaseItem.state = 'text';
            editorClosed();
        }
    }

    function pasteClipboard() {
        textEditor.pasteClipboard();
    }

    function activateEditor() {
        textEditor.text = baseText.text;
        editableTextBaseItem.state = 'editor';
    }
}
