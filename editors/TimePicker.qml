import QtQuick 2.0
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

Rectangle {
    id: timePicker
    property var time: new Date()
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
            width: hour.width + minute.width
            height: childrenRect.height

            Common.WheelButton {
                id: hour
                width: units.fingerUnit * 1.5
                height: units.fingerUnit * 4
                fromNumber: 0
                toNumber: 23
                onCurrentIndexChanged: updatedByUser()
            }

            Common.WheelButton {
                id: minute
                width: units.fingerUnit * 1.5
                height: units.fingerUnit * 4
                fromNumber: 0
                toNumber: 59
                onCurrentIndexChanged: updatedByUser()
            }
        }
    }

    function updateDisplay() {
        var h = time.getHours()
        hour.moveToNumber(h);
        var m = time.getMinutes()
        minute.moveToNumber(m);
    }

    function setDateTime(newDate) {
        timePicker.time = new Date(newDate);
        updateDisplay();
    }

    function getTime() {
        timePicker.time.setHours(hour.currentIndex);
        timePicker.time.setMinutes(minute.currentIndex);
        return timePicker.time;
    }
}
