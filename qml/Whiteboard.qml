import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.1
import 'qrc:///common' as Common
import "qrc:///javascript/Storage.js" as Storage


Rectangle {
    id: whiteboard

    property string pageTitle: qsTr('Pissarra')
    // Possible drawing actions ['Clear', 'Path']
    property string drawingAction: ''
    property string selectedDrawingTool: canvasPoint.typePolygon

    Common.UseUnits { id: units }

    ColumnLayout {
        anchors.fill:parent

        Rectangle {
            Layout.fillWidth: true;
            Layout.preferredHeight: units.fingerUnit

            ExclusiveGroup {
                id: mainTool
            }
            ExclusiveGroup {
                id: mainColor
            }
            ExclusiveGroup {
                id: mainBgColor
            }

            VisualItemModel {
                id: toolsModel
                Button {
                    enabled: whiteArea.undoable
                    text: qsTr('Undo')
                    onClicked: whiteArea.undoDrawings()
                }
                Button {
                    enabled: whiteArea.redoable
                    text: qsTr('Redo')
                    onClicked: whiteArea.redoDrawings()
                }
                Item {
                    width: units.fingerUnit
                }
                Button {
                    text: qsTr('Mou')
                    checkable: true
                    exclusiveGroup: mainTool
                    onClicked: {
                        whiteboard.selectedDrawingTool = 'move';
                    }
                }
                Item {
                    width: units.nailUnit
                }

                Button {
                    text: qsTr('Llapis')
                    checkable: true
                    exclusiveGroup: mainTool
                    onClicked: {
                        whiteboard.selectedDrawingTool = canvasPoint.typePolygon;
                    }
                }
                Button {
                    text: qsTr('Recta')
                    checkable: true
                    exclusiveGroup: mainTool
                    onClicked: {
                        whiteboard.selectedDrawingTool  = canvasPoint.typeRect;
                    }
                }

                Button {
                    text: qsTr('Rectangle')
                    checkable: true
                    exclusiveGroup: mainTool
                    onClicked: {
                        whiteboard.selectedDrawingTool  = canvasPoint.typeRectangle;
                    }
                }
                Button {
                    text: qsTr('Cercle')
                    checkable: true
                    exclusiveGroup: mainTool
                    onClicked: {
                        whiteboard.selectedDrawingTool  = canvasPoint.typeCircle;
                    }
                }
                Button {
                    text: qsTr('El·lipse')
                    checkable: true
                    exclusiveGroup: mainTool
                    onClicked: {
                        whiteboard.selectedDrawingTool  = canvasPoint.typeEllipse;
                    }
                }
                Item {
                    width: units.fingerUnit
                }
                Button {
                    text: qsTr('Blanc')
                    checkable: true
                    exclusiveGroup: mainColor
                    onClicked: whiteArea.foreground = 'white'
                }
                Button {
                    text: qsTr('Verd')
                    checkable: true
                    exclusiveGroup: mainColor
                    onClicked: whiteArea.foreground = '#00ff00'
                }
                Button {
                    text: qsTr('Negre')
                    checkable: true
                    exclusiveGroup: mainColor
                    onClicked: whiteArea.foreground = 'black'
                }

                Item {
                    width: units.nailUnit
                }
                Button {
                    text: qsTr('Fosc')
                    checkable: true
                    exclusiveGroup: mainBgColor
                    onClicked: {
                        whiteArea.background = '#585858';
                        whiteArea.requestPaint();
                    }
                }
                Button {
                    text: qsTr('Verd')
                    checkable: true
                    exclusiveGroup: mainBgColor
                    onClicked: {
                        whiteArea.background = '#007700';
                        whiteArea.requestPaint();
                    }
                }
                Button {
                    text: qsTr('Clar')
                    checkable: true
                    exclusiveGroup: mainBgColor
                    onClicked: {
                        whiteArea.background = '#F5F6CE';
                        whiteArea.requestPaint();
                    }
                }
                Item {
                    width: units.fingerUnit
                }

                Button {
                    text: qsTr('Desa')
                    onClicked: {
                        annotationsModel.insertObject({title: 'Whiteboard ' + Storage.currentTime(), image: whiteArea.toDataURL()});
                        messageSave.open();
                    }
                }
                Button {
                    text: qsTr('Neteja')
                    onClicked: messageErase.open()
                }
            }

            ListView {
                anchors.fill: parent
                orientation: ListView.Horizontal
                model: toolsModel

                snapMode: ListView.SnapToItem
                boundsBehavior: Flickable.StopAtBounds
            }
        }

        Flickable {
            id: flickCanvas
            Layout.fillWidth: true
            Layout.fillHeight: true
            interactive: whiteboard.selectedDrawingTool == 'move'
            contentWidth: 2000 // contentItem.width
            contentHeight: 2000 // contentItem.height
            clip: true

            Canvas {
                id: whiteArea
                width: 2000
                height: 2000
                renderStrategy: Canvas.Immediate
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
                    enabled: whiteboard.selectedDrawingTool != 'move'
                    preventStealing: true

                    property int px;
                    property int py;

                    onPressed: {
                        var component = Qt.createComponent('qrc:///common/CanvasElement.qml');
                        var item = component.createObject(whiteArea);
                        item.ctx = whiteArea.getContext("2d");
                        // Remove items between actionIndex and the last one, because these items have been undone
                        while (whiteArea.actionIndex<whiteArea.allElements.length)
                            whiteArea.allElements.pop();
                        // Add the next item
                        whiteArea.allElements.push(item);
                        whiteArea.actionIndex++;

                        item.addFirstPoint(selectedDrawingTool, {x: Math.round(mouseArea.mouseX), y: Math.round(mouseArea.mouseY)}, whiteArea.foreground);
                    }

                    onPositionChanged: {
                        var item = whiteArea.allElements[whiteArea.allElements.length-1];
                        item.addPoint({x: Math.round(mouseArea.mouseX), y: Math.round(mouseArea.mouseY)});
                        whiteboard.drawingAction = 'LastItem';
                        whiteArea.requestPaint();
                    }

                    onReleased: {
                        var item = whiteArea.allElements[whiteArea.allElements.length-1];
                        item.addPoint({x: Math.round(mouseArea.mouseX), y: Math.round(mouseArea.mouseY)});
                        whiteboard.drawingAction = 'LastItem';
                        whiteArea.requestPaint();
                    }
                }

                onPaint: {
                    switch(whiteboard.drawingAction) {
                    case 'LastItem':
                        /*
                        var item = allElements[allElements.length-1];
                        if (item.itemType==canvasPoint.typePolygon)
                            item.paintLast(ctx);
                        else
                            item.paint(ctx);
                            */
                    default:
                        console.log('Paint all');
                        var ctx = whiteArea.getContext("2d");
                        clearArea(ctx,whiteArea.background);
                        var i=0;
                        while (i<actionIndex) {
                            allElements[i].paint(ctx, 1.0);
                            i++;
                        }
                        while (i<allElements.length) {
                            allElements[i].paint(ctx, 0.3);
                            i++;
                        }
                        break;
                    }
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

    MessageDialog {
        id: messageSave
        title: qsTr('Pissarra desada')
        text: qsTr('S\'ha desat el dibuix com a anotacio.')
        standardButtons: StandardButton.Ok
    }

    Component.onCompleted: {
        whiteArea.requestPaint();
    }
}

