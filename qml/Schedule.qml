import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import "qrc:///common/FormatDates.js" as FormatDates
import "qrc:///javascript/Storage.js" as Storage
import "qrc:///javascript/NotebookEvent.js" as NotebookEvent


Rectangle {
    id: schedule
    property string pageTitle: qsTr('Agenda');
    signal newEvent
    signal editEvent(int id,string event, string desc,string startDate,string startTime,string endDate,string endTime)
    signal deletedEvents (int num)

    property var buttons: buttonsModel

    VisualItemModel {
        id: buttonsModel
        Button {
            text: qsTr('Nou')
        }
    }

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
                Button {
                    id: editButton
                    Layout.fillHeight: true
                    text: qsTr('Edita')
                    onClicked: editBox.state = 'show'
                }
                Common.SearchBox {
                    id: searchEvents
                    Layout.fillWidth: true
                    anchors.margins: units.nailUnit
                    onPerformSearch: scheduleModel.searchString = text
                }
                Button {
                    id: showOptionsButton
                    Layout.fillHeight: true
                    text: qsTr('Mostra')
                    menu: Menu {
                        title: qsTr('Mostra esdeveniments')
                        MenuItem {
                            id: showPending
                            text: qsTr('Pendents')
                            onTriggered: eventList.stateType = NotebookEvent.StateNotDone
                        }
                        MenuItem {
                            id: showDone
                            text: qsTr('Finalitzats')
                            onTriggered: eventList.stateType = NotebookEvent.StateDone
                        }
                        MenuItem {
                            id: showAll
                            text: qsTr('Tots')
                            onTriggered: eventList.stateType = NotebookEvent.StateAll
                        }
                    }
                }

                Button {
                    id: orderButton
                    Layout.fillHeight: true
                    text: qsTr('Ordre')
                    menu: Menu {
                        title: qsTr('Ordenació')
                        MenuItem {
                            text: qsTr('Per data inici')
                            onTriggered: eventList.order = 1;
                        }
                        MenuItem {
                            text: qsTr('Per data final')
                            onTriggered: eventList.order = 2;
                        }
                        MenuSeparator {}
                        MenuItem {
                            text: qsTr('Per data inici inversa')
                            onTriggered: eventList.order = 3;
                        }
                        MenuItem {
                            text: qsTr('Per data final inversa')
                            onTriggered: eventList.order = 4;
                        }
                    }
                }
            }
        }

        Common.EditBox {
            id: editBox
            maxHeight: units.fingerUnit
            Layout.preferredHeight: height
            Layout.fillWidth: true
            onCancel: scheduleModel.deselectAllObjects()
            onDeleteItems: deletedEvents(scheduleModel.removeSelectedObjects())
        }

        ListView {
            id: eventList
            Layout.preferredWidth: parent.width
            Layout.fillHeight: true
            property int order: 0
            property int stateType: NotebookEvent.StateNotDone
            clip: true

            onOrderChanged: {
                switch(eventList.order) {
                case 1:
                    scheduleModel.setSort(4,Qt.AscendingOrder);
                    break;
                case 2:
                    scheduleModel.setSort(6,Qt.AscendingOrder);
                    break;
                case 3:
                    scheduleModel.setSort(4,Qt.DescendingOrder);
                    break;
                case 4:
                    scheduleModel.setSort(6,Qt.DescendingOrder);
                    break;
                }
                scheduleModel.select();
            }

            onStateTypeChanged: {
                var filter;
                switch(eventList.stateType) {
                case NotebookEvent.StateNotDone:
                    filter = ["ifnull(state,'') != 'done'"];
                    break;
                case NotebookEvent.StateDone:
                    filter = ["state = 'done'"];
                    break;
                case NotebookEvent.StateAll:
                default:
                    filter = [];
                }

                scheduleModel.filters = filter;
                scheduleModel.select();
            }

            model: scheduleModel
            delegate: ScheduleItem {
                id: oneScheduleItem
                anchors.left: parent.left
                anchors.right: parent.right
                state: {
                    if (model.selected)
                        return 'selected'
                    else {
                        if ((model.state) && (model.state=='done')) {
                            return 'done'
                        } else {
                            return 'basic'
                        }
                    }
                }
                event: Storage.convertNull(model.event)
                desc: Storage.convertNull(model.desc)
                startDate: Storage.convertNull(model.startDate)
                startTime: Storage.convertNull(model.startTime)
                endDate: Storage.convertNull(model.endDate)
                endTime: Storage.convertNull(model.endTime)
                stateEvent: Storage.convertNull(model.state)

                onScheduleItemSelected: {
                    if (editBox.state == 'show') {
                        scheduleModel.selectObject(model.index,!scheduleModel.isSelectedObject(model.index));
                    } else {
                        switch(oneScheduleItem.state) {
                        case 'basic':
                            oneScheduleItem.state = 'expanded';
                            break;
                        case 'expanded':
                            oneScheduleItem.state = 'basic';
                            break;
                        default:
                            break;
                        }
                    }
                }
                onScheduleItemLongSelected: {
                    schedule.editEvent(id,event,desc,startDate,startTime,endDate,endTime);
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
                        font.pixelSize: units.readUnit
                        verticalAlignment: Text.AlignBottom
                        text: ((eventList.order==1)||(eventList.order==3)?qsTr('A partir de'):qsTr('Fins a')) + ' ' + (section!=''?(new Date()).fromYYYYMMDDFormat(section).toLongDate():qsTr('no especificat'))
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        scheduleModel.searchFields = ['event','desc'];
        eventList.order = 1;
    }
}
