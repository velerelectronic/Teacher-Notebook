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

Common.AbstractEditor {
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

    property alias content: textArea.text

    height: units.fingerUnit * 4

    border.color: 'black'

    Common.UseUnits { id: units }

    Flickable {
        id: flick

        anchors {
            fill: parent
            margins: units.nailUnit
        }

        flickableDirection: Flickable.VerticalFlick
        contentWidth: flick.width
        contentHeight: textArea.paintedHeight + flick.height
        clip: true

        function ensureVisible(r)
        {
            if (contentX >= r.x)
                contentX = r.x;
            else if (contentX+width <= r.x+r.width)
                contentX = r.x+r.width-width;
            if (contentY >= r.y)
                contentY = r.y;
            else if (contentY+height <= r.y+r.height)
                contentY = r.y+r.height-height;
        }

        TextEdit {
            id: textArea
            width: flick.width
            height: paintedHeight + flick.height
            activeFocusOnPress: false
            wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
            onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
            font.pixelSize: fontPixelSize

            onSelectedTextChanged: enableButtons()
            onTextChanged: {
                textAreaEditor.setChanges(true);
            }

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

            cursorDelegate: Rectangle {
                color: 'green'
                width: 2
                height: textArea.cursorRectangle.height
                Rectangle {
                    anchors {
                        topMargin: units.nailUnit * 2
                        top: parent.bottom
                        horizontalCenterOffset: {
                            var leftOffset = width/2 - parent.x;
                            if (leftOffset>0) {
                                return leftOffset;
                            } else {
                                var rightOffset = parent.parent.width - parent.x - width/2;
                                if (rightOffset < 0) {
                                    return rightOffset;
                                } else
                                    return 0;
                            }
                        }
                        horizontalCenter: parent.horizontalCenter
                    }
                    height: buttonsList.height
                    color: '#ccffcc'
                    width: buttonsList.width
                    ListView {
                        id: buttonsList
                        width: contentItem.width
                        height: contentItem.height
                        model: editButtonsModel
                        orientation: ListView.Horizontal
                        spacing: buttonMargins
                    }
                }
            }

            MouseArea {
                property bool inGesture: false
                property int firstCursorPosition
                property int firstX
                property int firstY
                property bool horizontalSwipe: false

                propagateComposedEvents: false

                anchors.fill: parent

                onClicked: {
                    inGesture = false;
                    // Single click
                    if (textArea.selectedText == "") {
                        console.log('Clicked at ' + mouse.x + '-' + mouse.y);
                        textArea.cursorPosition = textArea.positionAt(mouse.x, mouse.y);
                        textArea.forceActiveFocus();
                        Qt.inputMethod.show();
                    }
                }

                onPressed: {
                    inGesture = true;
                    firstX = mouse.x;
                    firstY = mouse.y;
                    firstCursorPosition = textArea.cursorPosition;
                }
                onMouseXChanged: {
                    if (inGesture) {
                        var advance = (mouse.x - firstX) / (2 * units.fingerUnit);
                        var newPos = 0;
                        if (advance > 1) {
                            newPos = 1;
                        } else if (advance < -1) {
                            newPos = -1;
                        }

                        if (newPos != 0) {
                            horizontalSwipe = true;
                            firstX = mouse.x;
                            console.log(newPos);
                            if (textArea.selectionEnd>textArea.selectionStart) {
                                textArea.select(textArea.selectionStart,textArea.selectionEnd + newPos);
                            } else {
                                textArea.cursorPosition = textArea.cursorPosition + newPos;
                            }
                        }
                    }
                }

                onReleased: {
                    inGesture = false;
                    if (horizontalSwipe) {
                        horizontalSwipe = false;
                    }
                }
            }

            Component.onCompleted: enableButtons()
        }
    }

    MouseArea {
        anchors.fill: flick
        onClicked: {
            textArea.forceActiveFocus();
            Qt.inputMethod.show();
            textArea.cursorPosition = textArea.length;
            enabled = false;
        }
    }

    ObjectModel {
        id: editButtonsModel

        Common.Button {
            id: undoButton
            width: (visible)?(units.fingerUnit * 1.5):0
            height: units.fingerUnit * 1.5
            color: 'white'
            visible: textArea.canUndo

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
            width: (visible)?(units.fingerUnit * 1.5):0
            height: units.fingerUnit * 1.5
            color: 'white'
            visible: textArea.canRedo
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
            width: (visible)?(units.fingerUnit * 1.5):0
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
            width: (visible)?(units.fingerUnit * 1.5):0
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
            width: (visible)?(units.fingerUnit * 1.5):0
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
            width: (visible)?(units.fingerUnit * 1.5):0
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
            id: selectButton
            width: units.fingerUnit * 1.5
            height: units.fingerUnit * 1.5
            color: 'white'
            Image {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                source: '../icons/screen-capture-23236.svg'
                fillMode: Image.PreserveAspectFit
            }
            onClicked: {
                if (textArea.selectedText == "") {
                    if (textArea.focus) {
                        textArea.selectWord();
                    }
                } else {
                    textArea.deselect();
                }
            }
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
            onClicked: {
                if (textArea.selectionEnd==textArea.selectionStart) {
                    textArea.selectAll();
                } else
                    textArea.select(textArea.selectionStart,textArea.selectionEnd-1);
            }
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
            onClicked: textArea.select(textArea.selectionStart,textArea.selectionEnd+1)
        }
    }
}
