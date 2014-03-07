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
    signal editEvent(int id,string event, string desc,string startDate,string startTime,string endDate,string endTime)

    Common.UseUnits { id: units }

    ColumnLayout {
        anchors.fill: parent
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height

            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: childrenRect.height

                Button {
                    id: buttons
                    Layout.fillHeight: true
                    text: qsTr('Nou esdeveniment')
                    onClicked: schedule.newEvent()
                }
                Common.SearchBox {
                    id: searchEvents
                    Layout.fillWidth: true
                    anchors.margins: units.nailUnit
                    onPerformSearch: Storage.listEvents(scheduleModel,null,text)
                }
                Button {
                    id: editButton
                    Layout.fillHeight: true
                    text: qsTr('Edita')
                    onClicked: editBox.state = 'show'
                }
            }
            Common.EditBox {
                id: editBox
                Layout.fillWidth: true
            }
        }


        ListView {
            Layout.preferredWidth: parent.width
            Layout.fillHeight: true
            clip: true

            model: ListModel { id: scheduleModel }
            delegate: Rectangle {
                id: element
                anchors.left: parent.left
                anchors.right: parent.right
                height: childrenRect.height
                border.color: 'black'

                RowLayout {
                    width: parent.width
                    height: childrenRect.height
                    spacing: 0

                    Rectangle {
                        color: 'yellow'
                        border.color: 'black'
                        Layout.preferredWidth: units.fingerUnit * 8
                        Layout.preferredHeight: units.nailUnit * 3
                        GridLayout {
                            anchors.fill: parent
                            rows: 2
                            flow: GridLayout.TopToBottom
                            columnSpacing: 0
                            rowSpacing: 0

                            Text {
                                Layout.preferredWidth: units.fingerUnit * 2
                                Layout.preferredHeight: units.nailUnit
                                font.pixelSize: units.nailUnit
                                text: startDate
                            }
                            Text {
                                Layout.preferredWidth: units.fingerUnit * 2
                                Layout.preferredHeight: units.nailUnit
                                font.pixelSize: units.nailUnit
                                text: startTime
                            }
                            Text {
                                Layout.preferredWidth: units.fingerUnit * 2
                                Layout.preferredHeight: units.nailUnit
                                font.pixelSize: units.nailUnit
                                text: endDate
                            }
                            Text {
                                Layout.preferredWidth: units.fingerUnit * 2
                                Layout.preferredHeight: units.nailUnit
                                font.pixelSize: units.nailUnit
                                text: endTime
                            }
                        }
                    }

                    Rectangle {
                        id: mainContents
                        color: 'green'
                        border.color: 'black'
                        Layout.fillWidth: true
                        Layout.preferredHeight: childrenRect.height
                        clip: true

                        ColumnLayout {
                            Text {
                                id: eventTitle
                                Layout.preferredWidth: parent.width
                                Layout.preferredHeight: paintedHeight
                                font.bold: true
                                text: event
                                wrapMode: Text.Wrap
                            }
                            Text {
                                id: eventDesc
                                Layout.preferredWidth: parent.width
                                Layout.preferredHeight: paintedHeight
                                text: desc
                                wrapMode: Text.Wrap
                            }
                        }
                        MouseArea {
                            anchors.fill: mainContents

                            onClicked: schedule.editEvent(id,event,desc,startDate,startTime,endDate,endTime)
                            onPressAndHold: {
                                Storage.removeEvent(id);
                                console.log(index);
                                scheduleModel.remove(index);
                            }
                        }
                    }
                }
            }
        }

    }

    Component.onCompleted: Storage.listEvents(scheduleModel,null,null)
}
