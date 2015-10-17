import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import PersonalTypes 1.0
import "qrc:///javascript/NotebookEvent.js" as NotebookEvent
import "qrc:///common/FormatDates.js" as FormatDates
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Rectangle {
    id: tasksSystem

    Common.UseUnits { id: units }

    property string pageTitle: qsTr('Tasques i esdeveniments')

    property var buttons: buttonsModel
    signal emitSignal(string name, var param)

    signal newEvent(var parameters)
    signal showEvent(var parameters)

    property int project: -1
    property int order: -1
    property int stateType: NotebookEvent.StateNotDone

    property var firstDate
    property var lastDate

    property var stateFilter: []
    property var timeFilter: []

    onOrderChanged: {
        switch(tasksSystem.order) {
        case 1:
            scheduleModel.sort = "startDate ASC"
            break;
        case 2:
            scheduleModel.sort = "endDate ASC"
            break;
        case 3:
            scheduleModel.sort = "startDate DESC"
            break;
        case 4:
            scheduleModel.sort = "endDate DESC"
            break;
        default:
            scheduleModel.sort = "ref DESC"
        }
        scheduleModel.select();
        if ((tasksLoader.item !== null) && (typeof tasksLoader.item.order !== 'undefined'))
            tasksLoader.item.order = order;
    }

    function changeScheduleFilters() {
        var projectFilter = (project !== -1)?["ref='" + project + "'"]:[];
        scheduleModel.filters = stateFilter.concat(projectFilter,timeFilter);
        console.log('Changing filters ' + scheduleModel.filters);
        console.log('Selecting with filters');
        scheduleModel.select();
    }

    function changeTimeFilter() {
        timeFilter = [];
        if (firstDate !== null)
            timeFilter.push("startDate>='" + firstDate.toYYYYMMDDFormat() + "' OR ifnull(startDate,'')=''");

        if (lastDate !== null)
            timeFilter.push("endDate<='" + lastDate.toYYYYMMDDFormat() + "' OR ifnull(endDate,'')=''");

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

        Component.onCompleted: {
            append({method: 'showCalendar', image: 'calendar-23684', title: qsTr('Mostra el calendari')});
            append({method: 'showGantt', image: 'percent-40844', title: qsTr('Mostra el diagrama de Gantt')});
            append({method: 'showList', image: 'list-153185', title: qsTr('Mostra la llista de tasques i esdeveniments')});
        }
    }

    function createEvent() {
        newEvent({});
        emitSignal('ShowEvent',{projectsModel: projectsModel});
    }

    function showCalendar() {
        tasksLoader.setSource(Qt.resolvedUrl('Calendar.qml'), {searchString: scheduleModel.searchString, scheduleModel: scheduleModel});
    }

    function showGantt() {
        tasksLoader.setSource(Qt.resolvedUrl('GanttDiagram.qml'), {scheduleModel: scheduleModel, startDateLimit: firstDate, endDateLimit: lastDate});
    }

    function showList() {
        tasksLoader.setSource(Qt.resolvedUrl('Schedule.qml'), {searchString: scheduleModel.searchString, scheduleModel: scheduleModel})
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
                        MenuItem {
                            id: showNoStart
                            text: qsTr("Ignora data d'inici")
                            onTriggered: {
                                firstDate = null;
                                changeTimeFilter();
                            }
                        }
                        MenuItem {
                            id: showNoEnd
                            text: qsTr("Ignora data de final")
                            onTriggered: {
                                lastDate = null;
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
                onShowEvent: {
                    tasksSystem.showEvent(parameters);
                    tasksSystem.emitSignal('ShowEvent',parameters);
                }
            }

            Component.onCompleted: showList()
        }
    }
    Common.SuperposedButton {
        anchors {
            bottom: parent.bottom
            right: parent.right
        }
        size: units.fingerUnit * 2
        imageSource: 'plus-24844'
        onClicked: createEvent()
    }

    Models.ProjectsModel {
        id: projectsModel

//        filters: (tasksSystem.project !== -1)?["ref='" + tasksSystem.project + "'"]:[]
        Component.onCompleted: {
            select();
        }
    }

    Models.ScheduleModel {
        id: scheduleModel
        Component.onCompleted: select()
    }

    Connections {
        target: globalScheduleModel
        onUpdated: scheduleModel.select()
    }

    Component.onCompleted: {
        order = 1;
        searchEvents.text = scheduleModel.searchString;
        scheduleModel.searchFields = ['event','desc'];

        var date = new Date();
        firstDate = new Date(date.getFullYear(),date.getMonth(),date.getDate()-15);
        lastDate = new Date(date.getFullYear(),date.getMonth(),date.getDate()+15);
        changeTimeFilter();
    }
}

