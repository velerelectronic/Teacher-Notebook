import QtQuick 2.0
import QtQuick.Layouts 1.1
import '../common' as Common

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
            width: hour.width + separator.width + minute.width
            height: childrenRect.height
            Common.BizoneButton {
                // Hours
                id: hour
                content: '0'
                onUpClicked: moveTime(1,0)
                onUpLongClicked: moveTime(12,0)
                onDownClicked: moveTime(-1,0)
                onDownLongClicked: moveTime(-12,0)
            }
            Text {
                id: separator
                height: hour.height
                width: units.nailUnit
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: hour.height / 2
                text: ':'
            }

            Common.BizoneButton {
                // Minutes
                id: minute
                content: '00'
                onUpClicked: moveTime(0,1)
                onUpLongClicked: moveTime(0,10)
                onDownClicked: moveTime(0,-1)
                onDownLongClicked: moveTime(0,-10)
            }
        }
    }

    function moveTime(hours,minutes) {
        if (hours != 0)
            time.setHours(time.getHours()+hours);
        if (minutes != 0)
            time.setMinutes(time.getMinutes()+minutes);
        updateDisplay();
        updatedByUser();
    }

    function updateDisplay() {
        var h = time.getHours()
        hour.content = ((h<10)?'0':'') + h
        var m = time.getMinutes()
        minute.content = ((m<10)?'0':'') + m
    }

    function setDateTime(newDate) {
        timePicker.time = new Date(newDate);
        console.log('Hora: ' + newDate.toString());
        updateDisplay();
    }

    function getTime() {
        return timePicker.time;
    }
}
