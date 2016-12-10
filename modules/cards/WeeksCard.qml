import QtQuick 2.5
import QtQuick.Layouts 1.1
import 'qrc:///models' as Models
import 'qrc:///common' as Common
import 'qrc:///modules/calendar' as Calendar
import "qrc:///common/FormatDates.js" as FormatDates

BaseCard {
    Common.UseUnits {
        id: units
    }

    requiredHeight: selectorsRow.height + weeksCalendarView.requiredHeight

    signal showAnnotations()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            id: selectorsRow

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            RowLayout {
                anchors.fill: parent
                spacing: units.nailUnit

                Common.ImageButton {
                    Layout.preferredWidth: size
                    size: units.fingerUnit
                    image: 'arrow-145769'

                    onClicked: {
                        weeksCalendarView.decreaseWeek();
                        referenceDate.text = weeksCalendarView.initialDate.toShortReadableDate();
                    }
                }
                Text {
                    id: referenceDate

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    font.pixelSize: units.readUnit
                    font.bold: true

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    text: {
                        return weeksCalendarView.initialDate.toShortReadableDate();
                    }
                }
                Common.ImageButton {
                    Layout.preferredWidth: size
                    size: units.fingerUnit
                    image: 'arrow-145766'

                    onClicked: {
                        weeksCalendarView.advanceWeek();
                        referenceDate.text = weeksCalendarView.initialDate.toShortReadableDate();
                    }
                }
            }

        }

        Calendar.WeeksView {
            id: weeksCalendarView

            Layout.fillWidth: true
            Layout.fillHeight: true

            weeksNumber: 5
            interactive: false
            daysOverWidget: true

            onSelectedDate: {
                var date = new Date(year, month, day);
                var startDateStr = date.toYYYYMMDDFormat();
                date.setDate(day+1);
                var endDateStr = date.toYYYYMMDDFormat();
                selectedPage('annotations2/AnnotationsList', {periodStart: startDateStr, periodEnd: endDateStr, filterPeriod: true, interactive: true}, qsTr('Anotacions dins rang de dates'));
            }

            subWidget: Calendar.DayBase {
                property int day
                property int month
                property int year

                color: (annotationsModel.count>0)?'red':'transparent'

                Models.DocumentAnnotations {
                    id: annotationsModel

                    filters: ['INSTR(start,?) OR INSTR(end,?)']
                }

                function dateUpdated() {
                    var date = new Date(year, month, day);
                    var dateStr = date.toYYYYMMDDFormat();
                    annotationsModel.bindValues = [dateStr, dateStr];
                    annotationsModel.select();
                }
            }
        }
    }

    function updateContents() {
        weeksCalendarView.updateContents();
    }
}
