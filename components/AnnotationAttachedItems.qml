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
            font.bold: true
            text: qsTr("Elements annexos: ") + annotation
        }

        ListView {
            id: attachedItemsList

            Layout.fillHeight: true
            Layout.fillWidth: true
            orientation: ListView.Vertical

            clip: true
            model: attachedItems
            spacing: units.nailUnit

            bottomMargin: units.fingerUnit * 2

            delegate: Rectangle {
                z: 1
                height: units.fingerUnit * 2
                width: attachedItemsList.width
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    anchors.leftMargin: units.fingerUnit * 2
                    spacing: units.nailUnit
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 3
                        font.pixelSize: units.readUnit
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.visualTitle
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 3
                        font.pixelSize: units.readUnit
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: {
                            switch(model.type) {
                            case 'rubric':
                                return qsTr('Rúbrica');
                            case 'resource':
                                return qsTr('Recurs');
                            default:
                                return qsTr('Algun altre tipus');
                            }
                        }
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
            Common.ImageButton {
                anchors {
                    top: parent.top
                    left: parent.left
                }

                size: units.fingerUnit * 2

                z: 2
                image: 'paper-clip-27821'
            }
        }

    }

    onAnnotationChanged: refreshData();

    Component.onCompleted: refreshData();

    function refreshData() {
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
