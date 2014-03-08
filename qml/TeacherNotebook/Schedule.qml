import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.1
import 'common' as Common
import 'Storage.js' as Storage

Rectangle {
    id: schedule
    property string pageTitle: qsTr('Agenda');
    signal newEvent
    signal editEvent(int id,string event, string desc,string startDate,string startTime,string endDate,string endTime)
    signal deletedEvents (int num)

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
                    onPerformSearch: eventList.recalculateList()
                }
                Button {
                    id: orderButton
                    Layout.fillHeight: true
                    text: qsTr('Ordre')
                    menu: Menu {
                        title: qsTr('Ordenacio')
                        MenuItem {
                            text: qsTr('Per data inici')
                            onTriggered: {
                                eventList.order = 1;
                                eventList.recalculateList();
                            }
                        }
                        MenuItem {
                            text: qsTr('Per data final')
                            onTriggered: {
                                eventList.order = 2;
                                eventList.recalculateList();
                            }
                        }
                        MenuSeparator {}
                        MenuItem {
                            text: qsTr('Per data inici inversa')
                            onTriggered: {
                                eventList.order = 3;
                                eventList.recalculateList();
                            }
                        }
                        MenuItem {
                            text: qsTr('Per data final inversa')
                            onTriggered: {
                                eventList.order = 4;
                                eventList.recalculateList();
                            }
                        }
                    }
                }

                Button {
                    id: editButton
                    Layout.fillHeight: true
                    text: qsTr('Edita')
                    onClicked: editBox.state = 'show'
                }
            }
        }

        Common.EditBox {
            id: editBox
            maxHeight: units.fingerUnit
            Layout.preferredHeight: height
            Layout.fillWidth: true
            onCancel: eventList.unselectAll()
            onDeleteItems: eventList.deleteSelected()
        }

        ListView {
            id: eventList
            Layout.preferredWidth: parent.width
            Layout.fillHeight: true
            property int order: 1
            clip: true

            model: ListModel { id: scheduleModel }
            delegate: ScheduleItem {
                anchors.left: parent.left
                anchors.right: parent.right
                state: (model.selected)?'selected':'basic'
                event: model.event
                desc: model.desc
                startDate: model.startDate
                startTime: model.startTime
                endDate: model.endDate
                endTime: model.endTime

                onScheduleItemSelected: {
                    if (editBox.state == 'show') {
                        scheduleModel.setProperty(model.index,'selected',!scheduleModel.get(model.index).selected);
                    } else {
                        schedule.editEvent(id,event,desc,startDate,startTime,endDate,endTime);
                    }
                }
            }
            snapMode: ListView.SnapToItem

            section.property: ((order==1)||(order==3))?"startDate":"endDate"
            section.criteria: ViewSection.FullString
            section.labelPositioning: ViewSection.InlineLabels
            section.delegate: Component {
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: 'white'
                    height: units.fingerUnit
                    Text {
                        anchors.fill: parent
                        font.bold: true
                        font.pixelSize: units.nailUnit * 1.5
                        verticalAlignment: Text.AlignBottom
                        text: ((eventList.order==1)||(eventList.order==3)?qsTr('A partir de'):qsTr('Fins a')) + ' ' + (section!=''?(new Date()).fromYYYYMMDDFormat(section).toLongDate():qsTr('no especificat'))
                    }
                }
            }

            function recalculateList() {
                Storage.listEvents(scheduleModel,null,searchEvents.text,eventList.order)
            }

            function unselectAll() {
                for (var i=0; i<scheduleModel.count; i++) {
                    scheduleModel.setProperty(i,'selected',false);
                    console.log('Desselecciona ' + i);
                }
            }

            function deleteSelected() {
                // Start deleting from the end of the model, because the index of further items change when deleting a previous item.
                var num = 0;
                for (var i=scheduleModel.count-1; i>=0; --i) {
                    if (scheduleModel.get(i).selected) {
                        Storage.removeEvent(scheduleModel.get(i).id);
                        scheduleModel.remove(i);
                        num++;
                    }
                }
                schedule.deletedEvents(num);
            }
        }

    }

    Component.onCompleted: eventList.recalculateList()
}
