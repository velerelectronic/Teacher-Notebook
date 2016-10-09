import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import 'qrc:///common' as Common

Item {
    id: imageBoardItem

    property string selectedFile: ''

    signal publishMessage(string message)

    Image {
        id: fileImage

        anchors.fill: parent
        source: selectedFile
        cache: false
        fillMode: Image.PreserveAspectFit

        property real factor: Math.min(width / Math.max(implicitWidth, 1), height / Math.max(implicitHeight, 1))
        property real expandedWidth: implicitWidth * factor
        property real expandedHeight: implicitHeight * factor

        Item {
            id: availableArea

            anchors.centerIn: parent
            width: parent.expandedWidth
            height: parent.expandedHeight

            MouseArea {
                anchors.fill: parent
                onPressed: {
                    mouse.accepted = true;
                    selectionRect.visible = true;
                    selectionRect.initDimensions(mouse.x, mouse.y);
                }
                onPositionChanged: {
                    var posX = Math.max(0, Math.min(availableArea.width, mouse.x));
                    var posY = Math.max(0, Math.min(availableArea.height, mouse.y));
                    selectionRect.redimensionate(posX, posY);
                }
                onReleased: {
                    var posX = Math.max(0, Math.min(availableArea.width, mouse.x));
                    var posY = Math.max(0, Math.min(availableArea.height, mouse.y));
                    selectionRect.redimensionate(posX, posY);
                }
            }
            Rectangle {
                id: selectionRect

                border.color: 'black'
                color: 'transparent'

                function initDimensions(xDim, yDim) {
                    x = xDim;
                    y = yDim;
                    width = 0;
                    height = 0;
                }

                function redimensionate(xDim, yDim) {
                    if (xDim < x) {
                        width = width + x - xDim;
                        x = xDim;
                    }
                    if (yDim < y) {
                        height = height + y - yDim;
                        y = yDim;
                    }
                    if (xDim > x + width) {
                        width = xDim-x;
                    }
                    if (yDim > y + height) {
                        height = yDim - y;
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        superposedZoomDialog.openZoom();
                    }
                }
            }

        }
    }

    Common.SuperposedWidget {
        id: superposedZoomDialog

        function openZoom() {
            load(qsTr('Edita fragment'), 'whiteboard/WhiteBoard', {rectangle: Qt.rect(selectionRect.x / fileImage.factor, selectionRect.y / fileImage.factor, selectionRect.width / fileImage.factor, selectionRect.height / fileImage.factor), selectedFile: selectedFile});
        }

        Connections {
            target: superposedZoomDialog.mainItem

            onSavedImage: {
                fileImage.source = '';
                fileImage.source = Qt.binding(function() { return imageBoardItem.selectedFile; } );
                imageBoardItem.publishMessage(qsTr("S'ha desat la imatge en el fitxer «") + file + "».");
            }

        }
    }
}
