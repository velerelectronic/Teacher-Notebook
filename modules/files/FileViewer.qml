import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

Rectangle {
    id: fileViewer

    property string fileURL

    signal closed()
    signal gotoPrevious()
    signal gotoNext()
    signal editorRequested(string file)

    Common.UseUnits {
        id: units
    }

    MouseArea {
        anchors.fill: parent
        enabled: false

        onClicked: {
            buttonsBar.visible = !buttonsBar.visible;
        }
    }

    Flickable {
        id: flickableItem

        anchors.fill: parent

        onWidthChanged: returnToBounds()
        onHeightChanged: returnToBounds()

        contentWidth: bigImageView.width
        contentHeight: bigImageView.height

        Image {
            id: bigImageView
            width: Math.min(flickableItem.width, implicitWidth)
            height: Math.min(flickableItem.height, implicitHeight)

            fillMode: Image.PreserveAspectFit
            source: fileURL
            cache: false
            asynchronous: true

            PinchArea {
                id: imagePinch

                property int originalWidth
                property int originalHeight

                anchors.fill: parent
                onPinchStarted: {
                    pinch.accpted = true;
                    originalWidth = bigImageView.width;
                    originalHeight = bigImageView.height;
                }
                onPinchUpdated: {
                    bigImageView.width = Math.max(flickableItem.width, Math.min(originalWidth * pinch.scale, bigImageView.implicitWidth));
                    bigImageView.height = Math.max(flickableItem.height, Math.min(originalHeight * pinch.scale, bigImageView.implicitHeight));
                }
                onPinchFinished: {
                    flickableItem.returnToBounds();
                }
            }
        }
    }


    Text {
        anchors.fill: parent
        font.pixelSize: units.readUnit
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: (bigImageView.status == Image.Error)?(qsTr('No reconegut') + "\n" + fileURL):''
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

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: buttonsBar.height + spacing
            spacing: units.fingerUnit

            Text {
                Layout.fillHeight: true
                Layout.fillWidth: true

                font.pixelSize: units.readUnit
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: fileURL
            }

            Common.ImageButton {
                Layout.fillHeight: true
                Layout.preferredWidth: height
                image: 'arrow-145769'
                onClicked: gotoPrevious()
            }

            Common.ImageButton {
                Layout.fillHeight: true
                Layout.preferredWidth: height
                image: 'arrow-145766'
                onClicked: gotoNext()
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
