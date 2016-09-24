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

    Common.UseUnits {
        id: units
    }

    Image {
        id: bigImageView
        anchors.fill: parent

        fillMode: Image.PreserveAspectFit
        source: fileURL

        MouseArea {
            anchors.fill: parent
            onClicked: {
                buttonsBar.visible = !buttonsBar.visible;
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
                spacing: units.fingerUnit

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
                    onClicked: Qt.openUrlExternally(fileURL)
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    image: 'road-sign-147409'
                    onClicked: close();
                }
            }
        }

    }

    function close() {
        fileURL = '';
        visible = false;
        closed();
    }

    function load() {
        visible = true;
    }
}
