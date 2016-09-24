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

    Rectangle {
        anchors.centerIn: parent

        border.color: 'black'
        width: Math.min(parent.width, parent.height)
        height: width * 0.75 // 4:3 ratio

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

                    Button {
                        id: pencilButton

                        Layout.fillHeight: true
                        text: qsTr('Llapis')
                        checkable: true
                        checked: true
                        onCheckedChanged: {
                            if (pencilButton.checked)
                                eraserButton.checked = false;
                        }
                    }
                    Common.ImageButton {
                        Layout.fillHeight: true
                        Layout.preferredWidth: size
                        image: 'paintbrush-153754'
                        size: buttonsRow.height
                        onClicked: lineWidthDialog.open()
                    }
                    Common.ImageButton {
                        Layout.fillHeight: true
                        Layout.preferredWidth: size
                        size: buttonsRow.height
                        image: 'palette-23406'
                        onClicked: colourSelectorDialog.open()
                    }

                    Button {
                        id: eraserButton
                        Layout.fillHeight: true
                        text: qsTr('Goma')
                        checkable: true
                        onCheckedChanged: {
                            if (eraserButton.checked)
                                pencilButton.checked = false;
                        }
                    }
                    Button {
                        id: eraserWidthButton
                        Layout.fillHeight: true
                        text: qsTr('Mida')
                        onClicked: eraserWidthDialog.open();
                    }
                    Text {
                        id: fileNameText

                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }
                    Button {
                        text: qsTr('Desa')
                        Layout.fillHeight: true
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

            Image {
                id: canvasImage

                visible: false
                onStatusChanged: {
                    if (canvasImage.status == Image.Ready)
                        canvas.loadCanvasImage();
                }
            }

            FileIO {
                id: imageFile
            }

            Canvas {
                id: canvas
                Layout.fillHeight: true
                Layout.fillWidth: true

                clip: true

                property var points
                property real lineWidth: units.nailUnit
                property real eraserWidth: units.nailUnit * 3
                property string strokeColor: '#000000'
                property var initialImage
                property string importedFile

                MouseArea {
                    id: mousePointer

                    anchors.fill: parent

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
                                if (eraserButton.checked) {
                                    eraseCircle.reposition(mouse.x,mouse.y)
                                    eraseCircle.visible = true;
                                    canvas.erasePoints();
                                } else {
                                    eraseCircle.visible = false;
                                    canvas.paintPoints();
                                }
                            }
                        }
                    }
                    onReleased: {
                        eraseCircle.visible = false;
                        if (eraserButton.checked)
                            canvas.erasePoints();
                        else
                            canvas.paintPoints();

                        active = false;
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

                function loadCanvasImage() {
                    console.log('image loaded');
                    var ctx = canvas.getContext("2d");
                    ctx.drawImage(canvasImage, 0, 0);
//                    ctx.stroke();
                    markDirty(Qt.rect(0,0,canvas.width,canvas.height));
                }

                function importImage(imageSource) {
                    canvas.importedFile = imageSource;
                    canvas.loadImage(imageSource);
                }

                onImageLoaded: {
                    var ctx = canvas.getContext("2d");
                    ctx.drawImage(canvas.importedFile, 0, 0);
                    markDirty(Qt.rect(0,0,canvas.width,canvas.height));
                }
            }
        }

    }

    Common.SuperposedMenu {
        id: lineWidthDialog

        title: qsTr('Gruixa del llapis')

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
