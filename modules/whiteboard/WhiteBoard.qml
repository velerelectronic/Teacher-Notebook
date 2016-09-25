import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import FileIO 1.0
import 'qrc:///common' as Common
import 'qrc:///modules/files' as Files


Item {
    id: whiteBoardItem

    property string baseDirectory
    property string selectedFile

    Common.UseUnits {
        id: units
    }

    MouseArea {
        anchors.fill: parent
        onPressed: mouse.accepted = true;
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit
        spacing: units.nailUnit

        Item {
            Layout.preferredHeight: units.fingerUnit * 1.5
            Layout.fillWidth: true
            RowLayout {
                id: buttonsRow

                anchors.fill: parent
                spacing: units.nailUnit

                Common.ImageButton {
                    id: pencilButton

                    Layout.fillHeight: true
                    Layout.preferredWidth: size

                    property bool active: !eraserButton.active

                    image: 'pen-147569'
                    size: buttonsRow.height
                    onClicked: {
                        eraserButton.active = false;
                    }
                }
                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: size

                    image: 'washing-36666'
                    size: buttonsRow.height
                    onClicked: lineWidthDialog.open()
                }
                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: size
                    size: buttonsRow.height
                    image: 'palette-23406'
                    onClicked: colourSelectorDialog.open()

                    color: canvas.strokeColor
                }

                Common.ImageButton {
                    id: eraserButton

                    Layout.fillHeight: true
                    Layout.preferredWidth: size

                    property bool active: false

                    size: buttonsRow.height
                    image: 'erase-34105'
                    onClicked: {
                        eraserButton.active = true;
                    }
                }

                Button {
                    id: eraserWidthButton
                    Layout.fillHeight: true
                    text: qsTr('Mida')
                    onClicked: eraserWidthDialog.open();
                }
                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: size
                    size: buttonsRow.height
                    image: 'undo-97591'
                    color: (canvas.canvasHistoryIndex == 0)?'grey':'white'
                    onClicked: canvas.gotoPreviousCanvas()
                }
                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: size
                    size: buttonsRow.height
                    image: 'redo-97589'
                    color: (canvas.canvasHistoryIndex >= canvas.canvasHistoryLength)?'grey':'white'
                    onClicked: canvas.gotoNextCanvas()
                }

                Common.ImageButton {
                    id: moveToolButton

                    Layout.fillHeight: true
                    Layout.preferredWidth: size
                    size: buttonsRow.height
                    image: 'arrows-145992'
                    property bool active: false
                    color: (active)?'yellow':'white'
                    onClicked: {
                        moveToolButton.active = !moveToolButton.active;
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
                    color: (canvas.canvasHistoryIndex == 0)?'grey':'white'
                    onClicked: {
                        if (selectedFile !== '') {
                            console.log('Saving to', selectedFile);
                            console.log(canvas.toDataURL());
                            imageFile.source = selectedFile;
                            imageFile.write(canvas.toDataURL());
                        }
                    }
                }

                Button {
                    Layout.fillHeight: true
                    text: qsTr('Carrega')
                    onClicked: loadFileDialog.loadFile()
                }
                Button {
                    Layout.fillHeight: true
                    text: qsTr('Importa')
                    onClicked: loadFileDialog.importImage()
                }
            }
        }

        FileIO {
            id: imageFile
        }

        Flickable {
            id: flickableCanvas

            Layout.fillHeight: true
            Layout.fillWidth: true

            clip: true

            interactive: moveToolButton.active

            contentWidth: fullPage.width
            contentHeight: fullPage.height

            property real margins: Math.min(flickableCanvas.width, flickableCanvas.height) / 5

            leftMargin: flickableCanvas.margins
            rightMargin: flickableCanvas.margins
            topMargin: flickableCanvas.margins
            bottomMargin: flickableCanvas.margins

            onContentXChanged: canvas.canvasWindow = Qt.rect(contentX, contentY, fullPage.width, fullPage.height)
            onContentYChanged: canvas.canvasWindow = Qt.rect(contentX, contentY, fullPage.width, fullPage.height)

            Rectangle {
                id: fullPage
                color: 'white'
                width: units.fingerUnit * 5
                height: units.fingerUnit * 5

                Canvas {
                    id: canvas

                    anchors.fill: parent

                    property var points
                    property real lineWidth: units.nailUnit
                    property real eraserWidth: units.nailUnit * 3
                    property string strokeColor: '#000000'
                    property var initialImage

                    property var canvasHistory: []
                    property int canvasHistoryIndex: -1
                    property int canvasHistoryLength: canvasHistory.length
                    property bool firstRun: true

                    MouseArea {
                        id: mousePointer

                        anchors.fill: parent
                        enabled: !flickableCanvas.interactive

                        property bool active: false

                        onPressed: {
                            if ((mouse.x>=0) && (mouse.y>=0) && (mouse.x<canvas.width) && (canvas.y<canvas.height)) {
                                mouse.accepted = true;
                                canvas.points = [];
                                canvas.points.push(Qt.point(mouse.x, mouse.y));
                                active = true;
                            }
                        }
                        onPositionChanged: {
                            if (mousePointer.active) {
                                if ((mouse.x>=0) && (mouse.y>=0) && (mouse.x<canvas.width) && (canvas.y<canvas.height)) {
                                    canvas.points.push(Qt.point(mouse.x, mouse.y));
                                    if (eraserButton.active) {
                                        eraseCircle.reposition(mouse.x,mouse.y)
                                        eraseCircle.visible = true;
                                        canvas.erasePoints();
                                    } else {
                                        eraseCircle.visible = false;
                                        canvas.paintPoints();
                                    }
                                } else {
                                    eraseCircle.visible = false;
                                    if (eraserButton.active)
                                        canvas.erasePoints();
                                    else
                                        canvas.paintPoints();

                                    active = false;
                                    canvas.addCanvasToHistory();
                                }
                            }
                        }
                        onReleased: {
                            eraseCircle.visible = false;
                            if (eraserButton.active)
                                canvas.erasePoints();
                            else
                                canvas.paintPoints();

                            active = false;
                            canvas.addCanvasToHistory();
                        }

                    }


                    Rectangle {
                        id: eraseCircle

                        visible: false
                        border.color: 'black'
                        color: 'transparent'
                        width: canvas.eraserWidth * 2
                        height: canvas.eraserWidth * 2
                        radius: canvas.eraserWidth

                        function reposition(x,y) {
                            eraseCircle.x = x - eraseCircle.width / 2
                            eraseCircle.y = y - eraseCircle.height / 2
                        }
                    }

                    function paintPoints() {
                        var ctx = canvas.getContext("2d");
                        //ctx.fillStyle = Qt.rgba(1, 0, 0, 1);

                        var l = canvas.points.length;
                        switch(l) {
                        case 0:
                            break;
                        case 1:
                            drawSinglePoint(ctx,points[0]);
                            break;
                        default:
                            var point1 = canvas.points[l-2];
                            var point2 = canvas.points[l-1];
                            drawSinglePoint(ctx,point1);
                            drawSinglePoint(ctx,point2);
                            ctx.beginPath();
                            ctx.lineWidth = canvas.lineWidth;
                            ctx.lineJoin = "round";
                            ctx.strokeStyle = canvas.strokeColor;
                            ctx.moveTo(point1.x, point1.y);
                            ctx.lineTo(point2.x, point2.y);
                            ctx.stroke();
                            var left = Math.min(point1.x, point2.x);
                            var top = Math.min(point1.y,point2.y);
                            var width = Math.max(point1.x, point2.x) - left;
                            var height = Math.max(point1.y, point2.y) - top;

                            markDirty(Qt.rect(left, top, width, height));
                        }
                    }

                    function drawSinglePoint(ctx,point) {
                        ctx.beginPath();
                        ctx.lineWidth = canvas.lineWidth / 2;
                        ctx.lineJoin = "round";
                        ctx.strokeStyle = canvas.strokeColor;
                        ctx.fillStyle = canvas.strokeColor;
                        ctx.arc(point.x, point.y, canvas.lineWidth/4, 0, 2 * Math.PI);
                        ctx.stroke();
                        markDirty(Qt.rect(point.x-canvas.lineWidth/2,point.y-canvas.lineWidth/2,canvas.lineWidth,canvas.lineWidth));
                    }

                    function erasePoints() {
                        var ctx = canvas.getContext("2d");

                        var singlePoint = points[canvas.points.length-1];
                        ctx.beginPath();
                        ctx.lineWidth = canvas.eraserWidth;
                        ctx.lineJoin = "round";
                        ctx.strokeStyle = '#FFFFFF';
                        ctx.fillStyle = '#FFFFFF';
                        ctx.arc(singlePoint.x, singlePoint.y, canvas.eraserWidth / 2, 0, 2 * Math.PI);
                        ctx.stroke();
                        markDirty(Qt.rect(singlePoint.x-canvas.eraserWidth,singlePoint.y-canvas.eraserWidth,10,10));
                    }

                    function loadContents() {
                        imageFile.source = selectedFile;
                        canvasImage.source = imageFile.read();
                        //canvas.initialImage = canvas.loadImage(selectedFile);
                    }

                    Connections {
                        target: canvasImage

                        onCanvasImageLoaded: canvas.loadCanvasFromLoadedImage()
                    }

                    function loadCanvasFromLoadedImage() {
                        var ctx = canvas.getContext("2d");
                        ctx.clearRect(0,0,canvas.width,canvas.height);
                        ctx.drawImage(canvasImage, 0, 0);
                        markDirty(Qt.rect(0,0,canvas.width,canvas.height));
                        addCanvasToHistory();
                    }

                    function importImage(imageSource) {
                        canvasImage.source = imageSource;
//                        canvas.loadImage(imageSource);
                    }

                    function addCanvasToHistory() {
                        while (canvas.canvasHistoryIndex < canvas.canvasHistory.length-1) {
                            canvas.canvasHistory.pop();
                        }

                        var data = canvas.toDataURL('image/png');

                        canvas.canvasHistory.push(data);
                        canvas.canvasHistoryIndex = canvas.canvasHistoryIndex + 1;
                        canvas.canvasHistoryLength = canvas.canvasHistory.length;
                    }

                    function gotoPreviousCanvas() {
                        if (canvas.canvasHistoryIndex>0) {
                            canvas.canvasHistoryIndex = canvas.canvasHistoryIndex - 1;
                            canvasImage.source = canvas.canvasHistory[canvas.canvasHistoryIndex];
                        }
                    }

                    function gotoNextCanvas() {
                        if (canvas.canvasHistoryIndex < canvas.canvasHistoryLength-1) {
                            canvas.canvasHistoryIndex = canvas.canvasHistoryIndex + 1;
                            canvasImage.source = canvas.canvasHistory[canvas.canvasHistoryIndex];
                        }
                    }

                    function clearCanvas() {
                        var ctx = canvas.getContext("2d");
                        ctx.clearRect(0,0,canvas.width,canvas.height);
                        markDirty(Qt.rect(0,0,canvas.width,canvas.height));
                        importImage(selectedFile);
                    }

                    onImageLoaded: {
                        var ctx = canvas.getContext("2d");
                        ctx.drawImage(canvasImage, 0, 0);
                        markDirty(Qt.rect(0,0,canvas.width,canvas.height));
                        addCanvasToHistory();
                    }

                    onAvailableChanged: {
                        if ((available) && (firstRun)) {
                            firstRun = false;
                            clearCanvas();
                        }
                    }
                }
            }

        }

    }

    Image {
        id: canvasImage

        visible: false

        signal canvasImageLoaded()

        fillMode: Image.Pad

        onStatusChanged: {
            if (canvasImage.status == Image.Ready) {
                var newW = canvasImage.sourceSize.width;
                var newH = canvasImage.sourceSize.height;
                console.log('new WxH', newW, newH);
                if (fullPage.width < newW) {
                    fullPage.width = newW;
                }

                if (fullPage.height < newH) {
                    fullPage.height = newH;
                }

                canvas.canvasSize = Qt.size(newW, newH);

                canvasImageLoaded();
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
                canvas.lineWidth = units.nailUnit;
                lineWidthDialog.close();
            }
        }
        Common.SuperposedMenuEntry {
            text: qsTr('Mida **')
            onClicked: {
                canvas.lineWidth = units.nailUnit * 2;
                lineWidthDialog.close();
            }
        }
        Common.SuperposedMenuEntry {
            text: qsTr('Mida ***')
            onClicked: {
                canvas.lineWidth = units.nailUnit * 3;
                lineWidthDialog.close();
            }
        }
        Common.SuperposedMenuEntry {
            text: qsTr('Mida ****')
            onClicked: {
                canvas.lineWidth = units.nailUnit * 4;
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
                canvas.eraserWidth = units.nailUnit;
                eraserWidthDialog.close();
            }
        }
        Common.SuperposedMenuEntry {
            text: qsTr('Mida **')
            onClicked: {
                canvas.eraserWidth = units.nailUnit * 2;
                eraserWidthDialog.close();
            }
        }
        Common.SuperposedMenuEntry {
            text: qsTr('Mida ***')
            onClicked: {
                canvas.eraserWidth = units.nailUnit * 3;
                eraserWidthDialog.close();
            }
        }
        Common.SuperposedMenuEntry {
            text: qsTr('Mida ****')
            onClicked: {
                canvas.eraserWidth = units.nailUnit * 4;
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
                    canvas.strokeColor = parent.color;
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
                    canvas.strokeColor = parent.color;
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
                    canvas.strokeColor = parent.color;
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
                    canvas.strokeColor = parent.color;
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
                    canvas.strokeColor = parent.color;
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
                    canvas.strokeColor = parent.color;
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
                    canvas.strokeColor = parent.color;
                    colourSelectorDialog.close();
                }
            }
        }
    }

    Common.SuperposedWidget {
        id: loadFileDialog

        title: qsTr('Carrega fitxer')

        property bool importFile: false

        function loadFile() {
            load(qsTr('Carrega fitxer'), 'files/FileSelector', {initialDirectory: baseDirectory, selectFiles: true});
            importFile = false;
        }

        function importImage() {
            load(qsTr('Importa una imatge'), 'files/FileSelector', {initialDirectory: baseDirectory, selectFiles: true});
            importFile = true;
        }

        Connections {
            target: loadFileDialog.mainItem

            onFileSelected: {
                if (loadFileDialog.importFile) {
                    if (selectedFile == '')
                        selectedFile = file;
                    loadFileDialog.close();
                    canvas.importImage(file);
                } else {
                    whiteBoardItem.selectedFile = file;
                    loadFileDialog.close();
                    canvas.loadContents();
                }
            }
        }
    }

}
