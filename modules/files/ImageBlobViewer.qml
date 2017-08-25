import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///modules/basic' as Basic

import ImageItem 1.0

Item {
    id: fileViewer

    property string fileURL

    signal closed()
    signal editorRequested(string file)
    signal toggleFullScreen()
    signal closeViewer()

    property var contents
    property bool showImageEnabled: true

    property bool visibleImageInfo: true
    property int requiredHeight: bigImageView.implicitImageHeight * (width / bigImageView.implicitImageWidth)
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

        ImageFromBlob {
            id: bigImageView

            property alias implicitImageWidth: bigImageView.implicitWidth
            property alias implicitImageHeight: bigImageView.implicitHeight

            width: Math.min(flickableItem.width, implicitWidth)
            height: Math.min(flickableItem.height, implicitHeight)

            function reloadImage() {
                data = contents;
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
        anchors.fill: parent
        //preventStealing: true

        onDoubleClicked: toggleFullScreen()
        onPressAndHold: toggleFullScreen()

        property bool isActive: drag.active
        drag.target: bigImageView
        drag.axis: Drag.XAndYAxis

        enabled: true
        onIsActiveChanged: {
            if (!isActive) {
                console.log("ara no és actiu!!");
                flickableItem.returnToBounds();
            }
        }
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
            //flickableItem.contentX = Math.floor(originalContentX + (point1.x - point2.x / finalScale));
            //flickableItem.contentY = Math.floor(originalContentY + (point1.y - point2.y / finalScale));

            flickableItem.contentX = Math.floor(originalContentX - point1.x + ((originalContentX + point1.x) * finalScale));
            flickableItem.contentY = Math.floor(originalContentY - point1.y + ((originalContentY + point1.y) * finalScale));

            console.log('ppp');
            //flickableItem.contentX = originalContentX + pinch.startCenter.x * finalScale * 2;
            //flickableItem.contentY = originalContentY + pinch.startCenter.y * finalScale * 2;
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

            Common.ImageButton {
                Layout.fillHeight: true
                Layout.preferredWidth: height

                image: 'road-sign-147409'

                onClicked: fileViewer.closeViewer()
            }
        }
    }



    function reload() {
        bigImageView.reloadImage();
    }
}
