import QtQuick 2.7
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import "qrc:///common/FormatDates.js" as FormatDates
import "qrc:///modules/plannings" as Plannings

WeeksView {
    signal annotationsOnDateSelected(string start, string end)
    signal planningsOnDateSelected(string start, string end)

    Common.UseUnits {
        id: units
    }

    Plannings.ActionStateRectangle {
        id: actionColors
    }

    subWidget: DayBase {
        id: subWidgetItem

        property int dotsSize: height / 6
        clip: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            PointsDiagram {
                id: annotationsDiagram

                Layout.preferredHeight: subWidgetItem.dotsSize
                Layout.fillWidth: true

                maxDots: 10
                dotsSize: parent.parent.dotsSize
                interSpacing: units.nailUnit
                color: 'blue'
                clip: true

                dotsNumber: annotationsModel.count

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var dates = subWidgetItem.calculateDateString();
                        annotationsOnDateSelected(dates.start, dates.end);
                    }
                }
            }

            PointsDiagram {
                id: openPlanningsDiagram

                Layout.preferredHeight: subWidgetItem.dotsSize
                Layout.fillWidth: true

                maxDots: 10
                dotsSize: openPlanningsDiagram.height
                interSpacing: units.nailUnit
                color: 'red'
                clip: true

                dotsNumber: openItemsActionsModel.count

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var dates = subWidgetItem.calculateDateString();
                        planningsOnDateSelected(dates.start, dates.end);
                    }
                }
            }

            PointsDiagram {
                id: completedPlanningsDiagram

                Layout.preferredHeight: subWidgetItem.dotsSize
                Layout.fillWidth: true

                maxDots: 10
                dotsSize: completedPlanningsDiagram.height
                interSpacing: units.nailUnit
                color: actionColors.completedColor
                clip: true

                dotsNumber: completedItemsActionsModel.count

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var dates = subWidgetItem.calculateDateString();
                        planningsOnDateSelected(dates.start, dates.end);
                    }
                }
            }

            PointsDiagram {
                id: discardedPlanningsDiagram

                Layout.preferredHeight: subWidgetItem.dotsSize
                Layout.fillWidth: true

                maxDots: 10
                dotsSize: discardedPlanningsDiagram.height
                interSpacing: units.nailUnit
                color: actionColors.discardedColor
                clip: true

                dotsNumber: discardedItemsActionsModel.count

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

        Models.PlanningItemsActionsModel {
            id: openItemsActionsModel

            filters: ['INSTR(start,?) OR INSTR(end,?)', "(state = ?) OR (state = '')"]
        }

        Models.PlanningItemsActionsModel {
            id: completedItemsActionsModel

            filters: ['INSTR(start,?) OR INSTR(end,?)', "state = ?"]
        }

        Models.PlanningItemsActionsModel {
            id: discardedItemsActionsModel

            filters: ['INSTR(start,?) OR INSTR(end,?)', "state = ?"]
        }

        function dateUpdated() {
            // Init annotations
            annotationsModel.filters = ['INSTR(start,?) OR INSTR(end,?)'];
            var date = new Date();
            date.setDate(day);
            date.setMonth(month);
            date.setFullYear(year);

            var dateString = date.toYYYYMMDDFormat();
            annotationsModel.bindValues = [dateString, dateString];
            annotationsModel.select();

            // Init planning items actions
            console.log('filtering', dateString, dateString, actionColors.completedString, actionColors.discardedString);
            openItemsActionsModel.bindValues = [dateString, dateString, actionColors.openString];
            openItemsActionsModel.select();
            completedItemsActionsModel.bindValues = [dateString, dateString, actionColors.completedString];
            completedItemsActionsModel.select();
            discardedItemsActionsModel.bindValues = [dateString, dateString, actionColors.discardedString];
            discardedItemsActionsModel.select();
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
