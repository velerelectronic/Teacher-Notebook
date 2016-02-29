import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.1
import 'qrc:///common' as Common
import "qrc:///javascript/Storage.js" as Storage


BasicPage {
    id: whiteboard

    pageTitle: qsTr('Pissarra')
    // Possible drawing actions ['Clear', 'Path']
    property string drawingAction: ''
    property string selectedDrawingTool: canvasPoint.typePolygon

    Common.UseUnits { id: units }

    mainPage: ColumnLayout {
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

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Flickable {
                id: flickCanvas
                anchors.fill: parent

                interactive: false
                contentWidth: 2000 // contentItem.width
                contentHeight: 2000 // contentItem.height
                clip: true

                leftMargin: units.fingerUnit * 2
                rightMargin: units.fingerUnit * 2
                topMargin: units.fingerUnit * 2
                bottomMargin: units.fingerUnit * 2
                contentX: 0
                contentY: 0

                Rectangle {
                    color: 'yellow'
                    width: flickCanvas.contentWidth
                    height: flickCanvas.contentHeight

                    Canvas {
                        id: whiteArea
                        enabled: true
                        anchors.fill: parent

                        renderStrategy: Canvas.Cooperative
                        renderTarget: Canvas.FramebufferObject
//                        canvasSize: Qt.size(flickCanvas.contentWidth,flickCanvas.contentHeight)
//                        canvasWindow: Qt.rect(flickCanvas.contentX + flickCanvas.leftMargin, flickCanvas.contentY + flickCanvas.topMargin, flickCanvas.width + flickCanvas.leftMargin + flickCanvas.rightMargin, flickCanvas.height + flickCanvas.topMargin + flickCanvas.bottomMargin)

                        onCanvasWindowChanged: {
                            console.log(flickCanvas.width, flickCanvas.height)
                            console.log('Canvas window ' + canvasWindow);
                            requestPaint();
                        }

                        //renderTarget: Canvas.FramebufferObject
            //                canvasSize: Qt.size(1000,1000)

                        property var allElements: []
                        property var lastElement
                        property string background: '#007700'
                        property string foreground: 'white'
                        property bool undoable: (actionIndex>0)
                        property bool redoable: (actionIndex<allElements.length)
                        property int actionIndex: 0
                        property bool paintAll: true

                        Common.CanvasElement {
                            id: canvasPoint
                            anchors.fill: parent
                        }

                        onPaint: {
                            console.log('Paint ' + region);
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
                                console.log('Painting')

                                var ctx = whiteArea.getContext('2d');

                                if (paintAll) {
                                    clearArea(ctx, whiteArea.background);
                                    var i=0;
                                    while (i<actionIndex) {
                                        whiteArea.allElements[i].paint(1.0);
                                        i++;
                                    }
                                    while (i<whiteArea.allElements.length) {
                                        whiteArea.allElements[i].paint(0.3);
                                        i++;
                                    }
                                } else {
                                    /*
                                    if (whiteArea.allElements.length>0) {
                                        console.log("Context" + ctx);
                                        whiteArea.allElements[whiteArea.allElements.length-1].paintLast(1.0);
                                    }
                                    */
                                }
                                break;
                            }
                        }


                        function clearArea(ctx,color) {
                            console.log('Clear area');
                            ctx.save();
                            ctx.fillStyle = color;
                            ctx.fillRect(whiteArea.canvasWindow.x,whiteArea.canvasWindow.y,whiteArea.canvasWindow.width,whiteArea.canvasWindow.height);
//                            ctx.fillRect(0,0,whiteArea.canvasWindow.width,whiteArea.canvasWindow.height)
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

                        Component.onCompleted: {
                            console.log('Request paint');
                            whiteArea.requestPaint();
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        preventStealing: true
                        propagateComposedEvents: true

                        property int px;
                        property int py;

                        function transformXCoordinate(coordX) {
                            var p = coordX + whiteArea.canvasWindow.x;
                            if (p < 0) {
                                p = 0;
                            } else {
                                if (p > whiteArea.canvasSize.width) {
                                    p = whiteArea.canvasSize.width;
                                }
                            }
                            return p;
                        }

                        function transformYCoordinate(coordY) {
                            var p = coordY + whiteArea.canvasWindow.y;
                            if (p < 0) {
                                p = 0;
                            } else {
                                if (p > whiteArea.canvasSize.height) {
                                    p = whiteArea.canvasSize.height;
                                }
                            }
                            return p;
                        }

                        onPressed: {
                            if (selectedDrawingTool !== 'move') {
                                // var component = Qt.createComponent('qrc:///common/CanvasElement.qml');
                                // var item = component.createObject(whiteArea);
                                whiteArea.lastElement = canvasElementComponent.createObject(whiteArea);
                                whiteArea.lastElement.ctx = whiteArea.getContext("2d");
                                // Remove items between actionIndex and the last one, because these items have been undone
                                while (whiteArea.actionIndex<whiteArea.allElements.length)
                                    whiteArea.allElements.pop();
                                // Add the next item
                                whiteArea.allElements.push(whiteArea.lastElement);
                                whiteArea.actionIndex++;
                                whiteArea.lastElement.addFirstPoint(selectedDrawingTool, {x: transformXCoordinate(mouseArea.mouseX), y: transformYCoordinate(mouseArea.mouseY)}, whiteArea.foreground);
                                whiteArea.lastElement.paint(1.0);
                            }
                            px = mouse.x;
                            py = mouse.y;
                            nowTime = new Date();
                        }

                        property date nowTime

                        onPositionChanged: {
                            var newTime = new Date();
                            var diff = newTime.getTime() - nowTime.getTime();
                            console.log(diff / 1000);
                            nowTime = newTime;

                            whiteArea.lastElement.addPoint({x: transformXCoordinate(mouseArea.mouseX), y: transformYCoordinate(mouseArea.mouseY)});
                            whiteArea.lastElement.paintLast();
                            whiteArea.paintAll = false;
                            whiteboard.drawingAction = 'LastItem';
                            whiteArea.markDirty(whiteArea.lastElement.getLastRegion());
                            whiteArea.paintAll = true;
                        }

                        onReleased: {
                            whiteArea.lastElement.addPoint({x: transformXCoordinate(mouseArea.mouseX), y: transformYCoordinate(mouseArea.mouseY)});
                            whiteboard.drawingAction = 'LastItem';
                            whiteArea.markDirty(whiteArea.lastElement.getLastRegion());
                            mouse.accepted = true;
                        }

                        onPressAndHold: {
                            console.log('Press and hold')
                            mouse.accepted = false;
                        }
                    }

                }

                function addHorizontalOffset(offset) {
                    flickCanvas.contentX += offset;
                    flickCanvas.returnToBounds();
                }

                function addVerticalOffset(offset) {
                    flickCanvas.contentY += offset;
                    flickCanvas.returnToBounds();
                }

                function addHorizontalVerticalOffset(offsetX, offsetY) {
                    flickCanvas.contentX += offsetX;
                    flickCanvas.contentY += offsetY;
                    flickCanvas.returnToBounds();
                }
            }


            GridLayout {
                anchors.fill: parent
                columns: 3
                rows: 3
                rowSpacing: 0
                columnSpacing: 0

                MouseArea {
                    id: canvasLTmargin
                    Layout.preferredHeight: units.fingerUnit * 2
                    Layout.preferredWidth: units.fingerUnit * 2
                    onClicked: flickCanvas.addHorizontalVerticalOffset(-units.fingerUnit * 2, -units.fingerUnit * 2)
                }
                MouseArea {
                    id: canvasTmargin
                    Layout.preferredHeight: units.fingerUnit * 2
                    Layout.fillWidth: true
                    onClicked: flickCanvas.addVerticalOffset(-units.fingerUnit * 2)
                }
                MouseArea {
                    id: canvasRTmargin
                    Layout.preferredHeight: units.fingerUnit * 2
                    Layout.preferredWidth: units.fingerUnit * 2
                    onClicked: flickCanvas.addHorizontalVerticalOffset(units.fingerUnit * 2, -units.fingerUnit * 2)
                }
                MouseArea {
                    id: canvasLmargin
                    Layout.fillHeight: true
                    Layout.preferredWidth: units.fingerUnit * 2
                    onClicked: flickCanvas.addHorizontalOffset(-units.fingerUnit * 2)
                }
                Rectangle {
                    id: mainArea
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    border.color: 'black'
                    color: 'transparent'
                }
                MouseArea {
                    id: canvasRmargin
                    Layout.fillHeight: true
                    Layout.preferredWidth: units.fingerUnit * 2
                    onClicked: flickCanvas.addHorizontalOffset(units.fingerUnit * 2)
                }
                MouseArea {
                    id: canvasLBmargin
                    Layout.preferredHeight: units.fingerUnit * 2
                    Layout.preferredWidth: units.fingerUnit * 2
                    onClicked: flickCanvas.addHorizontalVerticalOffset(-units.fingerUnit * 2, units.fingerUnit * 2)
                }
                MouseArea {
                    id: canvasBmargin
                    Layout.preferredHeight: units.fingerUnit * 2
                    Layout.fillWidth: true
                    onClicked: flickCanvas.addVerticalOffset(units.fingerUnit * 2)
                }
                MouseArea {
                    id: canvasRBmargin
                    Layout.preferredHeight: units.fingerUnit * 2
                    Layout.preferredWidth: units.fingerUnit * 2
                    onClicked: flickCanvas.addHorizontalVerticalOffset(units.fingerUnit * 2, units.fingerUnit * 2)
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

    Component {
        id: canvasElementComponent

        Item {
            id: canvasElement
            width: 10
            height: 10
            // Types of figures
            property int typePolygon: 1
            property int typeRect: 2
            property int typeRectangle: 3
            property int typeImage: 4
            property int typeText: 5
            property int typeCircle: 6
            property int typeEllipse: 7

            property int itemType: 0
            property var points: []
            property var image: []
            property int rotation: 0
            property real scale: 1
            property var strokeStyle
            property string content: ''
            property var ctx

            signal selected

            MouseArea {
                anchors.fill: parent
                onClicked: canvasElement.selected()
                propagateComposedEvents: true
            }

            function getLastRegion() {
                var q;
                var p;
                if (points.length>=1) {
                    q = points[points.length-1];
                    if (points.length == 1) {
                        p = points[points.length-2];
                    } else {
                        p = q;
                    }
                } else {
                    p = Qt.point(0,0);
                    p = p;
                }
                return Qt.rect(Math.min(p.x, q.x), Math.min(p.y, q.y), Math.abs(p.x-q.x), Math.abs(p.y-q.y) );
            }

            function drawLineSegment(ctx,px,py,qx,qy) {
                ctx.beginPath();
                ctx.moveTo(px, py);
                ctx.lineTo(qx, qy);
                ctx.stroke();
                ctx.closePath();
            }

            function drawRectangle(ctx,px,py,qx,qy) {
                ctx.beginPath();
                ctx.moveTo(px,py);
                ctx.lineTo(px,qy);
                ctx.lineTo(qx,qy);
                ctx.lineTo(qx,py);
                ctx.lineTo(px,py);
                ctx.stroke();
                ctx.closePath();
            }

            function drawCircle(ctx,px,py,qx,qy) {
                ctx.beginPath();
                ctx.arc(px,py,Math.sqrt(Math.pow(px-qx,2)+Math.pow(py-qy,2)),0,Math.PI*2, true);
                ctx.stroke();
                ctx.closePath();
            }

            function drawAnEllipse(ctx,px,py,qx,qy) {
                ctx.beginPath();
                ctx.ellipse(px,py,qx-px,qy-py);
                ctx.stroke();
                ctx.closePath();
            }

            function paintLast() {
                ctx.save();
                ctx.globalAlpha = 1.0;
                ctx.strokeStyle = strokeStyle;
                var l = points.length;
                var p = points[(l>1)?(l-2):(l-1)];
                var q = points[l-1];
                drawLineSegment(ctx,p.x,p.y,q.x,q.y);
                ctx.restore();
            }

            function paint(alpha) {
                ctx.save();
                ctx.globalAlpha = alpha;
                ctx.strokeStyle = strokeStyle;
                switch(itemType) {
                case typeRect:
                case typePolygon:
                    var l = points.length;
                    for (var i=1; i<l; i++) {
                        var p = points[i-1];
                        var q = points[i];
                        drawLineSegment(ctx,p.x,p.y,q.x,q.y);
                    }
                    break;
                case typeRectangle:
                    if (points.length==2) {
                        var p = points[0];
                        var q = points[1];
                        drawRectangle(ctx,p.x,p.y,q.x,q.y);
                    }
                    break;

                case typeCircle:
                    if (points.length==2) {
                        var p = points[0];
                        var q = points[1];
                        drawCircle(ctx,p.x,p.y,q.x,q.y);
                    }
                    break;

                case typeEllipse:
                    if (points.length==2) {
                        var p = points[0];
                        var q = points[1];
                        drawAnEllipse(ctx,p.x,p.y,q.x,q.y);
                    }
                    break;
                default:
                    break;
                }
                ctx.restore();
            }

            function addPoint(newpoint) {
                switch(itemType) {
                case typeRect:
                case typeRectangle:
                case typeCircle:
                case typeEllipse:
                    if (points.length>1)
                        points.pop();
                    points.push(newpoint);
                    break;
                default:
                    points.push(newpoint);
                    break;
                }
                if (itemType==typePolygon) {
                    paintLast();
                }
                console.log('Points ' + points.length)
            }

            function addFirstPoint(type,newpoint,forecolor) {
                itemType = type;
                strokeStyle = forecolor;
                points = [];
                points.push(newpoint);
                ctx.strokeStyle = strokeStyle;
                ctx.lineWidth = 3;
                paintLast();
            }

            function writeText(ctx) {

            }
        }

    }

    Component.onCompleted: {
        whiteArea.requestPaint();
    }
}

