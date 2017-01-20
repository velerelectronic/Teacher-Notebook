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
                        referenceDate.text = weeksCalendarView.firstMonthDate.toShortReadableDate();
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

                    MouseArea {
                        anchors.fill: parent
                        onClicked: weeksCalendarView.setTodayDate()
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
                var dateStr = date.toYYYYMMDDFormat();
                selectedPage('annotations2/AnnotationsList', {selectedDate: dateStr, filterPeriod: true, interactive: true}, qsTr('Anotacions dins rang de dates'));
            }

            subWidget: Calendar.DayBase {
                id: calendarDayBase

                property int day
                property int month
                property int year

                Models.DocumentAnnotations {
                    id: annotationsModel
                }

                function dateUpdated() {
                    var date = new Date(year, month, day);
                    var dateStr = date.toYYYYMMDDFormat();
                    annotationsModel.filters = ['INSTR(start,?) OR INSTR(end,?)', "IFNULL(state,0) != 3"];
                    annotationsModel.bindValues = [dateStr, dateStr];
                    annotationsModel.select();

                    if (annotationsModel.count > 0)
                        calendarDayBase.color = 'red';
                    else {
                        annotationsModel.filters = ['INSTR(start,?) OR INSTR(end,?)', "state = 3"];
                        annotationsModel.bindValues = [dateStr, dateStr];
                        annotationsModel.select();
                        if (annotationsModel.count > 0) {
                            calendarDayBase.color = 'green';
                        } else {
                            calendarDayBase.color = 'white';
                        }
                    }
                    for (var i=0; i<annotationsModel.count; i++) {
                        var obj = pendingAnnotationsModel.getObjectInRow(i);
                        console.log('date updated', i, obj['state'], obj['title']);
                    }
                }
            }
        }
    }

    function updateContents() {
        weeksCalendarView.updateContents();
    }
}
