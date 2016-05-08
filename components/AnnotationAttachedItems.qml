import QtQuick 2.5
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Item {
    id: attachedItemsItem

    property string annotation: ''

    signal newRubricAssessment(string annotation)

    Common.UseUnits {
        id: units
    }

    Models.RubricsAssessmentModel {
        id: rubricsAssessmentModel
        filters: ["annotation=?"]
    }

    Models.ResourcesModel {
        id: resourcesModel
        filters: ["annotation=?"]
    }

    ListModel {
        id: attachedItems
    }


    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit
        spacing: units.nailUnit

        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit
            font.pixelSize: units.readUnit
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: annotation
        }

        ListView {
            id: attachedItemsList

            Layout.fillHeight: true
            Layout.fillWidth: true
            orientation: ListView.Vertical

            clip: true
            model: attachedItems
            spacing: units.nailUnit

            headerPositioning: ListView.OverlayHeader

            bottomMargin: units.fingerUnit * 2

            delegate: Rectangle {
                height: units.fingerUnit * 2
                width: attachedItemsList.width
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 3
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.visualTitle
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 3
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.type
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        switch(model.type) {
                        case 'rubric':
                            annotationView.openPageArgs('RubricsModule', {rubricAssessmentIdentifier: model.identifier});
                            break;
                        case 'resource':
                            annotationView.openPageArgs('ResourcesModule', {resourceId: model.identifier, state: 'displaySource'});
                            break;
                        default:
                            break;
                        }
                    }
                }
            }
            Common.ImageButton {
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }

                size: units.fingerUnit * 2
                image: 'plus-24844'
                onClicked: attachedItemsItem.newRubricAssessment(attachedItemsItem.annotation)
            }
        }

    }

    Component.onCompleted: {
        console.log('Attachment items');

        // Get rubrics
        attachedItems.clear();
        rubricsAssessmentModel.bindValues = [annotation];
        rubricsAssessmentModel.select();

        for (var i=0; i<rubricsAssessmentModel.count; i++) {
            var rubricObj = rubricsAssessmentModel.getObjectInRow(i);
            attachedItems.append({type: 'rubric', visualTitle: rubricObj.title + " (" + rubricObj.group + ")", identifier: rubricObj.id});
        }

        // Get resources
        resourcesModel.bindValues = [annotation];
        resourcesModel.select();

        for (var i=0; i<resourcesModel.count; i++) {
            var resourceObj = resourcesModel.getObjectInRow(i);
            attachedItems.append({type: 'resource', visualTitle: resourceObj.title, identifier: resourceObj.id});
        }

    }
}
