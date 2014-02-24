import QtQuick 2.0
import QtQuick.Layouts 1.1
import 'common' as Common

Rectangle {
    id: datePicker
    property var date: new Date()
    property var months: [qsTr('gener'),qsTr('febrer'),qsTr('març'),qsTr('abril'),qsTr('maig'),qsTr('juny'),qsTr('juliol'),qsTr('agost'),qsTr('setembre'),qsTr('octubre'),qsTr('novembre'),qsTr('desembre')]
    property int esquirolGraphicalUnit: 100

    anchors.fill: parent

    GridLayout {
        columns: 3
        rows: 3

        Common.SimpleButton {
            // Days plus
            label: '+'
            border.color: 'black'
            onClicked: { date.setDate( date.getDate() + 1); datePicker.updateDate() }
            onPressAndHold: { date.setDate( date.getDate() + 7); datePicker.updateDate() }
        }

        Common.SimpleButton {
            // Months plus
            label: '+'
            border.color: 'black'
            onClicked: { date.setMonth( date.getMonth() + 1); datePicker.updateDate() }
            onPressAndHold: { date.setMonth( date.getMonth() + 6); datePicker.updateDate() }
        }

        Common.SimpleButton {
            // Years plus
            label: '+'
            border.color: 'black'
            onClicked: { date.setFullYear( date.getFullYear() + 1); datePicker.updateDate() }
        }

        Rectangle {
            id: dayRect
            width: childrenRect.width
            height: childrenRect.height
            color: 'yellow'
            border.color: 'black'
            Text {
                id: day
            }
        }

        Rectangle {
            id: monthRect
            width: childrenRect.width
            height: childrenRect.height
            color: 'yellow'
            border.color: 'black'
            Text {
                id: month
            }
        }

        Rectangle {
            id: yearRect
            width: childrenRect.width
            height: childrenRect.height
            color: 'pink'
            Text {
                id: year
            }
        }

        Common.SimpleButton {
            // Days minus
            label: '-'
            border.color: 'black'
            onClicked: { date.setDate( date.getDate() - 1); datePicker.updateDate() }
            onPressAndHold: { date.setDate( date.getDate() - 7); datePicker.updateDate() }
        }

        Common.SimpleButton {
            // Months minus
            label: '-'
            border.color: 'black'
            onClicked: { date.setMonth( date.getMonth() - 1); datePicker.updateDate() }
            onPressAndHold: { date.setMonth( date.getMonth() - 6); datePicker.updateDate() }
        }

        Common.SimpleButton {
            // Years minus
            label: '-'
            border.color: 'black'
            onClicked: { date.setFullYear( date.getFullYear() - 1); datePicker.updateDate()  }
        }

    }

    Component.onCompleted: datePicker.updateDate()

    function updateDate() {
        day.text = date.getDate();
        dayRect.width = dayRect.childrenRect.width

        var m = date.getMonth();
        month.text = datePicker.months[m];
        monthRect.width = monthRect.childrenRect.width

        year.text = date.getFullYear()
        yearRect.width = yearRect.childrenRect.width
    }


    function toDate(newDate) {
        datePicker.date = newDate;
        updateDate();
    }

    function getDate() {
        return datePicker.date.toDateSpecificFormat();
    }
}

