import QtQuick 2.5
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import "qrc:///common/FormatDates.js" as FormatDates

BaseCard {
    Common.UseUnits {
        id: units
    }

    Models.DocumentAnnotations {
        id: annotationsModel

        filters: ['INSTR(start,?) OR INSTR(end,?)'];
    }

    signal annotationSelected(int identifier)
    requiredHeight: eventsList.contentItem.height

    ListView {
        id: eventsList

        anchors.fill: parent

        property var todayDate
        property string todayShort: ''

        model: annotationsModel
        interactive: false

        header: Common.BoxedText {
            width: eventsList.width
            height: units.fingerUnit

            text: eventsList.todayShort
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
                    id: eventTime

                    Layout.fillHeight: true
                    Layout.preferredWidth: contentWidth

                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    Component.onCompleted: {
                        if (model.start == model.end) {
                            color = 'orange';
                            text = qsTr('Avui');
                        } else {
                            var today = new Date();
                            if (model.start.indexOf(today.toYYYYMMDDFormat()) == 0) {
                                color = 'green';
                                text = qsTr('Comença');
                            } else {
                                color = 'red';
                                text = qsTr('Acaba');
                            }
                        }
                    }
                }

            }
            MouseArea {
                anchors.fill: parent
                onClicked:  annotationSelected(singleEventRect.identifier)
            }
        }
    }

    function updateContents() {
        eventsList.todayDate = new Date();
        var todayStr = eventsList.todayDate.toYYYYMMDDFormat();
        eventsList.todayShort = eventsList.todayDate.toShortReadableDate();
        annotationsModel.bindValues = [todayStr, todayStr];
        annotationsModel.select();
    }

    Component.onCompleted: updateContents()
}
