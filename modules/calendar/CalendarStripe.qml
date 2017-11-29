import QtQuick 2.7
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common

Item {
    id: calendarStripeBase

    Common.UseUnits {
        id: units
    }

    property int cellSize: units.fingerUnit * 2
    property int cellSpacing: units.nailUnit
    property int totalSize: (verticalLayout)?height:width
    property int cellsCount: Math.floor(totalSize / (cellSize+cellSpacing))

    property int requiredHeight: cellSize + 2 * cellSpacing

    property string selectedDate: ''
    property string initialDate: ''

    property var monthsList: ['GEN', 'FEB', 'MAR', 'ABR', 'MAI', 'JUN', 'JUL', 'AGO', 'SET', 'OCT', 'NOV', 'DES']
    property var daysOfWeek: ['dg', 'dl', 'dt', 'dc', 'dj', 'dv', 'ds']

    property bool verticalLayout

    signal dateSelected(string date)


    height: requiredHeight

    GridLayout {
        anchors.fill: parent

        columnSpacing: cellSpacing
        rowSpacing: cellSpacing

        rows: (verticalLayout)?cellsCount:1
        columns: (verticalLayout)?1:cellsCount

        Common.ImageButton {
            size: cellSize
            image: 'arrow-145769'

            onClicked: addDays(-1)
        }

        Repeater {
            model: cellsCount - 2

            Rectangle {
                id: calendarCell

                width: cellSize
                height: cellSize

                property string thisDate: ''

                color: (calendarStripeBase.selectedDate == calendarCell.thisDate)?'yellow':'white'

                Text {
                    id: cellDayText

                    anchors.fill: parent

                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter

                    font.pixelSize: units.readUnit
                    padding: units.nailUnit
                }

                Text {
                    id: cellDayOfWeekText

                    anchors.fill: parent

                    verticalAlignment: Text.AlignBottom
                    horizontalAlignment: Text.AlignHCenter

                    font.pixelSize: units.readUnit
                    padding: units.nailUnit
                }

                Text {
                    id: cellMonthText

                    anchors.fill: parent

                    font.bold: true
                    verticalAlignment: Text.AlignTop
                    horizontalAlignment: Text.AlignHCenter

                    font.pixelSize: units.readUnit
                    padding: units.nailUnit
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (selectedDate !== calendarCell.thisDate) {
                            selectedDate = calendarCell.thisDate;
                            dateSelected(calendarCell.thisDate);
                        } else {
                            selectedDate = '';
                            dateSelected(null);
                        }
                    }
                }

                function updateContents() {
                    var firstDate = new Date();
                    firstDate.fromYYYYMMDDFormat(initialDate)
                    firstDate.setDate(firstDate.getDate() + modelData);
                    cellDayText.text = firstDate.getDate();
                    calendarCell.thisDate = firstDate.toYYYYMMDDFormat();
                    if ((modelData == 0) || (firstDate.getDate() == 1))
                        cellMonthText.text = monthsList[firstDate.getMonth()];
                    else
                        cellMonthText.text = '';

                    cellDayOfWeekText.text = daysOfWeek[firstDate.getDay()];
                }

                Connections {
                    target: calendarStripeBase

                    onInitialDateChanged: {
                        console.log('initial date changed');
                        calendarCell.updateContents();
                    }
                }

                Component.onCompleted: calendarCell.updateContents()
            }
        }

        Common.ImageButton {
            size: cellSize
            image: 'arrow-145766'

            onClicked: addDays(+1)
        }
    }

    function setTodayDate() {
        var date = new Date();
        initialDate = date.toYYYYMMDDFormat();
    }

    function addDays(days) {
        var date = new Date();
        date.fromYYYYMMDDFormat(initialDate);
        date.setDate(date.getDate() + days);
        initialDate = date.toYYYYMMDDFormat();
    }

    Component.onCompleted: {
        setTodayDate();
    }
}
