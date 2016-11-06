import QtQuick 2.7
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import "qrc:///common/FormatDates.js" as FormatDates

WeeksView {
    signal annotationsOnDateSelected(string start, string end)
    signal planningsOnDateSelected(string start, string end)

    Common.UseUnits {
        id: units
    }

    subWidget: Item {
        id: subWidgetItem

        property int day
        property int month
        property int year

        clip: true

        ColumnLayout {
            anchors.fill: parent

            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                font.pixelSize: units.readUnit
                text: (annotationsModel.count>0)?qsTr('Anotacions'):''
            }

            PointsDiagram {
                id: annotationsDiagram

                Layout.fillHeight: true
                Layout.fillWidth: true

                maxDots: 10
                dotsSize: units.fingerUnit
                interSpacing: units.nailUnit
                color: 'blue'

                dotsNumber: annotationsModel.count

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var dates = subWidgetItem.calculateDateString();
                        annotationsOnDateSelected(dates.start, dates.end);
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                font.pixelSize: units.readUnit
                text: (planningSessionsModel.count>0)?qsTr('Sessions'):''
            }

            PointsDiagram {
                id: planningsDiagram

                Layout.fillHeight: true
                Layout.fillWidth: true

                maxDots: 10
                dotsSize: units.fingerUnit
                interSpacing: units.nailUnit
                color: 'red'

                dotsNumber: planningSessionsModel.count

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var dates = subWidgetItem.calculateDateString();
                        planningsOnDateSelected(dates.start, dates.end);
                    }
                }
            }
        }

        Models.DocumentAnnotations {
            id: annotationsModel
        }

        Models.PlanningSessionsModel {
            id: planningSessionsModel
        }

        function init() {
            // Init annotations
            annotationsModel.filters = ['INSTR(start,?) OR INSTR(end,?)'];
            var date = new Date();
            date.setDate(day);
            date.setMonth(month);
            date.setFullYear(year);

            var dateString = date.toYYYYMMDDFormat();
            annotationsModel.bindValues = [dateString, dateString];
            annotationsModel.select();

            if (annotationsModel.count>0)
                annotationsDataText.text = annotationsModel.count + qsTr(' anotacions');

            // Init planning sessions
            planningSessionsModel.filters = ['INSTR(start,?) OR INSTR(end,?)'];
            planningSessionsModel.bindValues = [dateString, dateString];
            planningSessionsModel.select();

            if (planningSessionsModel.count>0) {
                annotationsDataText.text += planningSessionsModel.count + qsTr(' sessions');
            }
        }

        function calculateDateString() {
            var date = new Date(subWidgetItem.year, subWidgetItem.month, subWidgetItem.day);
            var start = date.toYYYYMMDDFormat();
            date.setDate(date.getDate()+1);
            var end = date.toYYYYMMDDFormat();
            return {start: start, end: end};
        }
    }

}
