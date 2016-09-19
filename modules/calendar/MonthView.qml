import QtQuick 2.5
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

Rectangle {
    id: monthView
    property int month
    property int fullyear

    signal dateSelected(int date, int month, int fullyear)

    Common.UseUnits {
        id: units
    }


    onFullyearChanged: {
        monthGrid.firstDayOffset = -1;
        monthGrid.prepareDate();
    }
    onMonthChanged: {
        monthGrid.firstDayOffset = -1;
        monthGrid.prepareDate();
    }

    Flow {
        id: monthGrid

        anchors.fill: parent

        // Calculated properties

        property int firstDayOffset: -1
        property int daysInMonth
        property int today: 0

        property int cellWidth: Math.floor(width / 7)
        property int cellHeight: height / 6 // 6 weeks at most

        function prepareDate() {
            if (monthGrid.firstDayOffset < 0) {
                var date = new Date(fullyear, month, 1);
                monthGrid.firstDayOffset = (date.getDay() + 6) % 7;
                monthGrid.daysInMonth = monthGrid.numberOfDaysInMonth();
                var today = new Date();
                if ((today.getFullYear() == fullyear) && (today.getMonth() == month)) {
                    monthGrid.today = today.getDate();
                } else {
                    monthGrid.today = 0;
                }
            }
        }

        function numberOfDaysInMonth() {
            var d = new Date(fullyear, month+1, 0);
            return d.getDate();
        }

        Repeater {
            model: 42 // 6 weeks

            delegate: Item {
                id: blankDayItem

                width: monthGrid.cellWidth
                height: monthGrid.cellHeight

                Component {
                    id: dayItemComponent

                    Rectangle {
                        id: dayItem

                        anchors.fill: parent

                        border.color: (validDay)?'black':'transparent'
                        color: ((validDay) && (dayNumber == monthGrid.today))?'#81BEF7':'white'

                        property int dayNumber: modelData-monthGrid.firstDayOffset+1
                        property bool validDay: (dayItem.dayNumber>=1) && (dayItem.dayNumber<=monthGrid.daysInMonth)

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: units.readUnit

                            text: (dayItem.validDay)?(dayItem.dayNumber):''
                        }

                        MouseArea {
                            anchors.fill: parent

                            enabled: dayItem.validDay
                            onClicked: dateSelected(dayItem.dayNumber, month, fullyear)
                        }
                    }
                }


                Component.onCompleted: {
                    var incubator = dayItemComponent.createObject(blankDayItem);
                }
            }
        }

        Component.onCompleted: {
            monthGrid.prepareDate();
        }
    }
}
