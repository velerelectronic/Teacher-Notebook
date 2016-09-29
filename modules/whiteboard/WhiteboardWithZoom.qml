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

                cache: false

                property real factor: Math.min(mainCanvas.width / Math.max(mainCanvas.implicitWidth,1), mainCanvas.height / Math.max(mainCanvas.implicitHeight,1))

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
                            enabled: zoomCanvas.canvasHistoryIndex > 0
                            color: (enabled)?'white':'gray'
                            onClicked: {
                                zoomCanvas.gotoPreviousCanvas();
                            }
                        }
                        Common.ImageButton {
                            width: size
                            height: size
                            size: buttonsRow.height
                            image: 'redo-97589'
                            enabled: zoomCanvas.canvasHistoryIndex < zoomCanvas.canvasHistoryLength
                            color: (enabled)?'white':'gray'
                            onClicked: {
                                zoomCanvas.gotoNextCanvas();
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

                property var canvasHistory: []
                property var canvasHistory2: []
                property int canvasHistoryIndex: -1
                property int canvasHistoryLength: canvasHistory.length
                property bool backgroundLoaded: false

                onImageLoaded: {
                    loadBackgroundImage();
                    addCanvasToHistory();
                }

                function loadBackgroundImage() {
                    console.log('about to load background');
                    if (!backgroundLoaded) {
                        loadImage(selectedFile);
                        console.log('loading background');
                        var ctx = zoomCanvas.getContext("2d");
                        ctx.save();
                        ctx.drawImage(canvasImage, 0, 0, canvasImage.implicitWidth, canvasImage.implicitHeight);
                        ctx.restore();
                        requestPaint();
                        backgroundLoaded = true;
                    }
                }

                MouseArea {
                    id: mousePointer

                    anchors.fill: parent

                    property bool active: false

                    onPressed: {
                        var maxX = zoomCanvas.width;
                        var maxY = zoomCanvas.height;

                        if ((mouse.x>=0) && (mouse.y>=0) && (mouse.x<maxX) && (mouse.y<maxY)) {
                            console.log('hola', mouse.x, mouse.y);
                            mouse.accepted = true;
                            zoomCanvas.points = [];
                            zoomCanvas.points.push(Qt.point(mouse.x, mouse.y));
                            active = true;
                            copyCanvasTimer.stop();
                        }
                    }
                    onPositionChanged: {
                        if (mousePointer.active) {
                            var maxX = zoomCanvas.width;
                            var maxY = zoomCanvas.height;

                            if ((mouse.x>=0) && (mouse.y>=0) && (mouse.x<maxX) && (mouse.y<maxY)) {
                                zoomCanvas.points.push(Qt.point(mouse.x, mouse.y));
                                if (eraserButton.active) {
                                    eraseCircle.reposition(mouse.x,mouse.y)
                                    eraseCircle.visible = true;
                                    zoomCanvas.erasePoints();
                                } else {
                                    eraseCircle.visible = false;
                                    zoomCanvas.paintPoints();
                                }
                            } else {
                                eraseCircle.visible = false;
                                if (eraserButton.active)
                                    zoomCanvas.erasePoints();
                                else
                                    zoomCanvas.paintPoints();

                                active = false;
                            }
                        }
                    }
                    onReleased: {
                        eraseCircle.visible = false;
                        if (eraserButton.active)
                            zoomCanvas.erasePoints();
                        else
                            zoomCanvas.paintPoints();

                        active = false;
                        copyCanvasTimer.restart();
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

                    var mainCtx = mainCanvas2.getContext("2d");
                    mainCtx.putImageData(imageData, 0, 0, 0, 0, mainCanvas2.width, mainCanvas2.height);
                    mainCanvas2.requestPaint();
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
                    ctx.lineWidth = zoomCanvas.lineWidth / 2 / scale;
                    ctx.lineJoin = "round";
                    ctx.strokeStyle = zoomCanvas.strokeColor;
                    ctx.fillStyle = zoomCanvas.strokeColor;
                    ctx.arc(point.x, point.y, zoomCanvas.lineWidth/4 / scale, 0, 2 * Math.PI);
                    ctx.stroke();
                    markDirty(Qt.rect(point.x-zoomCanvas.lineWidth/2 / scale,point.y-zoomCanvas.lineWidth/2/scale,zoomCanvas.lineWidth/scale,zoomCanvas.lineWidth/scale));
                }

                function drawLineBetweenTwoPoints(ctx,point1,point2) {
                    ctx.beginPath();
                    ctx.lineWidth = zoomCanvas.lineWidth / scale;
                    ctx.lineJoin = "round";
                    ctx.strokeStyle = zoomCanvas.strokeColor;
                    ctx.moveTo(point1.x, point1.y);
                    ctx.lineTo(point2.x, point2.y);
                    ctx.stroke();
                    var left = Math.min(point1.x, point2.x);
                    var top = Math.min(point1.y,point2.y);
                    var width = Math.max(point1.x, point2.x) - left;
                    var height = Math.max(point1.y, point2.y) - top;

                    markDirty(Qt.rect(left, top, width, height));
                }

                function erasePoints() {
                    var ctx = zoomCanvas.getContext("2d");

                    var singlePoint = points[zoomCanvas.points.length-1];
                    ctx.beginPath();
                    ctx.lineWidth = zoomCanvas.eraserWidth / scale;
                    ctx.lineJoin = "round";
                    ctx.strokeStyle = '#FFFFFF';
                    ctx.fillStyle = '#FFFFFF';
                    ctx.arc(singlePoint.x, singlePoint.y, zoomCanvas.eraserWidth / 2, 0, 2 * Math.PI);
                    ctx.stroke();
                    markDirty(Qt.rect(singlePoint.x-zoomCanvas.eraserWidth,singlePoint.y-zoomCanvas.eraserWidth,10,10));
                }

                function addCanvasToHistory() {
                    while (zoomCanvas.canvasHistoryIndex < zoomCanvas.canvasHistory.length-1) {
                        zoomCanvas.canvasHistory.pop();
                    }

                    copyZoomToMainCanvas();

                    zoomCanvas.canvasHistory.push(data);
                    var newLength = zoomCanvas.canvasHistory.length;
                    zoomCanvas.canvasHistoryLength = newLength;
                    zoomCanvas.canvasHistoryIndex = newLength-1;
                }

                function gotoPreviousCanvas() {
                    console.log('current history', zoomCanvas.canvasHistoryIndex);
                    if (zoomCanvas.canvasHistoryIndex>0) {
                        var newIndex = zoomCanvas.canvasHistoryIndex - 1;
                        zoomCanvas.canvasHistoryIndex = newIndex;
                        var data = zoomCanvas.canvasHistory[newIndex];
                        mainCanvas.source = data;
                        canvasImage.source = data;

                        /*
                        var data = canvasHistory2.pop();
                        var ctx = getContext("2d");
                        ctx.drawImage(data, 0, 0, width, height);
                        */

                        requestPaint();
                        console.log('next history', zoomCanvas.canvasHistoryIndex);
                    }
                }

                function gotoNextCanvas() {
                    console.log('current history', zoomCanvas.canvasHistoryIndex);
                    if (zoomCanvas.canvasHistoryIndex < zoomCanvas.canvasHistoryLength-1) {
                        zoomCanvas.canvasHistoryIndex = zoomCanvas.canvasHistoryIndex + 1;
                        var data = zoomCanvas.canvasHistory[zoomCanvas.canvasHistoryIndex];
                        mainCanvas.source = data;
                        canvasImage.source = data;
                        requestPaint();
                        console.log('next history', zoomCanvas.canvasHistoryIndex);
                    }
                }

                function clearCanvas() {
                    copyCanvasTimer.stop();
                    console.log('clear canvas');
                    addCanvasToHistory();
                }

                onAvailableChanged: {
                    if (available) {
                        clearCanvas();
                    }
                }

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

        onTriggered: {
            zoomCanvas.addCanvasToHistory();
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
        canvasImage.source = '';
        canvasImage.source = selectedFile;
//        mainCanvas.source = zoomCanvas.toDataURL();
    }
}
