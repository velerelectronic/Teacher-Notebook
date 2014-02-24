import QtQuick 2.0
import QtQuick.Layouts 1.1
import 'common' as Common

Rectangle {
    id: timePicker
    property int esquirolGraphicalUnit: 100
    property var time: new Date()
    anchors.fill: parent

    GridLayout {
        columns: 3
        rows: 3

        Common.SimpleButton {
            // Hours plus
            label: '+'
            border.color: 'black'
            onClicked: { time.setHours( time.getHours() + 1); timePicker.updateTime() }
            onPressAndHold: { time.setHours( time.getHours() + 12); timePicker.updateTime() }
        }

        Text {
            // Separator
            text:' '
        }

        Common.SimpleButton {
            // Minutes plus
            label: '+'
            border.color: 'black'
            onClicked: { time.setMinutes( time.getMinutes() + 1); timePicker.updateTime() }
            onPressAndHold: { time.setMinutes( time.getMinutes() + 10); timePicker.updateTime() }
        }

        Rectangle {
            id: hourRect
            width: childrenRect.width
            height: childrenRect.height
            color: 'yellow'
            border.color: 'black'
            Text {
                id: hour
            }
        }

        Text {
            text: ':'
        }

        Rectangle {
            id: minuteRect
            width: childrenRect.width
            height: childrenRect.height
            color: 'pink'
            Text {
                id: minute
            }
        }

        Common.SimpleButton {
            // Hours minus
            label: '-'
            border.color: 'black'
            onClicked: { time.setHours( time.getHours() - 1); timePicker.updateTime() }
            onPressAndHold: { time.setHours( time.getHours() - 12); timePicker.updateTime() }
        }

        Text {
            // Separator
            text: ' '
        }

        Common.SimpleButton {
            // Minutes minus
            label: '-'
            border.color: 'black'
            onClicked: { time.setMinutes( time.getMinutes() - 1); timePicker.updateTime() }
            onPressAndHold: { time.setMinutes( time.getMinutes() - 10); timePicker.updateTime() }
        }

    }

    Component.onCompleted: timePicker.updateTime()

    function updateTime() {
        var h = time.getHours()
        hour.text = ((h<10)?'0':'') + h
        var m = time.getMinutes()
        minute.text = ((m<10)?'0':'') + m
    }

    function toDate(newDate) {
        timePicker.time = newDate;
        updateTime();
    }

    function getTime() {
        return timePicker.time.toTimeSpecificFormat();
    }
}
