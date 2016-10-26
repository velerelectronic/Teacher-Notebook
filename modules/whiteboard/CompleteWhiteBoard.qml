import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQml.Models 2.2
import FileIO 1.0
import 'qrc:///common' as Common
import 'qrc:///modules/basic' as Basic

Rectangle {
    id: whiteBoardItem

    property string selectedFile
    property var zoomedRectangle
    property var canvasContents: null

    signal savingImage(string contents)
    signal savedImage(string file)

    Common.UseUnits {
        id: units
    }

    FileIO {
        id: saveImageFile
    }


    ColumnLayout {
        anchors.fill: parent

        Basic.ButtonsRow {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit + units.nailUnit * 2

            Common.ImageButton {
                id: pencilButton

                width: size
                height: size

                property bool active: !eraserButton.active

                image: 'pen-147569'
                size: units.fingerUnit
                onClicked: {
                    eraserButton.active = false;
                }
            }
            Common.ImageButton {
                width: size
                height: size

                image: 'washing-36666'
                size: units.fingerUnit
                onClicked: lineWidthDialog.open()
            }
            Common.ImageButton {
                width: size
                height: size
                size: units.fingerUnit
                image: 'palette-23406'
                onClicked: colourSelectorDialog.open()

                color: zoomCanvas.strokeColor
            }

            Common.ImageButton {
                id: eraserButton

                width: size
                height: size

                property bool active: false

                size: units.fingerUnit
                image: 'erase-34105'
                onClicked: {
                    eraserButton.active = true;
                }
            }

            Button {
                id: eraserWidthButton
                width: units.fingerUnit * 2

                height: units.fingerUnit
                text: qsTr('Mida')
                onClicked: eraserWidthDialog.open();
            }
            Common.ImageButton {
                width: size
                height: size

                size: units.fingerUnit
                image: 'undo-97591'
                enabled: canvasHistory.canUndo
                color: (enabled)?'white':'gray'
                onClicked: {
                    copyCanvas.stampCanvasImage(canvasHistory.setPreviousCanvas());
                    zoomCanvas.requestPaint();
                    canvasTimer.restart();
                }
            }
            Common.ImageButton {
                width: size
                height: size
                size: units.fingerUnit
                image: 'redo-97589'
                enabled: canvasHistory.canRedo
                color: (enabled)?'white':'gray'
                onClicked: {
                    copyCanvas.stampCanvasImage(canvasHistory.setNextCanvas());
                    zoomCanvas.requestPaint();
                    canvasTimer.restart();
                }
            }
            Common.ImageButton {
                width: size
                height: size
                size: units.fingerUnit
                image: 'zoom-27958'
                onClicked: {
                    zoomSelectorDialog.open();
                }
            }

            Common.ImageButton {
                Layout.fillHeight: true
                Layout.preferredWidth: size
                size: units.fingerUnit
                image: 'floppy-35952'
                color: (zoomCanvas.canvasHistoryIndex == 0)?'grey':'white'
                onClicked: {
                    saveImageFile.source = selectedFile;
                    saveImageFile.addExtension('png');
                    saveImageFile.writePngImage(copyCanvas.getFinalImage());
                    savedImage(saveImageFile.source);
                }
            }
        }

        Item {
            id: canvasSubArea

            Layout.fillHeight: true
            Layout.fillWidth: true

            property real ratioCanvasDimensionsToZoomedRectangle: 1

            function recalculateCanvasRectangle() {
                canvasBorders.leftBorderEnabled = zoomedRectangle.x > 0;
                canvasBorders.rightBorderEnabled = zoomedRectangle.x + zoomedRectangle.width < zoomCanvas.canvasSize.width;
                canvasBorders.topBorderEnabled = zoomedRectangle.y > 0;
                canvasBorders.bottomBorderEnabled = zoomedRectangle.y + zoomedRectangle.height < zoomCanvas.canvasSize.height;

                ratioCanvasDimensionsToZoomedRectangle = Math.min(canvasSubArea.width / zoomedRectangle.width, canvasSubArea.height / zoomedRectangle.height);
                zoomCanvas.canvasWindow.x = Math.round(zoomedRectangle.x);
                zoomCanvas.canvasWindow.y = Math.round(zoomedRectangle.y);
                zoomCanvas.canvasWindow.width = zoomCanvas.width;
                zoomCanvas.canvasWindow.height = zoomCanvas.height;
            }

            CanvasHistory {
                id: canvasHistory
            }

            Image {
                id: backgroundImage

                source: selectedFile
                visible: false
                cache: true
                fillMode: Image.Pad
                //transformOrigin: zoomCanvas.transformOrigin
                //scale: zoomCanvas.canvasSize.width / zoomCanvas.canvasWindow.width

                onStatusChanged: {
                    if (status == Image.Ready) {
                        console.log('READY');
                        if (canvasContents == null) {
                            zoomCanvas.canvasSize = Qt.size(backgroundImage.implicitWidth, backgroundImage.implicitHeight);
                            var completeRect = Qt.rect(0, 0, backgroundImage.implicitWidth, backgroundImage.implicitHeight);
                            canvasSubArea.recalculateCanvasRectangle();
                            copyCanvas.getDimensions(zoomCanvas.canvasSize.width, zoomCanvas.canvasSize.height);
                            zoomCanvas.resetBackground = true;
                            zoomCanvas.requestPaint();
                        } else {
                            console.log('canvas contents not NULL');
                        }
                    }
                }
            }

            Canvas {
                id: zoomCanvas

                anchors {
                    top: parent.top
                    left: parent.left
                }

                scale: parent.ratioCanvasDimensionsToZoomedRectangle
                transformOrigin: Item.TopLeft

                width: Math.floor(parent.width / zoomCanvas.scale)
                height: Math.floor(parent.height / zoomCanvas.scale)

                property var points: []
                property real lineWidth: units.nailUnit
                property real eraserWidth: units.nailUnit * 3
                property string strokeColor: '#000000'

                property bool drawToolSelected: pencilButton.active
                property bool canvasImageNeedsToBeSaved: false

                property bool putCanvasIntoHistory: false

                property bool resetBackground: false
                property bool toolBeingUsed: false
                property bool firstTime: true

                MouseArea {
                    id: mousePointer

                    anchors.fill: parent

                    function makeDirtyRect(posX, posY, maxWidth) {
                        zoomCanvas.markDirty(Qt.rect(posX - maxWidth, posY - maxWidth, maxWidth * 2, maxWidth * 2));
                    }

                    onPressed: {
                        canvasTimer.stop();
                        var maxX = zoomCanvas.width;
                        var maxY = zoomCanvas.height;
                        zoomCanvas.toolBeingUsed = true;

                        if ((mouse.x>=0) && (mouse.y>=0) && (mouse.x<maxX) && (mouse.y<maxY)) {
                            mouse.accepted = true;
                            zoomCanvas.points = [];
                            var newX = mouse.x + zoomCanvas.canvasWindow.x;
                            var newY = mouse.y + zoomCanvas.canvasWindow.y;
                            zoomCanvas.points.push(Qt.point(newX, newY));
                            mousePointer.makeDirtyRect(newX, newY, zoomCanvas.lineWidth/2);
                        }
                    }
                    onPositionChanged: {
                        var maxX = zoomCanvas.width;
                        var maxY = zoomCanvas.height;

                        if ((mouse.x>=0) && (mouse.y>=0) && (mouse.x<maxX) && (mouse.y<maxY)) {
                            var newX = mouse.x + zoomCanvas.canvasWindow.x;
                            var newY = mouse.y + zoomCanvas.canvasWindow.y;

                            zoomCanvas.points.push(Qt.point(newX, newY));
                            if (eraserButton.active) {
                                eraseRect.reposition(mouse.x,mouse.y)
                                eraseRect.visible = true;
                            } else {
                                eraseRect.visible = false;
                            }
                            mousePointer.makeDirtyRect(newX, newY, zoomCanvas.lineWidth/2);
                        } else {
                            eraseRect.visible = false;
                            if (eraserButton.active)
                                mousePointer.makeDirtyRect(newX, newY, zoomCanvas.lineWidth);
                            else
                                zoomCanvas.paintPoints();

                            active = false;
                        }
                    }
                    onReleased: {
                        eraseRect.visible = false;
                        var newX = mouse.x + zoomCanvas.canvasWindow.x;
                        var newY = mouse.y + zoomCanvas.canvasWindow.y;
                        zoomCanvas.points.push(Qt.point(newX, newY));
                        if (eraserButton.active) {
                        }
                        else {
//                            zoomCanvas.paintPoints();
                        }
                        zoomCanvas.putCanvasIntoHistory = true;
                        mousePointer.makeDirtyRect(newX, newY, zoomCanvas.lineWidth/2);
                        zoomCanvas.toolBeingUsed = false;
                        canvasTimer.restart();
                    }
                }

                Rectangle {
                    id: eraseRect

                    visible: false
                    border.color: 'black'
                    color: 'transparent'
                    width: zoomCanvas.eraserWidth * 2
                    height: zoomCanvas.eraserWidth * 2

                    function reposition(x,y) {
                        eraseRect.x = x - eraseRect.width / 2
                        eraseRect.y = y - eraseRect.height / 2
                    }
                }


                Timer {
                    id: canvasTimer

                    running: true
                    interval: 500
                    onTriggered: zoomCanvas.requestPaint();
                }

                onAvailableChanged: {
                    if (available) {
                        canvasSubArea.recalculateCanvasRectangle();
                        requestPaint();
                    }
                }

                onPaint: {
                    if (available) {
                        var ctx = zoomCanvas.getContext("2d");
                        var ctxCopy = copyCanvas.getContext("2d");

                        console.log('ABOUT TO PAINT', region);
                        // Draw background, if required

                        if (!toolBeingUsed) {
                            console.log('inside !toolBeingUsed');
                            console.log(backgroundImage.status);
                            if (backgroundImage.status != Image.Ready)
                                console.log('image not ready');
                            ctx.clearRect(region.x, region.y, region.width, region.height);
                            ctx.drawImage(backgroundImage, region.x, region.y, region.width, region.height, region.x, region.y, region.width, region.height);

                            var firstImage = ctxCopy.getImageData(region.x, region.y, region.width, region.height);
                            ctx.drawImage(firstImage, region.x, region.y);
                        }

                        if (drawToolSelected) {
                            paintPoints(ctx);
                            paintPoints(ctxCopy);
                        } else {
                            for (var i=0; i<points.length; i++) {
                                erasePoint(ctx, points[i]);
                                erasePoint(ctxCopy, points[i]);
                            }
                            points = [];
                        }

                        if ((putCanvasIntoHistory) || (firstTime)) {
                            putCanvasIntoHistory = false;
                            firstTime = 0;
                            var fullImage = ctxCopy.getImageData(0, 0, copyCanvas.width, copyCanvas.height);
                            canvasHistory.addCanvas(fullImage);
                        }
                    }
                }

                function paintPoints(ctx) {
                    //ctx.fillStyle = Qt.rgba(1, 0, 0, 1);

                    if (drawToolSelected) {
                        var l = zoomCanvas.points.length;
                        switch(l) {
                        case 0:
                            break;
                        case 1:
                            drawSinglePoint(ctx,points[0]);
                            break;
                        default:
                            drawSinglePoint(ctx,points[0]);
                            for (var i=1; i<l; i++) {
                                var point1 = points[i-1];
                                var point2 = points[i];
                                drawLineBetweenTwoPoints(ctx,point1, point2);
                            }
                            drawSinglePoint(ctx,points[l-1]);
                        }
                    } else {
                    }
                }

                function drawSinglePoint(ctx,point) {
                    ctx.beginPath();
                    if (drawToolSelected) {
                        ctx.lineWidth = zoomCanvas.lineWidth / 2 / scale;
                        ctx.lineJoin = "round";
                        ctx.strokeStyle = zoomCanvas.strokeColor;
                        ctx.fillStyle = zoomCanvas.strokeColor;
                        ctx.arc(point.x, point.y, zoomCanvas.lineWidth/4 / scale, 0, 2 * Math.PI);
                    } else {
                        ctx.lineWidth = zoomCanvas.eraserWidth / scale;
                        ctx.lineJoin = "round";
                        ctx.strokeStyle = '#FFFFFF';
                        ctx.fillStyle = '#FFFFFF';
                        ctx.arc(point.x, point.y, zoomCanvas.eraserWidth / 2 / scale, 0, 2 * Math.PI);

                    }
                    ctx.stroke();
                }

                function drawLineBetweenTwoPoints(ctx,point1,point2) {
                    ctx.beginPath();
                    if (drawToolSelected) {
                        ctx.lineWidth = zoomCanvas.lineWidth / scale;
                        ctx.lineJoin = "round";
                        ctx.strokeStyle = zoomCanvas.strokeColor;
                    } else {
                        ctx.lineWidth = zoomCanvas.eraserWidth * 2 / scale;
                        ctx.lineJoin = "round";
                        ctx.strokeStyle = '#FFFFFF';
                        ctx.fillStyle = '#FFFFFF';
                    }
                    ctx.moveTo(point1.x, point1.y);
                    ctx.lineTo(point2.x, point2.y);
                    ctx.stroke();
                }

                function erasePoint(ctx, point) {
                    var imageX = Math.floor(point.x - eraserWidth);
                    var imageY = Math.floor(point.y - eraserWidth);
                    var imageWidth = Math.floor(eraserWidth * 2);
                    var imageHeight = imageWidth;
                    ctx.clearRect(imageX, imageY, imageWidth, imageHeight);
                    ctx.drawImage(backgroundImage, imageX, imageY, imageWidth, imageHeight, imageX, imageY, imageWidth, imageHeight);
                }
            }


            MoveCanvasBorders {
                id: canvasBorders

                anchors.fill: parent

                maximumBorder: units.fingerUnit * 2
                color: 'gray'

                onTopBorderClicked: {
                    zoomedRectangle.y = Math.max(zoomedRectangle.y - units.fingerUnit, 0);
                    canvasSubArea.recalculateCanvasRectangle();
                    zoomCanvas.requestPaint();
                    console.log("up");
                }
                onBottomBorderClicked: {
                    zoomedRectangle.y = Math.min(zoomedRectangle.y + units.fingerUnit, zoomCanvas.canvasSize.height - zoomCanvas.height);
                    console.log("down");
                    canvasSubArea.recalculateCanvasRectangle();
                    zoomCanvas.requestPaint();
                }
                onLeftBorderClicked: {
                    zoomedRectangle.x = Math.max(zoomedRectangle.x - units.fingerUnit, 0);
                    console.log("left");
                    canvasSubArea.recalculateCanvasRectangle();
                    zoomCanvas.requestPaint();
                }
                onRightBorderClicked: {
                    zoomedRectangle.x = Math.min(zoomedRectangle.x + units.fingerUnit, zoomCanvas.canvasSize.width - zoomCanvas.width);
                    console.log("right");
                    canvasSubArea.recalculateCanvasRectangle();
                    zoomCanvas.requestPaint();
                }
            }
        }
    }

    Common.SuperposedMenu {
        id: lineWidthDialog

        title: qsTr('Gruixa del llapis')
        parentWidth: whiteBoardItem.width
        parentHeight: whiteBoardItem.height

        Common.SuperposedMenuEntry {
            text: qsTr('Mida *')
            onClicked: {
                zoomCanvas.lineWidth = units.nailUnit;
                lineWidthDialog.close();
            }
        }
        Common.SuperposedMenuEntry {
            text: qsTr('Mida **')
            onClicked: {
                zoomCanvas.lineWidth = units.nailUnit * 2;
                lineWidthDialog.close();
            }
        }
        Common.SuperposedMenuEntry {
            text: qsTr('Mida ***')
            onClicked: {
                zoomCanvas.lineWidth = units.nailUnit * 3;
                lineWidthDialog.close();
            }
        }
        Common.SuperposedMenuEntry {
            text: qsTr('Mida ****')
            onClicked: {
                zoomCanvas.lineWidth = units.nailUnit * 4;
                lineWidthDialog.close();
            }
        }
    }

    Common.SuperposedMenu {
        id: eraserWidthDialog

        title: qsTr('Mida de la goma')
        parentWidth: whiteBoardItem.width
        parentHeight: whiteBoardItem.height

        Common.SuperposedMenuEntry {
            text: qsTr('Mida *')
            onClicked: {
                zoomCanvas.eraserWidth = units.nailUnit;
                eraserWidthDialog.close();
            }
        }
        Common.SuperposedMenuEntry {
            text: qsTr('Mida **')
            onClicked: {
                zoomCanvas.eraserWidth = units.nailUnit * 2;
                eraserWidthDialog.close();
            }
        }
        Common.SuperposedMenuEntry {
            text: qsTr('Mida ***')
            onClicked: {
                zoomCanvas.eraserWidth = units.nailUnit * 3;
                eraserWidthDialog.close();
            }
        }
        Common.SuperposedMenuEntry {
            text: qsTr('Mida ****')
            onClicked: {
                zoomCanvas.eraserWidth = units.nailUnit * 4;
                eraserWidthDialog.close();
            }
        }
    }

    Common.SuperposedMenu {
        id: colourSelectorDialog

        title: qsTr('Color de dibuix')
        parentWidth: whiteBoardItem.width
        parentHeight: whiteBoardItem.height

        Rectangle {
            width: parent.width
            height: units.fingerUnit * 1.5
            color: '#000000'
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    zoomCanvas.strokeColor = parent.color;
                    colourSelectorDialog.close();
                }
            }
        }
        Rectangle {
            width: parent.width
            height: units.fingerUnit * 1.5
            color: '#0000FF'
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    zoomCanvas.strokeColor = parent.color;
                    colourSelectorDialog.close();
                }
            }
        }
        Rectangle {
            width: parent.width
            height: units.fingerUnit * 1.5
            color: '#00FF00'
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    zoomCanvas.strokeColor = parent.color;
                    colourSelectorDialog.close();
                }
            }
        }
        Rectangle {
            width: parent.width
            height: units.fingerUnit * 1.5
            color: '#FF0000'
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    zoomCanvas.strokeColor = parent.color;
                    colourSelectorDialog.close();
                }
            }
        }
        Rectangle {
            width: parent.width
            height: units.fingerUnit * 1.5
            color: '#00FFFF'
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    zoomCanvas.strokeColor = parent.color;
                    colourSelectorDialog.close();
                }
            }
        }
        Rectangle {
            width: parent.width
            height: units.fingerUnit * 1.5
            color: '#FF00FF'
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    zoomCanvas.strokeColor = parent.color;
                    colourSelectorDialog.close();
                }
            }
        }
        Rectangle {
            width: parent.width
            height: units.fingerUnit * 1.5
            color: '#FFFF00'
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    zoomCanvas.strokeColor = parent.color;
                    colourSelectorDialog.close();
                }
            }
        }
        Rectangle {
            width: parent.width
            height: units.fingerUnit * 1.5
            color: '#FFFFFF'
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    zoomCanvas.strokeColor = parent.color;
                    colourSelectorDialog.close();
                }
            }
        }
    }

    Common.SuperposedMenu {
        id: zoomSelectorDialog

        title: qsTr('Ampliació o reducció')
        parentWidth: whiteBoardItem.width
        parentHeight: whiteBoardItem.height

        Common.SuperposedMenuEntry {
            text: '800%'
            onClicked: {
                zoomCanvas.scale = 8;
                zoomSelectorDialog.close();
            }
        }

        Common.SuperposedMenuEntry {
            text: '600%'
            onClicked: {
                zoomCanvas.scale = 6;
                zoomSelectorDialog.close();
            }
        }

        Common.SuperposedMenuEntry {
            text: '400%'
            onClicked: {
                zoomCanvas.scale = 4;
                zoomSelectorDialog.close();
            }
        }
        Common.SuperposedMenuEntry {
            text: '200%'
            onClicked: {
                zoomCanvas.scale = 2;
                zoomSelectorDialog.close();
            }
        }
        Common.SuperposedMenuEntry {
            text: qsTr('100% - Original')
            onClicked: {
                zoomCanvas.scale = 1;
                zoomSelectorDialog.close();
            }
        }
        Common.SuperposedMenuEntry {
            text: qsTr('50%')
            onClicked: {
                zoomCanvas.scale = 0.5;
                zoomSelectorDialog.close();
            }
        }
        Common.SuperposedMenuEntry {
            text: qsTr('25%')
            onClicked: {
                zoomCanvas.scale = 0.25;
                zoomSelectorDialog.close();
            }
        }
    }

    Canvas {
        id: copyCanvas

        // Object required to get the zoomCanvas contents, put them on the original image and then save the result into a file.

        visible: false
        property bool converting: false

        function getDimensions(w, h) {
            width = w;
            height = h;
            canvasSize.width = w;
            canvasSize.height = h;
            canvasWindow = Qt.rect(0, 0, w, h);
        }

        function stampCanvasImage(imageData) {
            var ctx = getContext("2d");
            ctx.drawImage(imageData, 0, 0, imageData.width, imageData.height, 0, 0, imageData.width, imageData.height);
        }

        function getFinalImage() {
            var ctx = getContext("2d");
            var fullImage = ctx.getImageData(0, 0, copyCanvas.width, copyCanvas.height);
            ctx.drawImage(backgroundImage, 0, 0);
            ctx.drawImage(fullImage, 0, 0);
            return toDataURL();
        }
    }

}
