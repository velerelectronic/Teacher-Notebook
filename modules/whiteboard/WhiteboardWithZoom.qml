import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtQml.Models 2.2
import FileIO 1.0
import 'qrc:///common' as Common
import 'qrc:///modules/files' as Files

Item {
    id: whiteboardWithZoom

    property real mainWhiteboardHeight: height / 2
    property string selectedFile

    signal savedImage()

    Common.UseUnits {
        id: units
    }

    ColumnLayout {
        id: mainColumnLayout

        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: mainCanvasRect

            Layout.preferredHeight: mainWhiteboardHeight
            Layout.fillWidth: true

            color: 'grey'

            Image {
                id: mainCanvas

                visible: true
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit

//                cache: false

                property real factor: Math.min(mainCanvas.width / Math.max(mainCanvas.implicitWidth,1), mainCanvas.height / Math.max(mainCanvas.implicitHeight,1))
                //property real factor: Math.min(mainCanvas.width / Math.max(zoomCanvas.width,1), mainCanvas.height / Math.max(zoomCanvas.height,1))

                onFactorChanged: console.log('factor mainCanvas', factor)

                Item {
                    id: allowableRegion

                    anchors.centerIn: mainCanvas
                    width: mainCanvas.implicitWidth * mainCanvas.factor
                    height: mainCanvas.implicitHeight * mainCanvas.factor


                    Rectangle {
                        id: selectionRect

                        width: zoomCanvasArea.width * mainCanvas.factor / zoomCanvas.scale
                        height: zoomCanvasArea.height * mainCanvas.factor / zoomCanvas.scale

                        border.color: 'black'
                        color: 'transparent'
                    }
                    MouseArea {
                        anchors.fill: allowableRegion

                        function repositionZoomRectangle(posX,posY) {
                            selectionRect.x = Math.max(0, Math.min(allowableRegion.width - selectionRect.width,posX - selectionRect.width / 2));
                            selectionRect.y = Math.max(0, Math.min(allowableRegion.height - selectionRect.height,posY - selectionRect.height / 2));

                            //var factor = Math.max(zoomCanvas.canvasSize.width / allowableRegion.width, zoomCanvas.canvasSize.height / allowableRegion.height);
                            var factor = zoomCanvas.width / allowableRegion.width;

                            zoomCanvas.x = (-selectionRect.x / mainCanvas.factor) * zoomCanvas.scale;
                            zoomCanvas.y = (-selectionRect.y / mainCanvas.factor) * zoomCanvas.scale;
                        }

                        onPressed: {
                            mouse.accepted = true;
                            repositionZoomRectangle(mouse.x, mouse.y);
                        }
                        onPositionChanged: {
                            repositionZoomRectangle(mouse.x, mouse.y);
                        }
                        onReleased: {
                            repositionZoomRectangle(mouse.x, mouse.y);
                        }
                    }

                }
            }
        }

        Rectangle {
            id: separatorRowBar

            Layout.preferredHeight: units.fingerUnit * 1.5
            Layout.fillWidth: true

            RowLayout {
                id: buttonsRow

                anchors.fill: parent
                anchors.margins: units.nailUnit

                ListView {
                    Layout.fillHeight: true
                    Layout.preferredWidth: Math.min(parent.width / 3, contentItem.width)

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
                                copyCanvasTimer.stop();
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
                                copyCanvasTimer.stop();
                                zoomCanvas.lastSubImage = canvasHistory.setNextCanvas(zoomCanvas, mainCanvas);
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
                Text {
                    id: fileNameText

                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: selectedFile
                }
                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: size
                    size: buttonsRow.height
                    image: 'floppy-35952'
                    color: (zoomCanvas.canvasHistoryIndex == 0)?'grey':'white'
                    onClicked: {
                        if (selectedFile !== '') {
                            console.log('saving');
                            saveFile.source = selectedFile;
                            var data = zoomCanvas.toDataURL();
                            saveFile.addExtension("png");
                            saveFile.writePngImage(data);
                            mainCanvas.source = data;
                            savedImage();
                        }
                    }

                    FileIO {
                        id: saveFile
                    }
                }

                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: contentWidth
                    text: qsTr('Mou')
                    font.pixelSize: units.readUnit
                    verticalAlignment: Text.AlignVCenter
                    MouseArea {
                        id: moveToolArea

                        anchors.fill: parent

                        property int initialMouseHeight: null

                        onPressed: {
                            mouse.accepted = true;
                            initialMouseHeight = mouse.y;
                        }

                        onPositionChanged: {
                            calculateNewHeight(mouse.y);
                        }

                        onReleased: {
                            calculateNewHeight(mouse.y);
                        }

                        function calculateNewHeight(mouseY) {
                            var diff = mouseY - initialMouseHeight;
                            var newHeight =  mainWhiteboardHeight + diff;
                            if ((newHeight >= 0) && (newHeight + separatorRowBar.height < mainColumnLayout.height)) {
                                mainWhiteboardHeight = newHeight;
                            } else {
                                if (newHeight < 0)
                                    mainWhiteboardHeight = 0;
                                else
                                    mainWhiteboardHeight = mainColumnLayout.height - separatorRowBar.height;
                            }
                        }
                    }
                }
            }


        }

        Rectangle {
            id: zoomCanvasArea

            Layout.fillHeight: true
            Layout.fillWidth: true

            color: 'yellow'

            clip: true

            CanvasHistory {
                id: canvasHistory
            }

            Canvas {
                id: zoomCanvas

                z: 10
                width: canvasImage.implicitWidth
                height: canvasImage.implicitHeight

                scale: 1

                transformOrigin: Item.TopLeft

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

                Image {
                    id: canvasSubImage
                }

                onImageLoaded: {
                    console.log('image loaded');

                    var ctx = zoomCanvas.getContext("2d");
                    ctx.save();
                    ctx.drawImage(canvasImage, 0, 0, canvasImage.implicitWidth, canvasImage.implicitHeight);
                    ctx.restore();
                    zoomCanvas.lastSubImage = null;
                    putCanvasIntoHistory = true;

                    zoomCanvas.requestPaint();
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

                    lastSubImage = ctx.getImageData(0, 0, zoomCanvas.width, zoomCanvas.height);
                    if (putCanvasIntoHistory) {
                        putCanvasIntoHistory = false;
                        canvasHistory.addCanvas(lastSubImage);
                    }

                    copyCanvasTimer.restart();
                    console.log('end painting');
                }

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
                                eraseCircle.reposition(mouse.x,mouse.y)
                                eraseCircle.visible = true;
                            } else {
                                eraseCircle.visible = false;
                            }
                            zoomCanvas.requestPaint();
                        } else {
                            eraseCircle.visible = false;
                            if (eraserButton.active)
                                zoomCanvas.erasePoints();
                            else
                                zoomCanvas.paintPoints();

                            active = false;
                        }
                    }
                    onReleased: {
                        eraseCircle.visible = false;
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
                    id: eraseCircle

                    visible: false
                    border.color: 'black'
                    color: 'transparent'
                    width: zoomCanvas.eraserWidth * 2
                    height: zoomCanvas.eraserWidth * 2
                    radius: zoomCanvas.eraserWidth

                    function reposition(x,y) {
                        eraseCircle.x = x - eraseCircle.width / 2
                        eraseCircle.y = y - eraseCircle.height / 2
                    }
                }

                function copyZoomToMainCanvas() {
                    /*
                    var zoomCtx = zoomCanvas.getContext("2d");
                    var imageData = zoomCtx.getImageData(0,0,zoomCanvas.width,zoomCanvas.height);

                    var mainCtx = mainCanvas.getContext("2d");
                    mainCtx.putImageData(imageData, 0, 0, 0, 0, mainCanvas.width, mainCanvas.height);
                    mainCanvas.requestPaint();
                    */

                    mainCanvas.source = zoomCanvas.toDataURL();
                }

                function paintPoints() {
                    var ctx = zoomCanvas.getContext("2d");
                    //ctx.fillStyle = Qt.rgba(1, 0, 0, 1);

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

                function clearCanvas() {
                    copyCanvasTimer.stop();
                    console.log('clear canvas');
                    canvasHistory.addCanvas(zoomCanvas.lastSubImage);
                    copyZoomToMainCanvas();
                }

                /*
                onAvailableChanged: {
                    if (available) {
                        clearCanvas();
                    }
                }
                */

                /*
//                    var ctx = getContext("2d");
                    var ctx = zoomCanvas.getContext("2d");
                    //ctx.clearRect(0,0,zoomCanvas.width,zoomCanvas.height);
                    ctx.drawImage(canvasImage, 0, 0, canvasImage.implicitWidth, canvasImage.implicitHeight);
//                    requestPaint();
                    canvasHistory2.push(data);
                }
                */

            }

        }

    }

    Timer {
        id: copyCanvasTimer

        interval: 500
        repeat: false

        onTriggered: {
//            canvasHistory.addCanvas(zoomCanvas.lastSubImage);
            zoomCanvas.copyZoomToMainCanvas();
        }
    }

    Image {
        id: canvasImage

        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        visible: false

        cache: false
        asynchronous: false

        onStatusChanged: {
            console.log('selected file', canvasImage.source);
            console.log('image status', status);
            switch(status) {
            case Image.Null:
                console.log('image status Null', status);
                break;
            case Image.Ready:
                console.log('image status Ready', status);
                break;
            case Image.Loading:
                console.log('image status Loading', status);
                break;
            case Image.Error:
                console.log('image status Error', status);
                break;
            default:
                console.log('image status NOT SPECIFIED', status);
            }

            if (status == Image.Ready) {
                zoomCanvas.width = canvasImage.implicitWidth;
                zoomCanvas.height = canvasImage.implicitHeight;
                zoomCanvas.loadImage(selectedFile);
            }
        }
    }

    Common.SuperposedMenu {
        id: lineWidthDialog

        title: qsTr('Gruixa del llapis')
        parentWidth: whiteboardWithZoom.width
        parentHeight: whiteboardWithZoom.height

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
        parentWidth: whiteboardWithZoom.width
        parentHeight: whiteboardWithZoom.height

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
        parentWidth: whiteboardWithZoom.width
        parentHeight: whiteboardWithZoom.height

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
        parentWidth: whiteboardWithZoom.width
        parentHeight: whiteboardWithZoom.height

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

    Component.onCompleted: {
        canvasImage.source = selectedFile;
//        mainCanvas.source = zoomCanvas.toDataURL();
    }
}
