import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

Rectangle {
    id: fileViewer

    property string fileURL

    signal closed()
    signal editorRequested(string file)
    signal toggleFullScreen()

    property bool visibleImageInfo: true
    property int requiredHeight: bigImageView.implicitHeight * (width / bigImageView.implicitWidth)
    property int extraBottomMargin: 0
    property int extraTopMargin: 0

    Common.UseUnits {
        id: units
    }

    Flickable {
        id: flickableItem

        anchors.fill: parent

        onWidthChanged: returnToBounds()
        onHeightChanged: returnToBounds()

        contentWidth: bigImageView.width
        contentHeight: bigImageView.height

        topMargin: extraTopMargin
        bottomMargin: extraBottomMargin

        interactive: false

        Image {
            id: bigImageView
            width: Math.min(flickableItem.width, implicitWidth)
            height: Math.min(flickableItem.height, implicitHeight)

            fillMode: Image.PreserveAspectFit
            source: (fileURL !== '')?fileURL:undefined
            cache: false
            asynchronous: true
        }
    }

    MouseArea {
        anchors.fill: flickableItem
        onDoubleClicked: toggleFullScreen()
    }

    PinchArea {
        id: imagePinch

        property int originalWidth
        property int originalHeight
        property int originalContentX;
        property int originalContentY;

        anchors.fill: flickableItem
        onPinchStarted: {
            pinch.accpted = true;
            originalWidth = bigImageView.width;
            originalHeight = bigImageView.height;
            originalContentX = flickableItem.contentX;
            originalContentY = flickableItem.contentY;
        }
        onPinchUpdated: {
            var point1 = pinch.startCenter;
            var point2 = pinch.center;

            // Scale image
            var newWidth = Math.min(originalWidth * pinch.scale, bigImageView.implicitWidth * 3);
            var newHeight = Math.min(originalHeight * pinch.scale, bigImageView.implicitHeight * 3);

            var finalScale = Math.min(bigImageView.width / originalWidth, bigImageView.height / originalHeight);
            bigImageView.width = (newWidth <= flickableItem.width)?Qt.binding(function() { return flickableItem.width; }):newWidth;
            bigImageView.height = (newHeight <= flickableItem.height)?Qt.binding(function() { return flickableItem.height; }):newHeight;

            // Translate image
            flickableItem.contentX = Math.floor(originalContentX + (point1.x - point2.x / finalScale));
            flickableItem.contentY = Math.floor(originalContentY + (point1.y - point2.y / finalScale));
        }
        onPinchFinished: {
            flickableItem.returnToBounds();
        }
    }

    Rectangle {
        id: shadowRect

        anchors {
            bottom: flickableItem.bottom
            left: flickableItem.left
            right: flickableItem.right
        }
        height: fileTitleText.contentHeight + 2 * units.nailUnit

        visible: visibleImageInfo
        color: 'gray'
        opacity: 0.8
    }

    Text {
        id: fileTitleText
        anchors.fill: shadowRect
        anchors.margins: units.nailUnit

        visible: visibleImageInfo
        font.pixelSize: units.readUnit
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: 'white'
        text: (bigImageView.status == Image.Error)?(qsTr('No reconegut') + "\n" + fileURL):fileURL
    }

    Item {
        id: buttonsBar

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: units.nailUnit
        }
        height: units.fingerUnit

        visible: visibleImageInfo
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: buttonsBar.height + spacing
            spacing: units.fingerUnit

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            Common.ImageButton {
                Layout.fillHeight: true
                Layout.preferredWidth: height
                image: 'arrows-145992'
                onClicked: toggleFullScreen()
            }

            Common.ImageButton {
                Layout.fillHeight: true
                Layout.preferredWidth: height
                image: 'edit-153612'
                onClicked: editorRequested(fileURL);
            }

            Common.ImageButton {
                Layout.fillHeight: true
                Layout.preferredWidth: height
                image: 'edit-153612'
                onClicked: Qt.openUrlExternally(fileURL)
            }

        }
    }



    function reload() {
        var aux = fileURL;
        fileURL = '';
        fileURL = aux;
    }
}
