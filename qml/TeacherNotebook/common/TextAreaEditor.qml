import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import '../common' as Common

Rectangle {
    id: textAreaEditor
    property int fontPixelSize: 0
    property alias wrapMode: textArea.wrapMode
    property int toolHeight: 100
    property alias text: textArea.text
    property bool selection: false

    ToolBar {
        id: toolbar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: toolHeight

        RowLayout {
            anchors.fill: parent.fill
            ToolButton {
                text: qsTr('Predictive')
                checkable: true
                onClicked: textArea.inputMethodHints = (checked)?Qt.ImhNone:Qt.ImhNoPredictiveText
            }
            ToolButton {
                id: undoButton
                text: qsTr('Desfer')
                onClicked: textArea.undo()
                enabled: textArea.canUndo
            }
            ToolButton {
                id: redoButton
                text: qsTr('Refer')
                onClicked: textArea.redo()
                enabled: textArea.canRedo
            }

            ToolButton {
                id: copyButton
                visible: false
                text: qsTr('Copia')
                onClicked: textArea.copy()
                Action {
                    shortcut: 'Ctrl+C'
                }
            }
            ToolButton {
                id: cutButton
                visible: false
                text: qsTr('Retalla')
                onClicked: textArea.cut()
                Action {
                    shortcut: 'Ctrl+X'
                }
            }
            ToolButton {
                id: pasteButton
                visible: false
                text: qsTr('Enganxa')
                onClicked: textArea.paste()
                Action {
                    shortcut: "Ctrl+V"
                }
            }
            ToolButton {
                id: deleteButton
                visible: false
                text: qsTr('Esborra')
                onClicked: textArea.remove(textArea.selectionStart,textArea.selectionEnd)
            }
        }
    }

    TextArea {
        id: textArea
        anchors.top: toolbar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        clip: true
        inputMethodHints: Qt.ImhNoPredictiveText
        font.pixelSize: fontPixelSize

        onSelectedTextChanged: {
            if (selectedText != '') {
                copyButton.visible = true;
                cutButton.visible = true;
                pasteButton.visible = false;
                deleteButton.visible = true;
            } else {
                copyButton.visible = false;
                cutButton.visible = false;
                pasteButton.visible = true;
                deleteButton.visible = false;
            }
        }
    }

}
