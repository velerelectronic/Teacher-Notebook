import QtQuick 2.0
import QtQuick.Layouts 1.1
import 'common' as Common

Rectangle {
    id: scheduleItem
    state: 'basic'
    states: [
        State {
            name: 'basic'
            PropertyChanges { target: datesRect; color: '#ffd06e' }
            PropertyChanges { target: mainContents; color: '#EFFBF5' }
        },
        State {
            name: 'done'
            PropertyChanges { target: datesRect; color: '#E6E6E6' }
            PropertyChanges { target: mainContents; color: '#E6E6E6' }
        },
        State {
            name: 'selected'
            PropertyChanges { target: datesRect; color: '#58FAAC' }
            PropertyChanges { target: mainContents; color: '#58FAAC' }
        },
        State {
            name: 'hidden'
            PropertyChanges { target: scheduleItem; height: 0 }
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
    property var stateEvent: ''

    signal scheduleItemSelected (string event,string desc,string startDate,string startTime,string endDate,string endTime)

    height: Math.max(units.fingerUnit, eventTitle.height + eventDesc.height + units.nailUnit * 3)
    border.color: 'black'

    Common.UseUnits { id: units }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: datesRect
            border.color: 'black'
            Layout.preferredWidth: units.fingerUnit * 6 + 2 * units.nailUnit
            Layout.preferredHeight: parent.height
            GridLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit

                rows: 3
                flow: GridLayout.TopToBottom
                columnSpacing: 0
                rowSpacing: units.nailUnit

                Text {
                    id: startDate
                    Layout.preferredWidth: units.fingerUnit * 3
                    Layout.preferredHeight: units.nailUnit
                    font.pixelSize: units.nailUnit
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                }
                Text {
                    id: startTime
                    Layout.preferredWidth: units.fingerUnit * 3
                    Layout.preferredHeight: units.nailUnit
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: units.nailUnit
                }
                Item {
                    Layout.fillHeight: true
                }

                Text {
                    id: endDate
                    Layout.preferredWidth: units.fingerUnit * 3
                    Layout.preferredHeight: units.nailUnit
                    font.pixelSize: units.nailUnit
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    id: endTime
                    Layout.preferredWidth: units.fingerUnit * 3
                    Layout.preferredHeight: units.nailUnit
                    font.pixelSize: units.nailUnit
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Rectangle {
            id: mainContents
            border.color: 'black'
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                spacing: units.nailUnit

                Text {
                    id: eventTitle
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: paintedHeight
                    font.bold: true
                    textFormat: Text.PlainText
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
                Text {
                    id: eventDesc
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: paintedHeight
                    textFormat: Text.PlainText
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: scheduleItem.scheduleItemSelected(scheduleItem.event,scheduleItem.desc,scheduleItem.startDate,scheduleItem.startTime,scheduleItem.endDate,scheduleItem.endTime)
    }
}


