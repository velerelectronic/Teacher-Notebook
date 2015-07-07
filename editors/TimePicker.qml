import QtQuick 2.0
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

Rectangle {
    id: timePicker
    property var time: new Date()
    signal updatedByUser()

    width: childrenRect.width
    height: childrenRect.height

    Common.UseUnits { id: units }
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        width: childrenRect.width
        height: childrenRect.height
        Row {
            width: hour.width + minute.width + spacing // + seconds.width
            height: childrenRect.height
            spacing: units.nailUnit

            Common.WheelButton {
                id: hour
                width: units.fingerUnit * 1.5
                height: units.fingerUnit * 4
                fromNumber: 0
                toNumber: 23
                onHighlightedValueChanged: {
                    time.setHours(getCurrentValue());
                    console.log("Current " + getCurrentValue());
                    updatedByUser();
                }
            }

            Common.WheelButton {
                id: minute
                width: units.fingerUnit * 1.5
                height: units.fingerUnit * 4
                fromNumber: 0
                toNumber: 59
                onHighlightedValueChanged: {
                    time.setMinutes(getCurrentValue());
                    updatedByUser();
                }
            }

            /*
            Common.WheelButton {
                id: seconds
                width: units.fingerUnit * 1.5
                height: units.fingerUnit * 4
                fromNumber: 0
                toNumber: 59
                onCurrentIndexChanged: {
                    time.setSeconds(currentIndex);
                    updatedByUser();
                }
            }
            */
        }
    }

    function updateDisplay() {
        var h = time.getHours()
        hour.moveToNumber(h);
        var m = time.getMinutes()
        minute.moveToNumber(m);
        //var s = time.getSeconds();
        //seconds.moveToNumber(s);
    }

    function setDateTime(newDate) {
        timePicker.time = new Date(newDate);
        updateDisplay();
    }

    function getTime() {
        return timePicker.time;
    }

    function timeString() {
        var d = timePicker.time;
        var hours = d.getHours();
        var minutes = d.getMinutes();
        // var seconds = d.getSeconds();
        return ((hours<10)?'0':'') + hours +  ':' + ((minutes<10)?'0':'') + minutes; // + ':' + ((seconds<10)?'0':'') + seconds;
    }
}
