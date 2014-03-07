import QtQuick 2.0
import QtQuick.Layouts 1.1
import 'common' as Common

Rectangle {
    id: datePicker
    property var date: new Date()
    property var months: [qsTr('gen'),qsTr('feb'),qsTr('mar'),qsTr('abr'),qsTr('mai'),qsTr('jun'),qsTr('jul'),qsTr('ago'),qsTr('set'),qsTr('oct'),qsTr('nov'),qsTr('des')]

    width: childrenRect.width
    height: childrenRect.height

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        width: childrenRect.width
        height: childrenRect.height
        Row {
            width: childrenRect.width
            height: childrenRect.height
            Common.BizoneButton {
                // days
                id: days
                width: units.fingerUnit * 2
                content: '0'
                onUpClicked: { date.setDate( date.getDate() + 1); datePicker.updateDate() }
                onUpLongClicked: { date.setDate( date.getDate() + 7); datePicker.updateDate() }
                onDownClicked: { date.setDate( date.getDate() - 1); datePicker.updateDate() }
                onDownLongClicked: { date.setDate( date.getDate() - 7); datePicker.updateDate() }
            }
            Text {
                text: '/'
            }

            Common.BizoneButton {
                // Months
                id: months
                width: units.fingerUnit * 2
                content: '00'
                onUpClicked: { date.setMonth( date.getMonth() + 1); datePicker.updateDate() }
                onUpLongClicked: { date.setMonth( date.getMonth() + 6); datePicker.updateDate() }
                onDownClicked: { date.setMonth( date.getMonth() - 1); datePicker.updateDate() }
                onDownLongClicked: { date.setMonth( date.getMonth() - 6); datePicker.updateDate() }
            }
            Text {
                text: '/'
            }
            Common.BizoneButton {
                // Year
                id: year
                width: units.fingerUnit * 2
                content: '00'
                onUpClicked: { date.setFullYear( date.getFullYear() + 1); datePicker.updateDate() }
                onUpLongClicked: {}
                onDownClicked: { date.setFullYear( date.getFullYear() - 1); datePicker.updateDate() }
                onDownLongClicked: {}
            }
        }
    }

    Component.onCompleted: datePicker.updateDate()

    function updateDate() {
        days.content = date.getDate();
        var m = date.getMonth();
        months.content = datePicker.months[m];
        year.content = date.getFullYear()
    }


    function setDate(newDate) {
        datePicker.date = newDate;
        updateDate();
    }

    function getDate() {
        return datePicker.date;
    }
}

