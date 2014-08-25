import QtQuick 2.0
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

Rectangle {
    id: datePicker
    property var date: new Date()
    property var monthsAb: [qsTr('gen'),qsTr('feb'),qsTr('mar'),qsTr('abr'),qsTr('mai'),qsTr('jun'),qsTr('jul'),qsTr('ago'),qsTr('set'),qsTr('oct'),qsTr('nov'),qsTr('des')]
    signal updatedByUser()

    width: childrenRect.width
    height: childrenRect.height
    anchors.margins: units.nailUnit

    Common.UseUnits { id: units }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        width: childrenRect.width
        height: childrenRect.height
        Row {
            width: days.width + months.width + year.width
            height: childrenRect.height

            Common.WheelButton {
                id: days
                width: units.fingerUnit * 1.5
                height: units.fingerUnit * 4
                fromNumber: 1
                toNumber: 31
                onCurrentIndexChanged: updatedByUser()
            }

            Common.WheelButton {
                id: months
                width: units.fingerUnit * 2
                height: units.fingerUnit * 4
                model: monthsAb
                onCurrentIndexChanged: updatedByUser()
            }

            Common.WheelButton {
                id: year
                width: units.fingerUnit * 2
                height: units.fingerUnit * 4
                fromNumber: 2000
                toNumber: 2200
                onCurrentIndexChanged: updatedByUser()
            }
        }
    }


    function updateDisplay() {
        days.moveToNumber(datePicker.date.getDate()-days.fromNumber);
        months.moveToNumber(datePicker.date.getMonth());
        year.moveToNumber(datePicker.date.getFullYear()-year.fromNumber);
    }

    function setDate(newDate) {
        datePicker.date = newDate;
        updateDisplay();
    }

    function getDate() {
        datePicker.date.setDate(days.currentIndex + days.fromNumber);
        datePicker.date.setMonth(months.currentIndex);
        datePicker.date.setFullYear(year.currentIndex + year.fromNumber);
        return datePicker.date;
    }
}
