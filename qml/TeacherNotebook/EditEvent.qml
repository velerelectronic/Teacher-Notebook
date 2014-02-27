import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import "Storage.js" as Storage

Rectangle {
    id: newEvent
    property string title: qsTr('Edita esdeveniment')
    property int esquirolGraphicalUnit: 100

    signal saveEvent(string event, string desc,date startDate,date startTime,date endDate,date endTime)
    signal cancelEvent()
    property int idEvent: -1
    property alias event: event.text
    property alias desc: desc.text
    property alias startDate: startDate.date
    property alias startTime: startTime.time
    property alias endDate: endDate.date
    property alias endTime: endTime.time

    GridLayout {
        anchors.fill: parent
        columns: 2
        Text {
            text:qsTr('Esdeveniment o tasca')
            font.pointSize: 28
            Layout.columnSpan: 2
        }

        Text {
            text: qsTr('Esdeveniment')
        }
        Rectangle {
            border.color: 'black'
            Layout.fillWidth: true
            height: 100
            TextInput {
                id: event
                anchors.fill: parent
                clip: true
                wrapMode: TextInput.WrapAtWordBoundaryOrAnywhere
                inputMethodHints: Qt.ImhNoPredictiveText
            }
        }
        Text {
            text: qsTr('Descripció')
        }
        Rectangle {
            border.color: 'black'
            Layout.fillWidth: true
            Layout.fillHeight: true
            height: 100
            TextInput {
                id: desc
                anchors.fill: parent
                clip: true
                wrapMode: TextInput.WrapAtWordBoundaryOrAnywhere
                inputMethodHints: Qt.ImhNoPredictiveText
            }
        }
        Text {
            id: labelStart
            text: qsTr('Inici')
        }
        Rectangle {
            Layout.fillWidth: true

            RowLayout {
                width: parent.width
                height: childrenRect.height

                TimePicker {
                    id: startTime
                    Layout.fillHeight: true
                }

                DatePicker {
                    id: startDate
                    Layout.fillHeight: true
                }
                Button {
                    text: qsTr('Avui')
                    onClicked: {
                        var today = new Date();
                        startDate.toDate(today);
                        startTime.toDate(today);
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
            }
        }
        Text {
            text: qsTr('Final')
        }

        RowLayout {
            Layout.fillWidth: true
            height: childrenRect.height

            DatePicker {
                id: endDate
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            TimePicker {
                id: endTime
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            Button {
                text: qsTr('Avui')
                onClicked: {
                    var today = new Date();
                    endDate.toDate(today);
                    endTime.toDate(today);
                }
            }
        }

        Text { text: ' '}

        RowLayout {
            Button {
                text: qsTr('Desa')
                onClicked: {
                    newEvent.saveEvent(event.text,desc.text,startDate.getDate(),startTime.getTime(),endDate.getDate(),endTime.getTime());
                    Storage.saveEvent(event.text,desc.text,startDate.getDate(),startTime.getTime(),endDate.getDate(),endTime.getTime());
                }
            }
            Button {
                text: qsTr('Cancela')
                onClicked: newEvent.cancelEvent()
            }
        }
    }
    Component.onCompleted: {
        if (typeof newEvent.idEvent != 'undefined') {
            var details = Storage.getDetailsEventId();
        }
    }
}
