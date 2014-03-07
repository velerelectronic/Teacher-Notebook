import QtQuick 2.0
import QtQuick.Layouts 1.1
import 'common' as Common

Rectangle {
    id: scheduleItem
    state: 'basic'
    states: [
        State {
            name: 'basic'
            PropertyChanges { target: datesRect; color: 'yellow' }
            PropertyChanges { target: mainContents; color: 'green' }
        },
        State {
            name: 'selected'
            PropertyChanges { target: datesRect; color: 'grey' }
            PropertyChanges { target: mainContents; color: 'grey' }
        }
    ]
    transitions: [
        Transition {
            PropertyAnimation {
                properties: 'color'
                easing.type: Easing.Linear
            }
        }
    ]

    property alias event: eventTitle.text
    property alias desc: eventDesc.text
    property alias startDate: startDate.text
    property alias startTime: startTime.text
    property alias endDate: endDate.text
    property alias endTime: endTime.text

    signal scheduleItemSelected (string event,string desc,string startDate,string startTime,string endDate,string endTime)

    height: Math.max(units.nailUnit * 3, eventTitle.height+eventDesc.height)
    border.color: 'black'

    Common.UseUnits { id: units }

    RowLayout {
        width: parent.width
        height: parent.height
        spacing: 0

        Rectangle {
            id: datesRect
            color: 'yellow'
            border.color: 'black'
            Layout.preferredWidth: units.fingerUnit * 8
            Layout.preferredHeight: parent.height
            GridLayout {
                anchors.fill: parent
                rows: 2
                flow: GridLayout.TopToBottom
                columnSpacing: 0
                rowSpacing: 0

                Text {
                    id: startDate
                    Layout.preferredWidth: units.fingerUnit * 2
                    Layout.preferredHeight: units.nailUnit
                    font.pixelSize: units.nailUnit
                    font.bold: true
                }
                Text {
                    id: startTime
                    Layout.preferredWidth: units.fingerUnit * 2
                    Layout.preferredHeight: units.nailUnit
                    font.pixelSize: units.nailUnit
                }
                Text {
                    id: endDate
                    Layout.preferredWidth: units.fingerUnit * 2
                    Layout.preferredHeight: units.nailUnit
                    font.pixelSize: units.nailUnit
                    font.bold: true
                }
                Text {
                    id: endTime
                    Layout.preferredWidth: units.fingerUnit * 2
                    Layout.preferredHeight: units.nailUnit
                    font.pixelSize: units.nailUnit
                }
            }
        }

        Rectangle {
            id: mainContents
            color: 'green'
            border.color: 'black'
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height
            clip: true

            ColumnLayout {
                Text {
                    id: eventTitle
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: paintedHeight
                    font.bold: true
                    wrapMode: Text.Wrap
                }
                Text {
                    id: eventDesc
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: paintedHeight
                    wrapMode: Text.Wrap
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: scheduleItem.scheduleItemSelected(scheduleItem.event,scheduleItem.desc,scheduleItem.startDate,scheduleItem.startTime,scheduleItem.endDate,scheduleItem.endTime)
    }
}


