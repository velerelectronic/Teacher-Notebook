import QtQuick 2.0
import QtQuick.Layouts 1.1
import 'common' as Common

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
            width: hour.width + separator.width + minute.width
            height: childrenRect.height
            Common.BizoneButton {
                // Hours
                id: hour
                content: '0'
                onUpClicked: { time.setHours( time.getHours() + 1); timePicker.updateTime(true) }
                onUpLongClicked:  { time.setHours( time.getHours() + 12); timePicker.updateTime(true) }
                onDownClicked: { time.setHours( time.getHours() - 1); timePicker.updateTime(true) }
                onDownLongClicked: { time.setHours( time.getHours() - 12); timePicker.updateTime(true) }
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
                onUpClicked: { time.setMinutes( time.getMinutes() + 1); timePicker.updateTime(true) }
                onUpLongClicked: { time.setMinutes( time.getMinutes() + 10); timePicker.updateTime(true) }
                onDownClicked: { time.setMinutes( time.getMinutes() - 1); timePicker.updateTime(true) }
                onDownLongClicked: { time.setMinutes( time.getMinutes() - 10); timePicker.updateTime(true) }
            }
        }
    }

    Component.onCompleted: timePicker.updateTime(false)

    function updateTime(sendSignal) {
        var h = time.getHours()
        hour.content = ((h<10)?'0':'') + h
        var m = time.getMinutes()
        minute.content = ((m<10)?'0':'') + m
        if (sendSignal) {
            updatedByUser()
        }
    }

    function setDateTime(newDate) {
        timePicker.time = new Date(newDate);
        updateTime(false);
    }

    function getTime() {
        return timePicker.time;
    }
}
