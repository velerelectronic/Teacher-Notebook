import QtQuick 2.3
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import "qrc:///common/FormatDates.js" as FormatDates

Rectangle {
    id: calendarView

    Common.UseUnits { id: units }

    property var startDate: new Date()
    property var shortMonthNames: ['gen', 'feb', 'març', 'abr', 'maig', 'jun', 'jul', 'ago', 'set', 'oct', 'nov', 'des']

    property string pageTitle: qsTr('Calendari')

    signal newEvent
    signal emitSignal(string name, var param)
    signal editEvent(int id,string event, string desc,string startDate,string startTime,string endDate,string endTime)

    property var buttons: buttonsModel

    function createEvent() {
        calendarView.newEvent();
        emitSignal('createEvent',{});
    }

    function gotoToday() {
        view.weeksOffset = 0;
        view.currentIndex = 0;
    }

    ListModel {
        id: buttonsModel
        ListElement {
            method: 'createEvent'
            image: 'plus-24844'
        }
        ListElement {
            method: 'gotoToday'
            image: 'calendar-27560'
        }
    }


    ListModel {
        id: weeksModel
        Component.onCompleted: {
            weeksModel.append({week: 0});
            weeksModel.append({week: 1});
            weeksModel.append({week: 2});
            weeksModel.append({week: 3});
            weeksModel.append({week: 4});
            weeksModel.append({week: 5});
        }
    }

    property int weeksHeight: height / weeksModel.count

    PathView {
        id: view
        anchors.fill: parent
        model: weeksModel
        clip: true

        delegate: Row {
            id: singleWeek
            width: parent.width
            height: weeksHeight
            property var weekNumber: model.week

            Rectangle {
                id: leftHandle
                color: 'gray'
                height: parent.height
                width: 0 // units.fingerUnit
            }

            Repeater {
                model: 7
                delegate: Rectangle {
                    id: singleDay
                    property int day: 0
                    property int month: 0
                    property int year: 0
                    border.color: 'black'
                    width: (calendarView.width - leftHandle.width - rightHandle.width) / 7
                    height: parent.height

                    RowLayout {
                        id: dateText
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: units.nailUnit / 2
                        }
                        height: parent.height / 3 - 2 * anchors.margins

                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: units.fingerUnit
                            horizontalAlignment: Text.AlignLeft
                            font.pixelSize: units.readUnit
                            fontSizeMode: Text.Fit
                            font.bold: true
                            text: day
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 0
                                Text {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignRight
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: units.readUnit
                                    fontSizeMode: Text.Fit
                                    font.capitalization: Font.SmallCaps
                                    text: shortMonthNames[month]
                                }
                                Text {
                                    Layout.fillHeight: true
                                    horizontalAlignment: Text.AlignRight
                                    verticalAlignment: Text.AlignVCenter
                                    Layout.fillWidth: true
                                    font.pixelSize: units.readUnit
                                    fontSizeMode: Text.Fit
                                    text: year
                                }
                            }
                        }
                    }

                    Connections {
                        target: view
                        onWeeksOffsetChanged: {
                            if ((view.currentIndex == singleWeek.weekNumber) || ((view.currentIndex-1 + weeksModel.count) % weeksModel.count == singleWeek.weekNumber)) {
                                singleDay.updateAllContents();
                            }
                        }
                    }

                    ListView {
                        id: eventsList
                        anchors {
                            top: dateText.bottom
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                            margins: units.nailUnit / 2
                        }

                        model: eventsOfDayModel
                        clip: true
                        boundsBehavior: ListView.StopAtBounds

                        delegate: Rectangle {
                            width: eventsList.width
                            height: Math.max(units.fingerUnit, eventText.contentHeight + eventText.anchors.margins * 2)
                            border.color: 'black'
                            color: (model.state == 'done')?'#99FF99':'#F5D0A9'

                            Text {
                                id: eventText
                                anchors.fill: parent
                                anchors.margins: units.nailUnit / 2
                                text: model.event
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.smallReadUnit
                            }
                            MouseArea {
                                anchors.fill: parent
                                propagateComposedEvents: true
                                onClicked: {
                                    calendarView.editEvent(model.id,model.event,model.desc,model.startDate,model.startTime,model.endDate,model.endTime);
                                    calendarView.emitSignal('editEvent',{id: model.id,event: model.event,desc: model.desc,startDate: model.startDate,startTime: model.startTime,endDate: model.endDate,endTime: model.endTime});
                                }
                            }
                        }
                        footer: Item {
                            width: eventsList.width
                            height: units.fingerUnit
                            Text {
                                anchors.centerIn: parent
                                font.pixelSize: units.readUnit
                                color: 'gray'
                                text: qsTr('Afegeix...')
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var month = singleDay.month+1;
                                    month = ((month<10)?'0':'') + month;
                                    var day = singleDay.day;
                                    day = ((day<10)?'0':'') + day;
                                    var dateString = singleDay.year + '-' + month + '-' + day;

                                    calendarView.editEvent(-1,'','',dateString,'',dateString,'');
                                    calendarView.emitSignal('editEvent',{id: -1, startDate: dateString,endDate: dateString});
                                }
                            }
                        }

                        SqlTableModel {
                            id: eventsOfDayModel
                            tableName: 'schedule'
                            filters: []
                            Component.onCompleted: {
                                setSort(1,Qt.DescendingOrder); // Order by last inclusion
                            }
                        }
                    }


                    function updateAllContents() {
                        // Date
                        var thisDate = new Date();
                        thisDate.setDate(thisDate.getDate() - thisDate.getDay() + 1 + (view.weeksOffset + singleWeek.weekNumber - view.currentIndex + ((view.currentIndex<=singleWeek.weekNumber)?0:weeksModel.count)) * 7 + modelData);
                        singleDay.day = thisDate.getDate();
                        singleDay.month = thisDate.getMonth();
                        singleDay.year = thisDate.getFullYear();
                        // textDay.text = thisDate.toShortReadableDate();

                        // Events
                        var previousFilter = scheduleModel.filters;

                        var month = singleDay.month+1;
                        month = ((month<10)?'0':'') + month;
                        var day = singleDay.day;
                        day = ((day<10)?'0':'') + day;

                        var dateString = singleDay.year + '-' + month + '-' + day;
                        var dateFilter = "startDate='" + dateString + "' OR endDate='" + dateString + "'";
                        eventsOfDayModel.filters = previousFilter;
                        eventsOfDayModel.filters.push(dateFilter);
                        eventsOfDayModel.select();
                        // scheduleModel.filters = previousFilter;
                    }

                    Component.onCompleted: singleDay.updateAllContents()
                }
            }
            Rectangle {
                id: rightHandle
                color: 'gray'
                height: parent.height
                width: units.fingerUnit
            }
        }
        path: Path {
            startX: parent.width / 2
            startY: weeksHeight / 2
            PathLine {
                relativeX: 0
                relativeY: calendarView.height
            }
        }
        property int lastIndex: 0
        property int weeksOffset: 0

        onCurrentIndexChanged: {
            switch(currentIndex) {
            case lastIndex+1:
            case lastIndex-weeksModel.count+1:
                weeksOffset += 1;
                break;
            case lastIndex-1:
            case lastIndex+weeksModel.count-1:
                weeksOffset -= 1;
                break;
            default:
                console.log('Error?');
            }
            lastIndex = currentIndex;
        }
    }
}

