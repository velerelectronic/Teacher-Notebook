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

        filters: ["start < ? OR end < ? OR (IFNULL(start,'') = '' AND IFNULL(end,'') = '') AND state != 3 AND state != -1"];
        sort: 'end ASC, start ASC'
    }

    ListModel {
        id: annotationsProxyModel
    }

    signal annotationSelected(int annotation)
    requiredHeight: eventsList.contentItem.height

    ListView {
        id: eventsList

        anchors.fill: parent

        model: annotationsProxyModel
        interactive: false
        property int remainingCount: Math.max(annotationsModel.count - annotationsProxyModel.count, 0)

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

                Text {
                    Layout.preferredWidth: parent.width / 4
                    Layout.fillHeight: true
                    font.pixelSize: units.readUnit
                    fontSizeMode: Text.Fit
                    verticalAlignment: Text.AlignVCenter
                    text: {
                        var start = model.start;
                        var end = model.end;
                        var today = new Date();
                        if (end < today.toYYYYMMDDFormat()) {
                            if (end !== '') {
                                var endDate = new Date();
                                endDate.fromYYYYMMDDFormat(end);
                                return endDate.differenceInDays(today) + qsTr(' dies');
                            } else
                                return "-";
                        } else {
                            if (start !== '') {
                                var startDate = new Date();
                                startDate.fromYYYYMMDDFormat(start);
                                return startDate.differencesInDays(today) + qsTr(' dies');
                            } else
                                return "-";
                        }
                    }
                }

            }
            MouseArea {
                anchors.fill: parent
                onClicked:  annotationSelected(singleEventRect.identifier)
            }
        }

        footer: (eventsList.remainingCount>0)?footerComponent:null

        Component {
            id: footerComponent

            Rectangle {
                id: footer
                width: eventsList.width
                height: units.fingerUnit * 1.5

                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter

                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: eventsList.remainingCount + qsTr(" anotacions més.")
                }
            }
        }
    }

    function updateContents() {
        var today = new Date();
        var todayStr = today.toYYYYMMDDFormat();
        annotationsModel.bindValues = [todayStr, todayStr];
        annotationsModel.select();
        annotationsProxyModel.clear();
        for (var i=0; i<Math.min(annotationsModel.count, 10); i++) {
            var annotationObj = annotationsModel.getObjectInRow(i);
            annotationsProxyModel.append({id: annotationObj['id'], title: annotationObj['title'], start: annotationObj['start'], end: annotationObj['end']});
        }
    }

    Component.onCompleted: updateContents()
}
