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

import QtQuick 2.3
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQml.Models 2.1

import '../common' as Common

Item {
    id: textAreaEditor
    property int fontPixelSize: units.readUnit
    property alias wrapMode: textArea.wrapMode
    property int toolHeight: 100
    property int buttonMargins: units.nailUnit
    property alias text: textArea.text
    property bool selection: false
    property bool isVertical: width<height
    property bool edit: true
    property var buttons: buttonsModel

    ListView {
        id: toolbar
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        height: units.fingerUnit * 1.5

        clip: true
        //anchors.left: (isVertical)?parent.left:undefined
        //anchors.bottom: (isVertical)?undefined:parent.bottom
        //width: (isVertical)?undefined:(units.fingerUnit*2)
        //height: (isVertical)?(units.fingerUnit*2):undefined
        anchors.margins: units.nailUnit
        //orientation: (isVertical)?ListView.Horizontal:ListView.Vertical
        orientation: ListView.Horizontal

        spacing: buttonMargins

        model: editButtonsModel
    }

    TextArea {
        id: textArea
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.top: toolbar.bottom
        anchors.right: parent.right

        //anchors.top: (isVertical)?toolbar.bottom:parent.top
        //anchors.right: (isVertical)?parent.right:toolbar.left
        anchors.margins: units.nailUnit

        readOnly: !textAreaEditor.edit
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

    ObjectModel {
        id: editButtonsModel

        Common.Button {
            width: units.fingerUnit * 1.5
            height: units.fingerUnit * 1.5
            color: 'white'
            property bool checkable: true
            Image {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                source: '../icons/dialog-148815_150.png'
                fillMode: Image.PreserveAspectFit
            }
            onClicked: textArea.inputMethodHints = (checked)?Qt.ImhNone:Qt.ImhNoPredictiveText
        }

       Common.Button {
           id: undoButton
           width: units.fingerUnit * 1.5
           height: units.fingerUnit * 1.5
           color: 'white'
           enabled: textArea.canUndo

           Image {
               anchors.fill: parent
               anchors.margins: units.nailUnit
               source: '../icons/undo-97591_150.png'
               fillMode: Image.PreserveAspectFit
           }
           onClicked: textArea.undo()
       }

       Common.Button {
           id: redoButton
           width: units.fingerUnit * 1.5
           height: units.fingerUnit * 1.5
           color: 'white'
           enabled: textArea.canRedo
           Image {
               anchors.fill: parent
               anchors.margins: units.nailUnit
               source: '../icons/redo-97589_150.png'
               fillMode: Image.PreserveAspectFit
           }
           onClicked: textArea.redo()
       }

       Common.Button {
           id: copyButton
           width: units.fingerUnit * 1.5
           height: units.fingerUnit * 1.5
           color: 'white'
           visible: false
           Image {
               anchors.fill: parent
               anchors.margins: units.nailUnit
               source: '../icons/copy-97584_150.png'
               fillMode: Image.PreserveAspectFit
           }
           Action {
               shortcut: 'Ctrl+C'
           }
           onClicked: textArea.copy()
       }
       Common.Button {
           id: cutButton
           width: units.fingerUnit * 1.5
           height: units.fingerUnit * 1.5
           color: 'white'
           visible: false
           Image {
               anchors.fill: parent
               anchors.margins: units.nailUnit
               source: '../icons/scissors-147115_150.png'
               fillMode: Image.PreserveAspectFit
           }
           Action {
               shortcut: 'Ctrl+X'
           }
           onClicked: textArea.cut()
       }
       Common.Button {
           id: pasteButton
           width: units.fingerUnit * 1.5
           height: units.fingerUnit * 1.5
           color: 'white'
           visible: false
           Image {
               anchors.fill: parent
               anchors.margins: units.nailUnit
               source: '../icons/paste-35946_150.png'
               fillMode: Image.PreserveAspectFit
           }
           Action {
               shortcut: "Ctrl+V"
           }
           onClicked: textArea.paste()
       }
       Common.Button {
           id: deleteButton
           width: units.fingerUnit * 1.5
           height: units.fingerUnit * 1.5
           color: 'white'
           visible: false
           Image {
               anchors.fill: parent
               anchors.margins: units.nailUnit
               source: '../icons/erase-34105_150.png'
               fillMode: Image.PreserveAspectFit
           }
           onClicked: textArea.remove(textArea.selectionStart,textArea.selectionEnd)
       }
       Common.Button {
           id: goLeft
           width: units.fingerUnit * 1.5
           height: units.fingerUnit * 1.5
           color: 'white'
           Image {
               anchors.fill: parent
               anchors.margins: units.nailUnit
               source: '../icons/arrow-145769.svg'
               fillMode: Image.PreserveAspectFit
           }
           onClicked: textArea.cursorPosition = textArea.cursorPosition - 1
       }
       Common.Button {
           id: goRight
           width: units.fingerUnit * 1.5
           height: units.fingerUnit * 1.5
           color: 'white'
           Image {
               anchors.fill: parent
               anchors.margins: units.nailUnit
               source: '../icons/arrow-145769.svg'
               mirror: true
               fillMode: Image.PreserveAspectFit
           }
           onClicked: textArea.cursorPosition = textArea.cursorPosition + 1
       }
   }
}
