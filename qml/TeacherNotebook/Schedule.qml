import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.1
import 'common' as Common
import 'Storage.js' as Storage

Rectangle {
    id: schedule
    property string title: qsTr('Agenda');
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

            function unselectAll() {
                for (var i=0; i<scheduleModel.count; i++) {
                    scheduleModel.setProperty(i,'selected',false);
                    console.log('Desselecciona ' + i);
                }
            }

            function deleteSelected() {
                // Start deleting from the end of the model, because the index of further items change when deleting a previous item.
                for (var i=scheduleModel.count-1; i>=0; --i) {
                    if (scheduleModel.get(i).selected) {
                        Storage.removeEvent(scheduleModel.get(i).id);
                        scheduleModel.remove(i);
                    }
                }
            }
        }

    }

    Component.onCompleted: Storage.listEvents(scheduleModel,null,null)
}
