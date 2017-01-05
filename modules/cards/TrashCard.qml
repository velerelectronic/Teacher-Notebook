import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
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

        filters: ["state = -1"];
        sort: 'end ASC, start ASC'
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

                Annotations.StateDisplay {
                    Layout.preferredWidth: requiredHeight
                    Layout.preferredHeight: requiredHeight

                    stateValue: model.state
                }

            }
            MouseArea {
                anchors.fill: parent
                onClicked:  annotationSelected(singleEventRect.identifier)
            }
        }

        footer: Button {
            width: eventsList.width
            height: units.fingerUnit * 1.5

            text: qsTr('Buida')

            onClicked: confirmEmptyTrashDialog.open()
        }
    }

    MessageDialog {
        id: confirmEmptyTrashDialog

        title: qsTr("Esborra les anotacions de la paperera")

        text: qsTr("Es destruiran les anotacions que estan dins la paperera. Vols continuar?")

        standardButtons: StandardButton.Ok | StandardButton.Cancel

        onAccepted: {
            // Empty trash

            while (annotationsModel.count > 0) {
                var obj = annotationsModel.getObjectInRow(0);
                annotationsModel.removeObject(obj[annotationsModel.primaryKey]);
                updateContents();
            }
        }
    }

    function updateContents() {
        annotationsModel.select();
    }

    Component.onCompleted: updateContents()
}
