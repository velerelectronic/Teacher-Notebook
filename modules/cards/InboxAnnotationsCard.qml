import QtQuick 2.6
import QtQuick.Layouts 1.1
import 'qrc:///models' as Models
import 'qrc:///common' as Common
import 'qrc:///modules/annotations2' as Annotations
import "qrc:///common/FormatDates.js" as FormatDates

BaseCard {
    Common.UseUnits {
        id: units
    }

    Models.DocumentAnnotations {
        id: annotationsModel

        filters: ["(state = 0 OR state = '' OR state IS NULL) AND IFNULL(start,'')='' AND IFNULL(end,'')=''"];
    }

    signal annotationSelected(int annotation)
    requiredHeight: eventsList.contentItem.height

    ListView {
        id: eventsList

        anchors.fill: parent

        model: annotationsModel
        interactive: false

        header: Common.BoxedText {
            width: eventsList.width
            height: units.fingerUnit

            text: annotationsModel.count + qsTr(' anotacions')
        }

        delegate: Rectangle {
            id: singleEventRect

            width: eventsList.width
            height: units.fingerUnit * 1.5

            property int identifier: model.id

            RowLayout {
                anchors.fill: parent

                Text {
                    id: eventTitle

                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: model.title
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked:  annotationSelected(singleEventRect.identifier)
            }
        }
    }

    function updateContents() {
        annotationsModel.select();
    }

    Component.onCompleted: updateContents()

}
