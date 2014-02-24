import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.1
import 'common' as Common
import 'Storage.js' as Storage

Rectangle {
    id: schedule
    property string title: qsTr('Agenda');
    property int esquirolGraphicalUnit: 100
    signal newEvent
    signal editEvent(int id,string event, string desc,date startDate,date startTime,date endDate,date endTime)

    ColumnLayout {
        anchors.fill: parent
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Button {
                id: buttons
                Layout.fillHeight: true
                text: 'Nou esdeveniment'
                onClicked: schedule.newEvent()
            }
            Common.SearchBox {
                id: searchEvents
                Layout.fillWidth: true
                anchors.margins: 10
                onPerformSearch: Storage.listEvents(scheduleModel,null,text)
            }
            Button {
                id: editButton
                Layout.fillHeight: true
                text: 'Edita'
                onClicked: editBox.state = 'show'
            }
        }
        Common.EditBox {
            id: editBox
            Layout.preferredHeight: height
            Layout.fillWidth: true
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            model: ListModel { id: scheduleModel }
            delegate: Rectangle {
                id: element
                anchors.left: parent.left
                anchors.right: parent.right
                height: childrenRect.height + 40
                border.color: 'black'

                RowLayout {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 20
                    height: mainContents.height

                    ColumnLayout {
                        id: mainContents
                        anchors.top: parent.top
                        Layout.fillWidth: true
                        height: childrenRect.height

                        Text {
                            id: eventTitle
                            font.bold: true
                            text: event
                            anchors.left: parent.left
                            anchors.right: parent.right
                        }
                        Text {
                            id: eventDesc
                            text: desc
                            anchors.left: parent.left
                            anchors.right: parent.right
                        }
                        MouseArea {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: eventTitle.top
                            anchors.bottom: eventDesc.bottom

                            onClicked: schedule.editEvent(id,event,desc,startDate,startTime,endDate,endTime)
                            onPressAndHold: {
                                Storage.removeEvent(id);
                                console.log(index);
                                scheduleModel.remove(index);
                            }
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        Layout.preferredWidth: 100
                        text: startDate
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        Layout.preferredWidth: 100
                        text: startTime
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        Layout.preferredWidth: 100
                        text: endDate
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        Layout.preferredWidth: 100
                        text: endTime
                    }
                }
            }
        }

    }

    Component.onCompleted: Storage.listEvents(scheduleModel,null,null)
}
