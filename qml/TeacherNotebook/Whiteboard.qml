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
    property string selectedDrawingTool: canvasPoint.typePolygon
    property string selectedEditTool: ''
    property string selectedOptionTool: ''

    Common.UseUnits { id: units }

    ColumnLayout {
        anchors.fill:parent

        Rectangle {
            Layout.fillWidth: true;
            Layout.preferredHeight: units.fingerUnit

            ExclusiveGroup {
                id: mainTool
            }

            ListView {
                anchors.fill: parent
                orientation: ListView.Horizontal
                model: ListModel {
                    id: toolModel
                    dynamicRoles: true
                }
                snapMode: ListView.SnapOneItem
                boundsBehavior: Flickable.StopAtBounds
                delegate: Item {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: childrenRect.width
                    Button {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        width: (model.code != '')?undefined:0
                        visible: (model.code != '')
                        enabled: (model.code != '')
                        checkable: (model.checkable)?model.checkable:false
                        text: model.name
                        exclusiveGroup: mainTool
                        onClicked: {
                            switch(model.type) {
                            case 'draw':
                                whiteboard.selectedDrawingTool = model.code;
                                break;
                            case 'edit':
                                whiteboard.selectedEditTool = model.code;
                                break;
                            case 'option':
                                whiteboard.selectedOptionTool = model.code;
                                break;
                            }
                        }
                    }
                    Item {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        width: units.nailUnit
                        visible: model.code == ''
                        enabled: model.code == ''
                    }
                }
            }

            Component.onCompleted: {
                toolModel.append({type: 'edit', name: qsTr('Undo'), checkable: false, code: 'undo'});
                toolModel.append({type: 'edit', name: qsTr('Redo'), checkable: false, code: 'redo'});
                toolModel.append({name: '', code: ''});
                toolModel.append({type: 'draw', name: qsTr('Mou'), checkable: true, code: 'move'});
                toolModel.append({type: 'draw', name: qsTr('Llapis'), checkable: true, code: canvasPoint.typePolygon});
                toolModel.append({name: '', code: ''});
                toolModel.append({type: 'draw', name: qsTr('Recta'), checkable: true, code: canvasPoint.typeRect});
                toolModel.append({type: 'draw', name: qsTr('Rectangle'), checkable: true, code: canvasPoint.typeRectangle});
                toolModel.append({type: 'draw', name: qsTr('Cercle'), checkable: true, code: canvasPoint.typeCircle});
                toolModel.append({type: 'draw', name: qsTr('El·lipse'), checkable: true, code: canvasPoint.typeEllipse});
                toolModel.append({name: '', code: ''});
                toolModel.append({type: 'option', name: qsTr('Blanc'), checkable: true, code: 'foreWhite'});
                toolModel.append({type: 'option', name: qsTr('Verd'), checkable: true, code: 'foreGreen'});
                toolModel.append({type: 'option', name: qsTr('Negre'), checkable: true, code: 'foreBlack'});
                toolModel.append({name: '', code: ''});
                toolModel.append({type: 'option', name: qsTr('Fosc'), checkable: true, code: 'backDark'});
                toolModel.append({type: 'option', name: qsTr('Verd'), checkable: true, code: 'backGreen'});
                toolModel.append({type: 'option', name: qsTr('Clar'), checkable: true, code: 'backLight'});
                toolModel.append({name: '', code: ''});
                toolModel.append({type: 'edit', name: qsTr('Desa'), checkable: false, code: 'save'});
                toolModel.append({type: 'edit', name: qsTr('Neteja'), checkable: false, code: 'clear'});
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
                    enabled: whiteboard.selectedDrawingTool != 'move'
                    preventStealing: true

                    property int px;
                    property int py;

                    onPressed: {
                        var component = Qt.createComponent('common/CanvasElement.qml');
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
                        var ctx = whiteArea.getContext("2d");
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
                        break;
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
                            allElements[i].paint(ctx, 0.5);
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
                        console.log('Undo');
                        actionIndex--;
                        requestPaint();
                    }
                }

                function redoDrawings() {
                    if (redoable) {
                        console.log('Redo');
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

    onSelectedEditToolChanged: {
        switch(selectedEditTool) {
        case 'undo':
            whiteArea.undoDrawings();
            break;
        case 'redo':
            whiteArea.redoDrawings();
            break;
        case 'save':
            break;
        case 'clear':
            messageErase.open();
            break;
        default:
            break;
        }
        selectedEditTool = '';
    }

    onSelectedOptionToolChanged: {
        switch(selectedOptionTool) {
        case 'foreWhite':
            whiteArea.foreground = 'white';
            break
        case 'foreGreen':
            whiteArea.foreground = '#00ff00';
            break;
        case 'foreBlack':
            whiteArea.foreground = 'black';
            break;
        case 'backDark':
            whiteArea.background = '#585858';
            whiteArea.requestPaint();
            break;
        case 'backGreen':
            whiteArea.background = '#007700';
            whiteArea.requestPaint();
            break;
        case 'backLight':
            whiteArea.background = '#F5F6CE';
            whiteArea.requestPaint();
            break;
        default:
            break;
        }
    }

    Component.onCompleted: {
        whiteArea.requestPaint();
    }
}

