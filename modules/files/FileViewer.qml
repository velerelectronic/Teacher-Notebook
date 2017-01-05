import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///modules/basic' as Basic

Rectangle {
    id: fileViewer

    property string fileURL

    signal closed()
    signal editorRequested(string file)
    signal toggleFullScreen()

    property bool reloadEnabled: true
    property bool showImageEnabled: true

    property bool visibleImageInfo: true
    property int requiredHeight: bigImageView.implicitImageHeight * (width / bigImageView.implicitImageWidth)
    property int extraBottomMargin: 0
    property int extraTopMargin: 0

    property alias directFileURL: bigImageView.source

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
        clip: true

        /*
        Basic.ReloadableImage {
            id: bigImageView

            width: Math.min(flickableItem.width, implicitImageWidth)
            height: Math.min(flickableItem.height, implicitImageHeight)

            fillMode: Image.PreserveAspectFit
            imageSource: (fileURL !== '')?fileURL:undefined
        }
        */

        Image {
            id: bigImageView

            property alias implicitImageWidth: bigImageView.implicitWidth
            property alias implicitImageHeight: bigImageView.implicitHeight

            width: Math.min(flickableItem.width, implicitWidth)
            height: Math.min(flickableItem.height, implicitHeight)

            fillMode: Image.PreserveAspectFit
            source: (showImageEnabled)?fileURL:undefined
            cache: true
            asynchronous: false

            function reloadImage() {
                if (reloadEnabled) {
                    source = 'qrc:///icons/hourglass-23654.svg';
                    source = Qt.binding(function() { return (showImageEnabled)?fileURL:undefined; });
                }
            }

            /*
            onStatusChanged: {
                if ((status == Image.Ready) && (source == 'qrc:///icons/hourglass-23654.svg')) {
                    source = Qt.binding(function() { return (fileURL !== '')?fileURL:undefined; });
                }
            }
            */
        }
    }

    MouseArea {
        anchors.fill: flickableItem
        preventStealing: true
        onDoubleClicked: toggleFullScreen()
        onPressAndHold: toggleFullScreen()
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
            var newWidth = Math.min(originalWidth * pinch.scale, bigImageView.implicitImageWidth * 3);
            var newHeight = Math.min(originalHeight * pinch.scale, bigImageView.implicitImageHeight * 3);

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
        bigImageView.reloadImage();
    }
}
