import QtQuick 2.7
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///modules/basic' as Basic
import "qrc:///common/FormatDates.js" as FormatDates

Rectangle {
    id: showPlanningItem

    signal sessionSelected(int session)
    signal updated(var object)

    property string periodStart: ''
    property string periodEnd: ''

    color: 'gray'

    Common.UseUnits {
        id: units
    }

    Models.PlanningsModel {
        id: planningsModel
    }

    Models.PlanningSessionsModel {
        id: sessionsModel

        // filters should be fixed
        filters:  ['INSTR(start,?) OR INSTR(end,?)']

        sort: 'start ASC, end ASC, number ASC'

        function refresh() {
            // this should be fixed
            bindValues = [periodStart, periodStart];
            select();
            console.log('counttttt', count);
        }
    }

    ColumnLayout {
        anchors.fill: parent

        ListView {
            id: sessionsList

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            model: sessionsModel
            spacing: units.nailUnit

            delegate: Rectangle {
                id: singleSessionRect

                width: sessionsList.width
                height: units.fingerUnit * 2

                property int sessionId: model.id

                MouseArea {
                    anchors.fill: parent
                    onClicked: sessionSelected(singleSessionRect.sessionId)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit

                    Text {
                        id: sessionNumberText

                        Layout.fillHeight: true
                        Layout.preferredWidth: units.fingerUnit * 2
                        verticalAlignment: Text.AlignTop
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.number
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.title
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.planning
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                        text: {
                            var startStr = '';
                            var date1 = new Date();
                            var returnString = '';
                            if (model.start !== '') {
                                var startObj = date1.fromYYYYMMDDHHMMFormat(model.start);
                            }
                            var endStr = '';
                            var date2 = new Date();
                            if (model.end !== '') {
                                var endObj = date2.fromYYYYMMDDHHMMFormat(model.end);
                            }
                            if ((date1.definedDate) && (date2.definedDate)) {
                                // Start and end have been defined
                                if ((date1.differenceInDays(date2) == 0)) {
                                    // Start and end have the same date

                                    returnString = date1.toShortReadableDate();

                                    if ((date1.definedTime) || (date2.definedTime)) {
                                        // Start time OR end time have not been defined

                                        if ((date1.definedTime) && (date2.definedTime) && (date1.differenceInMinutes(date2) == 0)) {
                                            // Start time AND end time have been defined
                                            // Start and end have the same time in hours and minutes
                                            returnString += "\n" + qsTr("A les ") + date1.toHHMMFormat();
                                        } else {
                                            returnString += "\n[ " + (date1.definedTime?date1.toHHMMFormat():'-') + " , ";
                                            returnString += (date2.definedTime?date2.toHHMMFormat():'-') + ' ]';
                                        }
                                    }
                                } else {
                                    // Start and end have been defined with different dates
                                    returnString = qsTr('Comença ') + date1.toShortReadableDate();
                                    if (date1.definedTime)
                                        returnString += " " + date1.toHHMMFormat();
                                    returnString += "\n" + qsTr('Acaba ') + date2.toShortReadableDate();
                                    if (date2.definedTime)
                                        returnString += " " + date2.toHHMMFormat();
                                }
                            } else {
                                // Only start date or end date have been specified
                                if (date1.definedDate) {
                                    returnString = qsTr('Comença ') + date1.toShortReadableDate();
                                    if (date1.definedTime)
                                        returnString += " " + date1.toHHMMFormat();
                                }
                                if (date2.definedDate) {
                                    returnString = qsTr('Acaba ') + date2.toShortReadableDate();
                                    if (date2.definedTime)
                                        returnString += " " + date2.toHHMMFormat();
                                }
                            }
                            return returnString;
                        }
                    }
                }
            }
        }
    }

    function receiveUpdated(object) {
        sessionsModel.refresh();
        showPlanningItem.updated(object);
    }

    Component.onCompleted: {
        sessionsModel.refresh();
    }

}
