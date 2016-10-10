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

    property bool visibleImageInfo: false
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

        Image {
            id: bigImageView
            width: Math.min(flickableItem.width, implicitWidth)
            height: Math.min(flickableItem.height, implicitHeight)

            fillMode: Image.PreserveAspectFit
            source: fileURL
            cache: false
            asynchronous: true

        }
    }
    Common.ImageButton {
        anchors {
            top: flickableItem.top
            left: flickableItem.left
            margins: units.nailUnit
        }
        size: units.fingerUnit
        image: 'cog-147414'

        onClicked: visibleImageInfo = !visibleImageInfo;
    }

    PinchArea {
        id: imagePinch

        property int originalWidth
        property int originalHeight

        anchors.fill: flickableItem
        onPinchStarted: {
            pinch.accpted = true;
            originalWidth = bigImageView.width;
            originalHeight = bigImageView.height;
        }
        onPinchUpdated: {
            var newWidth = Math.min(originalWidth * pinch.scale, bigImageView.implicitWidth);
            var newHeight = Math.min(originalHeight * pinch.scale, bigImageView.implicitHeight);
            bigImageView.width = (newWidth <= flickableItem.width)?Qt.binding(function() { return flickableItem.width; }):newWidth;
            bigImageView.height = (newHeight <= flickableItem.height)?Qt.binding(function() { return flickableItem.height; }):newHeight;
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
        color: 'white'
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
