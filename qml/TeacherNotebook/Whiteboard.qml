import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.1
import 'common' as Common

Rectangle {
    id: whiteboard

    property string pageTitle: qsTr('Pissarra')
    property bool canClose: true
    // Possible drawing actions ['Clear', 'Path']
    property string drawingAction: ''
    property string selectedTool: ''

    Common.UseUnits { id: units }

    ColumnLayout {
        anchors.fill:parent

        Rectangle {
            Layout.fillWidth: true;
            Layout.preferredHeight: units.fingerUnit

            RowLayout {
                anchors.fill: parent

                ExclusiveGroup {
                    id: mainTool
                }

                Button {
                    id: moveButton
                    Layout.fillHeight: true
                    text: qsTr('Mou')
                    checkable: true
                    exclusiveGroup: mainTool
                    onCheckedChanged: if (checked) whiteboard.selectedTool = 'move';
                }

                Button {
                    Layout.fillHeight: true
                    text: qsTr('Llapis')
                    checkable: true
                    exclusiveGroup: mainTool
                    onCheckedChanged: if (checked) whiteboard.selectedTool = 'pencil';
                }

                Button {
                    Layout.fillHeight: true
                    text: qsTr('Figura')
                    checkable: true
                    exclusiveGroup: mainTool

                    menu: Menu {
                        title: qsTr('Figura geomètrica')
                        MenuItem {
                            text: qsTr('Rectangle')
                            checkable: true
                            exclusiveGroup: mainTool
                            onTriggered: if (checked) whiteboard.selectedTool = 'rect'
                        }

                        MenuItem {
                            text: qsTr('Cercle')
                            checkable: true
                            exclusiveGroup: mainTool
                            onTriggered: if (checked) whiteboard.selectedTool = 'circle'
                        }

                        MenuItem {
                            text: qsTr('El·lipse')
                            checkable: true
                            exclusiveGroup: mainTool
                            onTriggered: whiteboard.selectedTool = 'ellipse'
                        }
                    }
                }

                Button {
                    Layout.fillHeight: true
                    text: qsTr('Undo')
                    enabled: whiteArea.undoable
                    onClicked: whiteArea.undoDrawings()
                }

                Button {
                    Layout.fillHeight: true
                    text: qsTr('Redo')
                    enabled: whiteArea.redoable
                    onClicked: whiteArea.redoDrawings()
                }

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    Layout.fillHeight: true
                    text: qsTr('Guix')
                    menu: Menu {
                        title: qsTr('Color del guix')
                        MenuItem {
                            text: qsTr('Blanc')
                            onTriggered: whiteArea.foreground = 'white'
                        }
                        MenuItem {
                            text: qsTr('Verd')
                            onTriggered: whiteArea.foreground = '#00ff00'
                        }
                        MenuItem {
                            text: qsTr('Negre')
                            onTriggered: whiteArea.foreground = 'black'
                        }
                    }
                }

                Button {
                    Layout.fillHeight: true
                    text: qsTr('Fons')
                    menu: Menu {
                        title: qsTr('Color del fons')
                        MenuItem {
                            text: qsTr('Fosc')
                            onTriggered: whiteArea.background = '#585858'
                        }
                        MenuItem {
                            text: qsTr('Verd')
                            onTriggered: whiteArea.background = '#007700'
                        }
                        MenuItem {
                            text: qsTr('Clar')
                            onTriggered: whiteArea.background = '#F5F6CE'
                        }
                    }
                }

                Button {
                    Layout.fillHeight: true
                    text: qsTr('Desa')
                    height: 50
                }

                Button {
                    Layout.fillHeight: true
                    text: qsTr('Neteja')
                    onClicked: messageErase.open()
                }

            }
        }

        Flickable {
            id: flickCanvas
            Layout.fillWidth: true
            Layout.fillHeight: true
            interactive: whiteboard.selectedTool == 'move'
            contentWidth: 2000 // contentItem.width
            contentHeight: 2000 // contentItem.height
            clip: true

            Canvas {
                id: whiteArea
                width: 2000
                height: 2000
                renderStrategy: Canvas.Cooperative
                //renderTarget: Canvas.FramebufferObject
//                canvasSize: Qt.size(1000,1000)

                property var allElements: []
                property string background: '#007700'
                property string foreground: 'white'
                property bool undoable: (actionIndex>0)
                property bool redoable: (actionIndex<allElements.length)
                property int actionIndex: 0

                onAllElementsChanged: {
                    console.log('Punts length ' + whiteArea.allElements.length);
                }

                Common.CanvasElement {
                    id: canvasPoint
                    anchors.fill: parent
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    enabled: whiteboard.selectedTool != 'move'

                    property int px;
                    property int py;

                    onPressed: {
                        var component = Qt.createComponent('common/CanvasElement.qml');
                        var item = component.createObject(whiteArea);
                        // Remove items between actionIndex and the last one, because these items have been undone
                        while (whiteArea.actionIndex<whiteArea.allElements.length)
                            whiteArea.allElements.pop();
                        // Add the next item
                        whiteArea.allElements.push(item);
                        whiteArea.actionIndex++;

                        item.color = whiteArea.foreground;
                        item.addPoint({x: Math.round(mouseArea.mouseX), y: Math.round(mouseArea.mouseY)});
                        switch(selectedTool) {
                        case 'pencil':
                            item.itemType = canvasPoint.typePolygon;
                            break;
                        case 'line':
                            item.itemType = canvasPoint.typeLine;
                            break;
                        case 'rect':
                            item.itemType = canvasPoint.typeRect;
                            break;
                        case 'circle':
                            item.itemType = canvasPoint.typeCircle;
                            break;
                        case 'ellipse':
                            item.itemType = canvasPoint.typeEllipse;
                            break;
                        default:
                            break;
                        }

                        whiteArea.requestPaint();
                    }

                    onPositionChanged: {
                        var item = whiteArea.allElements[whiteArea.allElements.length-1];
                        item.color = whiteArea.foreground;
                        item.addPoint({x: Math.round(mouseArea.mouseX), y: Math.round(mouseArea.mouseY)});
                        whiteboard.drawingAction = ''
//                        whiteboard.drawingAction = 'LastItem'
                        whiteArea.requestPaint();
                    }

                    onReleased: {
                        var item = whiteArea.allElements[whiteArea.allElements.length-1];
                        item.color = whiteArea.foreground;
                        item.addPoint({x: Math.round(mouseArea.mouseX), y: Math.round(mouseArea.mouseY)});
                        whiteboard.drawingAction = ''
//                        whiteboard.drawingAction = 'LastItem'
                        whiteArea.requestPaint();
                    }
                }

                onPaint: {
                    var ctx = whiteArea.getContext("2d");

                    switch(whiteboard.drawingAction) {
                    case 'LastItem':
                        allElements[allElements.length-1].paint(ctx);
                        break;
                    case 'Clear':
                    default:
                        clearArea(ctx,whiteArea.background);
                        for (var i=0; i<actionIndex; i++)
                            allElements[i].paint(ctx);
                        break;
                    }
                    whiteboard.drawingAction = '';
                }

                function clearArea(ctx,color) {
                    ctx.save();
                    ctx.fillStyle = color;
                    ctx.fillRect(0,0,whiteArea.width,whiteArea.height);
                    ctx.restore();
                }

                function undoDrawings() {
                    if (undoable) {
                        actionIndex--;
                        requestPaint();
                    }
                }

                function redoDrawings() {
                    if (redoable) {
                        actionIndex++;
                        requestPaint();
                    }
                }
            }
        }
    }

    MessageDialog {
        id: messageErase
        title: qsTr('Esborrar la tela');
        text: qsTr('Es borrara tot el que has dibuixat. Vols continuar?')
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: {
            while (whiteArea.allElements.length>0)
                whiteArea.allElements.pop();
            whiteArea.requestPaint();
        }
    }

    Component.onCompleted: {
        whiteArea.requestPaint();
    }
}

