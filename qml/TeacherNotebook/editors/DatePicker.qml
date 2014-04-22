import QtQuick 2.0
import QtQuick.Layouts 1.1
import '../common' as Common

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
            width: days.width + sep1.width + months.width + sep2.width + year.width
            height: childrenRect.height
            Common.BizoneButton {
                // days
                id: days
                width: units.fingerUnit * 2
                content: '0'
                onUpClicked: moveDate(1,0,0)
                onUpLongClicked: moveDate(7,0,0)
                onDownClicked: moveDate(-1,0,0)
                onDownLongClicked: moveDate(-7,0,0)
            }
            Text {
                id: sep1
                text: '/'
            }

            Common.BizoneButton {
                // Months
                id: months
                width: units.fingerUnit * 2
                content: '00'
                onUpClicked: moveDate(0,1,0)
                onUpLongClicked: moveDate(0,6,0)
                onDownClicked: moveDate(0,-1,0)
                onDownLongClicked: moveDate(0,-6,0)
            }
            Text {
                id: sep2
                text: '/'
            }
            Common.BizoneButton {
                // Year
                id: year
                width: units.fingerUnit * 2
                content: '00'
                onUpClicked: moveDate(0,0,1)
                onUpLongClicked: {}
                onDownClicked: moveDate(0,0,-1)
                onDownLongClicked: {}
            }
        }
    }

    function moveDate(days,months,years) {
        if (days != 0)
            date.setDate(date.getDate()+days);
        if (months != 0)
            date.setMonth(date.getMonth()+months);
        if (years != 0)
            date.setFullYear(date.getFullYear()+years);
        updateDisplay();
        updatedByUser();
    }

    function updateDisplay() {
        days.content = datePicker.date.getDate();
        var m = datePicker.date.getMonth();
        months.content = datePicker.monthsAb[m];
        year.content = datePicker.date.getFullYear();
    }

    function setDate(newDate) {
        datePicker.date = newDate;
        updateDisplay();
    }

    function getDate() {
        return datePicker.date;
    }
}
