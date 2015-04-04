import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import PersonalTypes 1.0
import "qrc:///javascript/NotebookEvent.js" as NotebookEvent
import "qrc:///common/FormatDates.js" as FormatDates
import 'qrc:///common' as Common

Rectangle {
    id: tasksSystem

    Common.UseUnits { id: units }

    property string pageTitle: qsTr('Tasques i esdeveniments')

    property var buttons: buttonsModel
    signal emitSignal(string name, var param)

    signal newEvent(var projectsModel)
    signal editEvent(int idEvent,string event, string desc,string startDate,string startTime,string endDate,string endTime,int project,var projectsModel)

    property int order: -1
    property int stateType: NotebookEvent.StateNotDone

    property var firstDate
    property var lastDate

    property var stateFilter: []
    property var timeFilter: []

    onOrderChanged: {
        switch(tasksSystem.order) {
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
        default:
            scheduleModel.setSort(9,Qt.DescendingOrder);
        }
        scheduleModel.select();
        if (typeof tasksLoader.item.order !== 'undefined')
            tasksLoader.item.order = order;
    }

    function changeScheduleFilters() {
        scheduleModel.filters = stateFilter.concat(timeFilter);
        console.log('Changing filters ' + scheduleModel.filters);
        console.log('Selecting with filters');
        scheduleModel.select();
    }

    function changeTimeFilter() {
        timeFilter = [];
        timeFilter.push("startDate>='" + firstDate.toYYYYMMDDFormat() + "' OR ifnull(startDate,'')=''");
        timeFilter.push("endDate<='" + lastDate.toYYYYMMDDFormat() + "' OR ifnull(endDate,'')=''");
        console.log(timeFilter);
        changeScheduleFilters();
    }

    onStateTypeChanged: {
        switch(tasksSystem.stateType) {
        case NotebookEvent.StateNotDone:
            stateFilter = ["ifnull(state,'') != 'done'"];
            break;
        case NotebookEvent.StateDone:
            stateFilter = ["state = 'done'"];
            break;
        case NotebookEvent.StateAll:
        default:
            stateFilter = [];
        }
        changeScheduleFilters();
    }



    ListModel {
        id: buttonsModel
        ListElement {
            method: 'createEvent'
            image: 'plus-24844'
        }
        ListElement {
            method: 'showCalendar'
            image: 'calendar-23684'
        }
        ListElement {
            method: 'showList'
            image: 'list-153185'
        }
        ListElement {
            method: 'showGantt'
            image: 'percent-40844'
        }
    }

    function createEvent() {
        newEvent(projectsModel);
        emitSignal('ShowEvent',{projectsModel: projectsModel});
    }

    function showCalendar() {
        tasksLoader.setSource(Qt.resolvedUrl('Calendar.qml'), {searchString: scheduleModel.searchString, projectsModel: projectsModel});
    }

    function showGantt() {
        tasksLoader.setSource(Qt.resolvedUrl('GanttDiagram.qml'), {projectsModel: projectsModel, startDateLimit: firstDate, endDateLimit: lastDate});
    }

    function showList() {
        tasksLoader.setSource(Qt.resolvedUrl('Schedule.qml'), {searchString: scheduleModel.searchString, projectsModel: projectsModel})
    }

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
                            onTriggered: tasksSystem.stateType = NotebookEvent.StateNotDone
                        }
                        MenuItem {
                            id: showDone
                            text: qsTr('Finalitzats')
                            onTriggered: tasksSystem.stateType = NotebookEvent.StateDone
                        }
                        MenuItem {
                            id: showAll
                            text: qsTr('Tots')
                            onTriggered: tasksSystem.stateType = NotebookEvent.StateAll
                        }
                        MenuSeparator {

                        }
                        MenuItem {
                            id: decreaseStart
                            text: qsTr('Retrocedeix una setmana')
                            onTriggered: {
                                firstDate.setDate(firstDate.getDate()-7);
                                lastDate.setDate(lastDate.getDate()-7);
                                changeTimeFilter();
                            }
                        }
                        MenuItem {
                            id: increaseStart
                            text: qsTr('Avança una setmana')
                            onTriggered: {
                                firstDate.setDate(firstDate.getDate()+7);
                                lastDate.setDate(lastDate.getDate()+7);
                                changeTimeFilter();
                            }
                        }
                        MenuItem {
                            id: decreaseTimeInterval
                            text: qsTr('Disminueix interval de temps en un mes')
                            onTriggered: {
                                if (firstDate.differenceInDays(lastDate)>31) {
                                    lastDate.setMonth(lastDate.getMonth()-1);
                                    changeTimeFilter();
                                }
                            }
                        }
                        MenuItem {
                            id: showOneDayLessAtEnd
                            text: qsTr('Augmenta interval de temps en un mes')
                            onTriggered: {
                                lastDate.setMonth(lastDate.getMonth()+1);
                                changeTimeFilter();
                            }
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
                            onTriggered: tasksSystem.order = 1;
                        }
                        MenuItem {
                            text: qsTr('Per data final')
                            onTriggered: tasksSystem.order = 2;
                        }
                        MenuSeparator {}
                        MenuItem {
                            text: qsTr('Per data inici inversa')
                            onTriggered: tasksSystem.order = 3;
                        }
                        MenuItem {
                            text: qsTr('Per data final inversa')
                            onTriggered: tasksSystem.order = 4;
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


        Loader {
            id: tasksLoader
            Layout.fillHeight: true
            Layout.fillWidth: true

            Connections {
                target: tasksLoader.item
                ignoreUnknownSignals: true
                onEditEvent: {
                    tasksSystem.editEvent(idEvent, event, desc, startDate, startTime, endDate, endTime, project, projectsModel);
                    tasksSystem.emitSignal('ShowEvent',{idEvent: idEvent, event: event, desc: desc, startDate: startDate, startTime: startTime, endDate: endDate, endTime: endTime, project: project, projectsModel: projectsModel});
                }
            }

            Component.onCompleted: showGantt()
        }
    }

    SqlTableModel {
        id: projectsModel
        tableName: 'projects'
        fieldNames: ['id, name, desc']

        Component.onCompleted: {
            select();
        }
    }

    Component.onCompleted: {
        order = 0;
        searchEvents.text = scheduleModel.searchString;
        scheduleModel.searchFields = ['event','desc'];

        var date = new Date();
        firstDate = new Date(date.getFullYear(),date.getMonth(),date.getDate()-15);
        lastDate = new Date(date.getFullYear(),date.getMonth(),date.getDate()+15);
        changeTimeFilter();
    }
}

