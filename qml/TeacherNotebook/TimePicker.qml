import QtQuick 2.0
import QtQuick.Layouts 1.1
import 'common' as Common

Rectangle {
    id: timePicker
    property var time: new Date()
    anchors.fill: parent

    Common.UseUnits { id: units }
    Rectangle {
        anchors.fill: parent
        RowLayout {
            anchors.fill: parent
            Common.BitouchButton {
                // Hours
                id: hour
                Layout.preferredWidth: units.fingerUnit * 2
                content: '0'
                onUpClicked: { time.setHours( time.getHours() + 1); timePicker.updateTime() }
                onUpLongClicked:  { time.setHours( time.getHours() + 12); timePicker.updateTime() }
                onDownClicked: { time.setHours( time.getHours() - 1); timePicker.updateTime() }
                onDownLongClicked: { time.setHours( time.getHours() - 12); timePicker.updateTime() }
            }
            Text {
                text: ':'
            }

            Common.BitouchButton {
                // Minutes
                id: minute
                Layout.preferredWidth: units.fingerUnit * 2
                content: '00'
                onUpClicked: { time.setMinutes( time.getMinutes() + 1); timePicker.updateTime() }
                onUpLongClicked: { time.setMinutes( time.getMinutes() + 10); timePicker.updateTime() }
                onDownClicked: { time.setMinutes( time.getMinutes() - 1); timePicker.updateTime() }
                onDownLongClicked: { time.setMinutes( time.getMinutes() - 10); timePicker.updateTime() }
            }
        }
    }

    Component.onCompleted: timePicker.updateTime()

    function updateTime() {
        var h = time.getHours()
        hour.content = ((h<10)?'0':'') + h
        var m = time.getMinutes()
        minute.content = ((m<10)?'0':'') + m
    }

    function toDate(newDate) {
        timePicker.time = newDate;
        updateTime();
    }

    function getTime() {
        return timePicker.time.toTimeSpecificFormat();
    }
}
