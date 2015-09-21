import QtQuick 2.0
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common

Rectangle {
    id: scheduleItem
    state: 'basic'
    states: [
        State {
            name: 'basic'
            PropertyChanges {
                target: scheduleItem
                height: units.fingerUnit * 2
            }
            PropertyChanges { target: startRect; color: '#ffd06e' }
            PropertyChanges { target: endRect; color: '#ffd06e' }
            PropertyChanges { target: mainContents; color: '#EFFBF5' }
        },
        State {
            name: 'expanded'
            PropertyChanges {
                target: scheduleItem
                height: Math.max(units.fingerUnit * 2, eventTitle.height + eventDesc.height + units.nailUnit * 3)
            }

            PropertyChanges { target: startRect; color: '#ffd06e' }
            PropertyChanges { target: endRect; color: '#ffd06e' }
            PropertyChanges { target: mainContents; color: '#EFFBF5' }
        },
        State {
            name: 'done'
            PropertyChanges {
                target: scheduleItem
                height: Math.max(units.fingerUnit * 2, eventTitle.height + eventDesc.height + units.nailUnit * 3)
            }
            PropertyChanges { target: startRect; color: '#E6E6E6' }
            PropertyChanges { target: endRect; color: '#E6E6E6' }
            PropertyChanges { target: mainContents; color: '#E6E6E6' }
        },
        State {
            name: 'selected'
            PropertyChanges {
                target: scheduleItem
                height: units.fingerUnit * 2
            }
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

    property int idEvent: -1
    property string title: ''
    property alias desc: eventDesc.text
    property alias startDate: startDate.text
    property alias startTime: startTime.text
    property alias endDate: endDate.text
    property alias endTime: endTime.text
    property var stateEvent: ''
    property int project: -1
    property string annotationTitleDesc: ''
    property string section: ''

    Component.onCompleted: {
    }

    signal scheduleItemSelected (int event,string desc,string startDate,string startTime,string endDate,string endTime)
    signal scheduleItemLongSelected (int event)

    border.color: 'black'

    Common.UseUnits { id: units }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Common.BoxedText {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width / 5
            text: scheduleItem.section
            margins: units.nailUnit
        }

        Rectangle {
            id: startRect
            Layout.preferredWidth: parent.width / 5
            Layout.fillHeight: true
            border.color: 'black'
            Text {
                id: startDate
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: parent.verticalCenter
                }

                font.pixelSize: units.readUnit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
            }
            Text {
                id: startTime
                anchors {
                    top: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: units.readUnit
            }
        }

        Rectangle {
            id: endRect
            Layout.preferredWidth: parent.width / 5
            Layout.fillHeight: true
            border.color: 'black'

            Text {
                id: endDate
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: parent.verticalCenter
                }
                font.pixelSize: units.readUnit
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            Text {
                id: endTime
                anchors {
                    top: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                font.pixelSize: units.readUnit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
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
                    text: scheduleItem.title + ' - ' + scheduleItem.annotationTitleDesc
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
        onClicked: scheduleItem.scheduleItemSelected(scheduleItem.idEvent,scheduleItem.desc,scheduleItem.startDate,scheduleItem.startTime,scheduleItem.endDate,scheduleItem.endTime)
        onPressAndHold: scheduleItem.scheduleItemLongSelected(scheduleItem.idEvent)
    }

    Common.ExtraInfo {
        minHeight: units.fingerUnit * 2
        contentHeight: eventTitle.height + eventDesc.height + units.nailUnit * 3
        available: scheduleItem.state == 'basic'
    }

}


