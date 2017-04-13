import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2

import ImageItem 1.0

import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///modules/connections' as AnnotationsConnections

Item {
    id: annotationPreviewItem

    property int identifier: -1
    property string descText
    property string periodStart
    property string periodEnd
    property string title
    property int stateValue

    signal annotationSelected(int annotation)

    Common.UseUnits {
        id: units
    }

    Models.DocumentAnnotations {
        id: annotationsModel
        //limit: 6
    }

    ColumnLayout {
        anchors.fill: parent

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: mainAnnotationInfoText.height

            RowLayout {
                anchors.fill: parent
                spacing: units.nailUnit

                Text {
                    id: mainAnnotationInfoText

                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(contentHeight, units.fingerUnit * 2)

                    font.pixelSize: units.readUnit
                    color: 'blue'
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight

                    text: annotationPreviewItem.title
                }
                Text {
                    Layout.preferredWidth: contentWidth
                    Layout.fillHeight: true

                    font.pixelSize: units.readUnit
                    color: 'blue'
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    text: qsTr('Obre anotació')

                    MouseArea {
                        anchors.fill: parent
                        onClicked: annotationPreviewItem.annotationSelected(annotationPreviewItem.identifier)
                    }
                }

            }
        }

        ListView {
            id: partsList

            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: units.nailUnit

            clip: true

            model: ObjectModel {
                Text {
                    width: partsList.width
                    height: Math.max(contentHeight, units.fingerUnit)

                    font.pixelSize: units.readUnit
                    font.bold: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: annotationPreviewItem.title
                }
                ImageFromBlob {
                    id: imagePreviewer

                    width: partsList.width
                    height: width * implicitHeight / Math.max(implicitWidth,1)
                }
                Item {
                    width: partsList.width
                    height: units.fingerUnit * 1.5

                    RowLayout {
                        anchors.fill: parent
                        spacing: units.nailUnit

                        Text {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: periodStart + " -- " + periodEnd
                        }

                        StateDisplay {
                            id: stateComponent

                            Layout.fillHeight: true
                            Layout.preferredWidth: height
                            stateValue: annotationPreviewItem.stateValue
                        }
                    }
                }
                Text {
                    width: partsList.width
                    height: Math.max(contentHeight, units.fingerUnit)

                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: annotationPreviewItem.descText
                }
                AnnotationsConnections.AnnotationConnections {
                    id: annotationsConnectionsItem

                    width: partsList.width
                    height: requiredHeight

                    annotationId: annotationPreviewItem.identifier

                    onAnnotationSelected: {
                        identifier = annotation;
                    }
                }
            }
        }
    }

    function getAnnotationDetails() {
        if (annotationPreviewItem.identifier > -1) {
            annotationsModel.filters = ["id = ?"];
            annotationsModel.bindValues = [annotationPreviewItem.identifier];
        } else {
            var today = new Date();
            var filters = [];
            filters.push("title != ''");
            filters.push("(start <= ?) OR (end <= ?)");
            annotationsModel.filters = filters;
            var todayText = today.toYYYYMMDDHHMMFormat();
            var values = [];
            values.push(todayText);
            values.push(todayText);
            annotationsModel.bindValues = values;
            annotationsModel.sort = 'start DESC, end DESC, title DESC';
        }
        annotationsModel.select();

        if (annotationsModel.count>0) {
            var obj;
            obj = annotationsModel.getObjectInRow(0);
            annotationPreviewItem.title = obj['title'];
            annotationPreviewItem.descText = obj['desc'];
            annotationPreviewItem.periodStart = obj['start'];
            annotationPreviewItem.periodEnd = obj['end'];
            imagePreviewer.data = obj['contents'];
            annotationPreviewItem.stateValue = obj['state'];
        }
    }

    Component.onCompleted: getAnnotationDetails()

    onIdentifierChanged: getAnnotationDetails()
}

