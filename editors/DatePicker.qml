import QtQuick 2.0
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

Rectangle {
    id: datePicker
    property var date: new Date()
    property var monthsAb: [qsTr('gen'),qsTr('feb'),qsTr('mar'),qsTr('abr'),qsTr('mai'),qsTr('jun'),qsTr('jul'),qsTr('ago'),qsTr('set'),qsTr('oct'),qsTr('nov'),qsTr('des')]
    property var daysOfWeek: [qsTr('diumenge'), qsTr('dilluns'), qsTr('dimarts'), qsTr('dimecres'), qsTr('dijous'), qsTr('divendres'), qsTr('dissabte')]
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
            width: dayOfWeek.width + days.width + months.width + year.width
            height: childrenRect.height

            Text {
                id: dayOfWeek
                width: units.fingerUnit * 3
                height: units.fingerUnit * 4
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Common.WheelButton {
                id: days
                width: units.fingerUnit * 1.5
                height: units.fingerUnit * 4
                fromNumber: 1
                toNumber: 31
                onCurrentIndexChanged: {
                    datePicker.date.setDate(days.currentIndex + days.fromNumber);
                    updateDayOfWeek();
                    updatedByUser();
                }
            }

            Common.WheelButton {
                id: months
                width: units.fingerUnit * 2
                height: units.fingerUnit * 4
                model: monthsAb
                onCurrentIndexChanged: {
                    datePicker.date.setMonth(months.currentIndex);
                    updateDayOfWeek();
                    updatedByUser();
                }
            }

            Common.WheelButton {
                id: year
                width: units.fingerUnit * 2
                height: units.fingerUnit * 4
                fromNumber: 2000
                toNumber: 2200
                onCurrentIndexChanged: {
                    datePicker.date.setFullYear(year.currentIndex + year.fromNumber);
                    updateDayOfWeek();
                    updatedByUser();
                }
            }
        }
    }


    function updateDisplay() {
        days.moveToNumber(datePicker.date.getDate()-days.fromNumber);
        months.moveToNumber(datePicker.date.getMonth());
        year.moveToNumber(datePicker.date.getFullYear()-year.fromNumber);
        updateDayOfWeek();
    }

    function updateDayOfWeek() {
        dayOfWeek.text = daysOfWeek[datePicker.date.getDay()];
    }

    function setDate(newDate) {
        datePicker.date = newDate;
        updateDisplay();
    }

    function getDate() {
        return datePicker.date;
    }

    function dateString() {
        var d = datePicker.date;
        var month = d.getMonth()+1;
        var day = d.getDate();
        return d.getFullYear() + '/' + ((month<10)?'0':'') + month + '/' + ((day<10)?'0':'') + day;
    }
}
