/* Licenses

  CC0
  * Predictive: http://pixabay.com/es/cuadro-de-di%C3%A1logo-punta-148815/
  * Undo: http://pixabay.com/es/deshacer-flecha-rehacer-redo-jugar-97591/
  * Redo: http://pixabay.com/es/flecha-hacia-delante-rehacer-redo-97589/
  * Copy: http://pixabay.com/es/copia-documentos-p%C3%A1ginas-97584/
  * Cut: http://pixabay.com/es/tijeras-del-hogar-oficina-corte-147115/
  * Paste: http://pixabay.com/es/portapapeles-bot%C3%B3n-pegar-copia-35946/
  * Delete: http://pixabay.com/es/negro-icono-l%C3%A1piz-contorno-oficina-34105/
*/

import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import '../common' as Common

Rectangle {
    id: textAreaEditor
    property int fontPixelSize: 0
    property alias wrapMode: textArea.wrapMode
    property int toolHeight: 100
    property int buttonMargins: 0
    property alias text: textArea.text
    property bool selection: false
    property bool isVertical: width<height

    Flow {
        id: toolbar
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: (isVertical)?parent.left:parent.horizontalCenter
        anchors.bottom: (isVertical)?parent.verticalCenter:parent.bottom
        anchors.margins: units.nailUnit

        spacing: buttonMargins

        ToolButton {
            anchors.margins: buttonMargins
            width: units.fingerUnit
            height: units.fingerUnit
            checkable: true
            Image {
                anchors.fill: parent
                source: '../icons/dialog-148815_150.png'
                fillMode: Image.PreserveAspectFit
            }
            onClicked: textArea.inputMethodHints = (checked)?Qt.ImhNone:Qt.ImhNoPredictiveText
        }
        ToolButton {
            id: undoButton
            width: units.fingerUnit
            height: units.fingerUnit
            enabled: textArea.canUndo
            Image {
                anchors.fill: parent
                source: '../icons/undo-97591_150.png'
                fillMode: Image.PreserveAspectFit
            }
            onClicked: textArea.undo()
        }
        ToolButton {
            id: redoButton
            width: units.fingerUnit
            height: units.fingerUnit
            enabled: textArea.canRedo
            Image {
                anchors.fill: parent
                source: '../icons/redo-97589_150.png'
                fillMode: Image.PreserveAspectFit
            }
            onClicked: textArea.redo()
        }

        ToolButton {
            id: copyButton
            width: units.fingerUnit
            height: units.fingerUnit
            visible: false
            Image {
                anchors.fill: parent
                source: '../icons/copy-97584_150.png'
                fillMode: Image.PreserveAspectFit
            }
            Action {
                shortcut: 'Ctrl+C'
            }
            onClicked: textArea.copy()
        }
        ToolButton {
            id: cutButton
            width: units.fingerUnit
            height: units.fingerUnit
            visible: false
            Image {
                anchors.fill: parent
                source: '../icons/scissors-147115_150.png'
                fillMode: Image.PreserveAspectFit
            }
            Action {
                shortcut: 'Ctrl+X'
            }
            onClicked: textArea.cut()
        }
        ToolButton {
            id: pasteButton
            width: units.fingerUnit
            height: units.fingerUnit
            visible: false
            Image {
                anchors.fill: parent
                source: '../icons/paste-35946_150.png'
                fillMode: Image.PreserveAspectFit
            }
            Action {
                shortcut: "Ctrl+V"
            }
            onClicked: textArea.paste()
        }
        ToolButton {
            id: deleteButton
            width: units.fingerUnit
            height: units.fingerUnit
            visible: false
            Image {
                anchors.fill: parent
                source: '../icons/erase-34105_150.png'
                fillMode: Image.PreserveAspectFit
            }
            onClicked: textArea.remove(textArea.selectionStart,textArea.selectionEnd)
        }
    }

    TextArea {
        id: textArea
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.top: (isVertical)?parent.verticalCenter:parent.top
        anchors.right: (isVertical)?parent.right:parent.horizontalCenter

        clip: true
//        inputMethodHints: Qt.ImhNoPredictiveText
        font.pixelSize: fontPixelSize

        onSelectedTextChanged: enableButtons()
        onFocusChanged: focus && enableButtons()
        onVisibleChanged: visible && forceActiveFocus()

        function enableButtons() {
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
