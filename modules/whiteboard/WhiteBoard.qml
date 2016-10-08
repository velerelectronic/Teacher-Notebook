import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQml.Models 2.2
import FileIO 1.0
import 'qrc:///common' as Common

Rectangle {
    id: whiteBoardItem

    property string selectedFile
    property var rectangle
    property var transformedRectangle

    signal savedImage()
    signal savingImage()

    Common.UseUnits {
        id: units
    }

    Image {
        id: basicImage

        source: selectedFile

        visible: false
    }

    FileIO {
        id: imageFile
    }

    ColumnLayout {
        anchors.fill: parent
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 1.5

            RowLayout {
                id: buttonsRow

                anchors.fill: parent

                ListView {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    orientation: ListView.Horizontal
                    clip: true

                    spacing: units.nailUnit
                    model: ObjectModel {
                        id: buttonsModel

                        Common.ImageButton {
                            id: pencilButton

                            width: size
                            height: size

                            property bool active: !eraserButton.active

                            image: 'pen-147569'
                            size: buttonsRow.height
                            onClicked: {
                                eraserButton.active = false;
                            }
                        }
                        Common.ImageButton {
                            width: size
                            height: size

                            image: 'washing-36666'
                            size: buttonsRow.height
                            onClicked: lineWidthDialog.open()
                        }
                        Common.ImageButton {
                            width: size
                            height: size
                            size: buttonsRow.height
                            image: 'palette-23406'
                            onClicked: colourSelectorDialog.open()

                            color: zoomCanvas.strokeColor
                        }

                        Common.ImageButton {
                            id: eraserButton

                            width: size
                            height: size

                            property bool active: false

                            size: buttonsRow.height
                            image: 'erase-34105'
                            onClicked: {
                                eraserButton.active = true;
                            }
                        }

                        Button {
                            id: eraserWidthButton
                            width: units.fingerUnit * 2

                            height: buttonsRow.height
                            text: qsTr('Mida')
                            onClicked: eraserWidthDialog.open();
                        }
                        Common.ImageButton {
                            width: size
                            height: size

                            size: buttonsRow.height
                            image: 'undo-97591'
                            enabled: canvasHistory.canUndo
                            color: (enabled)?'white':'gray'
                            onClicked: {
                                zoomCanvas.lastSubImage = canvasHistory.setPreviousCanvas();
                                zoomCanvas.resetBackground = true;
                                zoomCanvas.canvasImageNeedsToBeSaved = true;
                                zoomCanvas.requestPaint();
                            }
                        }
                        Common.ImageButton {
                            width: size
                            height: size
                            size: buttonsRow.height
                            image: 'redo-97589'
                            enabled: canvasHistory.canRedo
                            color: (enabled)?'white':'gray'
                            onClicked: {
                                zoomCanvas.lastSubImage = canvasHistory.setNextCanvas(zoomCanvas);
                                zoomCanvas.canvasImageNeedsToBeSaved = true;
                                zoomCanvas.requestPaint();
                            }
                        }
                        Common.ImageButton {
                            width: size
                            height: size
                            size: buttonsRow.height
                            image: 'zoom-27958'
                            onClicked: {
                                zoomSelectorDialog.open();
                            }
                        }
                    }
                }

                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: size
                    size: buttonsRow.height
                    image: 'floppy-35952'
                    color: (zoomCanvas.canvasHistoryIndex == 0)?'grey':'white'
                    onClicked: {
                        imageFile.source = selectedFile;
                        imageFile.addExtension("png");
                        confirmSaveDialog.open();
                    }
                }
            }
        }

        Item {
            id: canvasSubArea

            Layout.fillHeight: true
            Layout.fillWidth: true

            property real factor: Math.min(parent.width / rectangle.width, parent.height / rectangle.height)

            CanvasHistory {
                id: canvasHistory
            }

            Canvas {
                id: zoomCanvas

                anchors {
                    top: parent.top
                    left: parent.left
                }

                scale: parent.factor
                transformOrigin: Item.TopLeft

                width: parent.width / parent.factor
                height: parent.height / parent.factor

                property var points: []
                property real lineWidth: units.nailUnit
                property real eraserWidth: units.nailUnit * 3
                property string strokeColor: '#000000'

                property bool firstTime: true
                property bool backgroundLoaded: false

                property bool drawToolSelected: pencilButton.active
                property bool canvasImageNeedsToBeSaved: false

                property bool putCanvasIntoHistory: false
                property bool resetBackground: false
                property var lastSubImage: null

                MouseArea {
                    id: mousePointer

                    anchors.fill: parent

                    onPressed: {
                        var maxX = zoomCanvas.width;
                        var maxY = zoomCanvas.height;

                        if ((mouse.x>=0) && (mouse.y>=0) && (mouse.x<maxX) && (mouse.y<maxY)) {
                            mouse.accepted = true;
                            zoomCanvas.points = [];
                            zoomCanvas.points.push(Qt.point(mouse.x, mouse.y));
                            zoomCanvas.requestPaint();
                        }
                    }
                    onPositionChanged: {
                        var maxX = zoomCanvas.width;
                        var maxY = zoomCanvas.height;

                        if ((mouse.x>=0) && (mouse.y>=0) && (mouse.x<maxX) && (mouse.y<maxY)) {
                            console.log('new point', mouse.x, mouse.y);
                            zoomCanvas.points.push(Qt.point(mouse.x, mouse.y));
                            if (eraserButton.active) {
                                eraseRect.reposition(mouse.x,mouse.y)
                                eraseRect.visible = true;
                            } else {
                                eraseRect.visible = false;
                            }
                            zoomCanvas.requestPaint();
                        } else {
                            eraseRect.visible = false;
                            if (eraserButton.active)
                                zoomCanvas.erasePoints();
                            else
                                zoomCanvas.paintPoints();

                            active = false;
                        }
                    }
                    onReleased: {
                        eraseRect.visible = false;
                        zoomCanvas.points.push(Qt.point(mouse.x, mouse.y));
                        if (eraserButton.active) {
                        }
                        else {
//                            zoomCanvas.paintPoints();
                        }
                        zoomCanvas.putCanvasIntoHistory = true;
                        zoomCanvas.requestPaint();
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


                onAvailableChanged: initCanvas()

                function initCanvas() {
                    var ctx = getContext("2d");
                    console.log('rect', rectangle.x, rectangle.y, rectangle.width, rectangle.height);
                    ctx.clearRect(0,0,zoomCanvas.width, zoomCanvas.height);
                    ctx.drawImage(basicImage, rectangle.x, rectangle.y, width, height, 0, 0, width, height);
                    lastSubImage = ctx.getImageData(0, 0, zoomCanvas.width, zoomCanvas.height);
                    putCanvasIntoHistory = true;
                }

                onPaint: {
                    console.log('painting');
                    var ctx = zoomCanvas.getContext("2d");

                    if (zoomCanvas.resetBackground) {
                        zoomCanvas.resetBackground = false;
                        ctx.clearRect(0,0,zoomCanvas.width, zoomCanvas.height);
                        zoomCanvas.points = [];
                        console.log('reset background');
                    }

                    if (lastSubImage != null) {
                        console.log('New put image data');
                        ctx.drawImage(lastSubImage, 0, 0);
                    }

                    if (drawToolSelected) {
                        var l = zoomCanvas.points.length;
                        if (l>0) {
                            drawSinglePoint(ctx, zoomCanvas.points[0]);

                            while (l>1) {
                                var point1 = zoomCanvas.points.shift();
                                drawLineBetweenTwoPoints(ctx, point1, zoomCanvas.points[0]);
                                l--;
                            }
                            drawSinglePoint(ctx, zoomCanvas.points[0]);
                        }
                    } else {
                        for (var i=0; i<points.length; i++) {
                            erasePoint(ctx, points[i]);
                        }
                    }

                    // Grab an image of the canvas for the next paint iteration

                    lastSubImage = ctx.getImageData(0, 0, zoomCanvas.width, zoomCanvas.height);
                    if (putCanvasIntoHistory) {
                        putCanvasIntoHistory = false;
                        canvasHistory.addCanvas(lastSubImage);
                    }

                    console.log('end painting');
                }

                function paintPoints() {
                    var ctx = zoomCanvas.getContext("2d");
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
                            var point1 = zoomCanvas.points[l-2];
                            var point2 = zoomCanvas.points[l-1];
                            drawSinglePoint(ctx,point1);
                            drawSinglePoint(ctx,point2);
                            drawLineBetweenTwoPoints(ctx,point1, point2);
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
                    ctx.drawImage(basicImage, rectangle.x + imageX, rectangle.y + imageY, imageWidth, imageHeight, imageX, imageY, imageWidth, imageHeight);
                }

                function clearCanvas() {
                    console.log('clear canvas');
                    canvasHistory.addCanvas(zoomCanvas.lastSubImage);
                    copyZoomToMainCanvas();
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
        id: temporaryCanvas

        // Object required to get the zoomCanvas contents, put them on the original image and then save the result into a file.

        property bool saveRequested: false

        visible: false

        function startConversion() {
            canvasSize.width = basicImage.implicitWidth;
            canvasSize.height = basicImage.implicitHeight;
            width = canvasSize.width;
            height = canvasSize.height;
            console.log('request paint');
            requestPaint();
        }

        onPaint: {
            console.log('painting...');
            var ctx = getContext("2d");
            ctx.drawImage(basicImage, 0, 0);
            var imageOnTop = zoomCanvas.lastSubImage;
            ctx.drawImage(imageOnTop, rectangle.x, rectangle.y);
        }

        onPainted: {
            if (!saveRequested) {
                saveRequested = true;
                var data = temporaryCanvas.toDataURL();
                imageFile.writePngImage(data);
                console.log('saved...');
                savedImageDialog.open();
                savedImage();
                saveRequested = false;
            }
        }
    }

    MessageDialog {
        id: confirmSaveDialog

        title: qsTr("Confirma desat d'imatge")

        text: qsTr("Es desarà la imatge sobre el fitxer «") + imageFile.source + qsTr("». Vols continuar?")

        standardButtons: StandardButton.Ok | StandardButton.Cancel

        onAccepted: {
            if (selectedFile !== '') {
                temporaryCanvas.startConversion();
            }
        }
    }

    MessageDialog {
        id: savedImageDialog

        title: qsTr("Imatge desada")

        text: qsTr("La imatge s'ha desada amb el nom «") + imageFile.source + qsTr("».")
    }
}
