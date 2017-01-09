import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import ImageItem 1.0

import 'qrc:///common' as Common
import 'qrc:///models' as Models

Item {
    property int annotation

    signal locationChanged(string location)

    Common.UseUnits {
        id: units
    }

    Models.DocumentAnnotations {
        id: annotationsModel
    }

    ColumnLayout {
        anchors.fill: parent

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true

            contentWidth: imagePreviewer.width
            contentHeight: imagePreviewer.height

            clip: true

            Item {
                id: imagePreviewer

                width: imageBlob.implicitWidth
                height: imageBlob.implicitHeight

                ImageFromBlob {
                    id: imageBlob

                    anchors.fill: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        hotSpotItem.visible = true;
                        hotSpotItem.locationX = mouse.x;
                        hotSpotItem.locationY = mouse.y;
                        saveButton.enabled = true;
                    }
                }

                Rectangle {
                    id: hotSpotItem

                    property real locationX
                    property real locationY

                    x: locationX - width / 2
                    y: locationY - height / 2
                    visible: false
                    radius: units.fingerUnit / 2
                    width: units.fingerUnit
                    height: width
                    border.width: units.nailUnit
                    border.color: 'black'
                    color: 'yellow'
                }
            }

        }

        Button {
            id: saveButton

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2

            enabled: false
            text: qsTr('Desa')

            onClicked: {
                var relX = hotSpotItem.locationX / imageBlob.width;
                var relY = hotSpotItem.locationY / imageBlob.height;
                locationChanged('rel ' + relX.toString() + ' ' + relY.toString());
            }
        }
    }

    function getImage() {
        var object = annotationsModel.getObject(annotation);
        if (object) {
            imageBlob.data = object['contents'];
        }
    }

    Component.onCompleted: getImage()

    onAnnotationChanged: getImage()
}
