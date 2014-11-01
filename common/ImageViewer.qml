import QtQuick 2.0
import QtQuick.Layouts 1.1

Rectangle {
    id: imageViewer
    property string source: ''
    signal closeViewer()
    signal gotoPrevious()
    signal gotoNext()

    ColumnLayout {
        anchors.fill: parent
        RowLayout {
            Layout.fillWidth: true
            Button {
                Layout.preferredHeight: units.fingerUnit
                color: 'white'
                text: qsTr('Zoom +')
                onClicked: {
                    flickImage.contentWidth = 1.1 * flickImage.contentWidth;
                    flickImage.contentHeight = 1.1 * flickImage.contentHeight;
                }
            }
            Button {
                Layout.preferredHeight: units.fingerUnit
                color: 'white'
                text: qsTr('Ajusta a la pantalla')
                onClicked: {
                    flickImage.contentWidth = flickImage.width;
                    flickImage.contentHeight = flickImage.height;
                }
            }
            Button {
                Layout.preferredHeight: units.fingerUnit
                color: 'white'
                text: qsTr('Zoom -')
                onClicked: {
                    flickImage.contentWidth = flickImage.contentWidth / 1.1;
                    flickImage.contentHeight = flickImage.contentHeight / 1.1;
                }
            }
            Button {
                Layout.preferredHeight: units.fingerUnit
                color: 'white'
                text: qsTr('Tanca')
                onClicked: closeViewer()
            }
            Button {
                Layout.preferredHeight: units.fingerUnit
                color: 'white'
                text: qsTr('Anterior')
                onClicked: gotoPrevious()
            }
            Button {
                Layout.preferredHeight: units.fingerUnit
                color: 'white'
                text: qsTr('Següent')
                onClicked: gotoNext()
            }
        }
        Flickable {
            id: flickImage
            Layout.fillWidth: true
            Layout.fillHeight: true

            contentWidth: width
            contentHeight: height
            clip: true

            Image {
                source: imageViewer.source
                width: flickImage.contentWidth
                height: flickImage.contentHeight
                fillMode: Image.PreserveAspectFit
            }
        }
    }
}
