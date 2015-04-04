import QtQuick 2.3
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import "qrc:///common/FormatDates.js" as FormatDates

Rectangle {
    id: calendarView

    Common.UseUnits { id: units }

    states: [
        State {
            name: 'CalendarOnly'
            AnchorChanges {
                target: view
                anchors.bottom: view.parent.bottom
            }
        },
        State {
            name: 'CalendarAndEvents'
            AnchorChanges {
                target: view
                anchors.bottom: view.parent.verticalCenter
            }
        }
    ]
    state: 'CalendarOnly'

    transitions: [
        Transition {
            AnchorAnimation {
                targets: view
                easing.type: Easing.InOutQuad
            }
        }


    ]

    property var startDate: new Date()
    property var shortMonthNames: ['gen', 'feb', 'març', 'abr', 'maig', 'jun', 'jul', 'ago', 'set', 'oct', 'nov', 'des']

    property string pageTitle: qsTr('Calendari')

    signal newEvent
    signal editEvent(int id,string event, string desc,string startDate,string startTime,string endDate,string endTime)

    function createEvent() {
        calendarView.newEvent();
    }

    function gotoToday() {
        view.currentIndex = 0;
    }

    function hideEventsList() {
        view.currentIndex = -1;
    }

    ListModel {
        id: daysModel
        Component.onCompleted: {
            var today = new Date();
            today.setDate(today.getDate()-today.getDay()+1);
            for (var i=0; i<7; i++) {
                daysModel.append({day: today.getDate(), month: today.getMonth(), year: today.getFullYear()});
                today.setDate(today.getDate() + 1);
            }
        }
    }

    GridView {
        id: view
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        model: daysModel
        cellHeight: Math.floor(width / 7)
        cellWidth: cellHeight
        clip: true

        currentIndex: -1

        property bool canPrependWeek: true

        highlightFollowsCurrentItem: true
        highlight: Rectangle {
            color: 'yellow'
        }
        highlightRangeMode: GridView.ApplyRange
        preferredHighlightBegin: 0
        preferredHighlightEnd: view.height

        onMovingVerticallyChanged: {
            if (movingVertically) {
                if ((contentY<0) && (canPrependWeek)) {
                    canPrependWeek = false;
                    var date = setDateFromModel(model.get(0));
                    for (var i=0; i<7; i++) {
                        date.setDate(date.getDate()-1);
                        daysModel.insert(0,{day: date.getDate(), month: date.getMonth(), year: date.getFullYear()});
                    }
                }
            } else {
                canPrependWeek = true;
            }
        }
        onAtYEndChanged: {
            if (atYEnd) {
                var date = setDateFromModel(model.get(model.count-1));
                for (var i=0; i<7; i++) {
                    date.setDate(date.getDate()+1);
                    daysModel.append({day: date.getDate(), month: date.getMonth(), year: date.getFullYear()});
                }
            }
        }

        onCurrentIndexChanged: {
            if (currentIndex > -1) {
                calendarView.state = 'CalendarAndEvents';
                var dateItem = daysModel.get(currentIndex);
                eventsArea.updateAllContents(dateItem.day, dateItem.month, dateItem.year);
            } else {
                calendarView.state = 'CalendarOnly';
            }
        }

        function setDateFromModel(dateItem) {
            var date = new Date();
            date.setDate(dateItem.day);
            date.setMonth(dateItem.month);
            date.setFullYear(dateItem.year);
            return date;
        }

        delegate: Rectangle {
            id: singleDay
            border.color: 'black'
            color: 'transparent'
            width: view.cellWidth
            height: view.cellHeight

            RowLayout {
                id: dateText
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: units.nailUnit / 2
                }
                height: parent.height / 2 - 2 * anchors.margins

                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: units.fingerUnit
                    horizontalAlignment: Text.AlignLeft
                    font.pixelSize: units.glanceUnit
                    fontSizeMode: Text.Fit
                    font.bold: true
                    text: model.day
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
                            text: shortMonthNames[model.month]
                        }
                        Text {
                            Layout.fillHeight: true
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            Layout.fillWidth: true
                            font.pixelSize: units.readUnit
                            fontSizeMode: Text.Fit
                            text: model.year
                        }
                    }
                }
            }
            Text {
                id: totalEvents
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    top: dateText.bottom
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAnywhere
                color: '#FFBF00'
            }

            SqlTableModel {
                id: eventsOfDayModel
                tableName: 'schedule'
                filters: []
                Component.onCompleted: {
                    setSort(1,Qt.DescendingOrder); // Order by last inclusion
                    var previousFilter = scheduleModel.filters;

                    var monthStr = model.month+1;
                    monthStr = ((monthStr<10)?'0':'') + monthStr;

                    var dayStr = ((day<10)?'0':'') + model.day;

                    var dateString = model.year + '-' + monthStr + '-' + dayStr;
                    var dateFilter = "startDate='" + dateString + "' OR endDate='" + dateString + "'";
                    eventsOfDayModel.filters = previousFilter;
                    eventsOfDayModel.filters.push(dateFilter);
                    eventsOfDayModel.select();
                    // scheduleModel.filters = previousFilter;

                    var c = eventsOfDayModel.count;
                    if (c>0) {
                        var res = "";
                        for (var i=0; i<c; i++) {
                            res += " *";
                        }
                        totalEvents.text = res;
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    view.currentIndex = model.index;
                }
            }
        }

    }

    Rectangle {
        id: eventsArea
        property int day
        property int month
        property int year

        color: 'white'
        anchors {
            left: parent.left
            right: parent.right
            top: view.bottom
            bottom: parent.bottom
            margins: units.nailUnit
        }

        ColumnLayout {
            anchors.fill: parent
            clip: true

            Text {
                id: eventsAreaTitle
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                font.pixelSize: units.readUnit
                font.bold: true
                text: {
                    var date = new Date();
                    date.setDate(eventsArea.day);
                    date.setMonth(eventsArea.month);
                    date.setFullYear(eventsArea.year);
                    return qsTr('Esdeveniments de ') + date.toLongDate();
                }
            }

            ListView {
                id: eventsList
                Layout.fillWidth: true
                Layout.fillHeight: true

                model: events
                clip: true
                boundsBehavior: ListView.StopAtBounds


                delegate: Rectangle {
                    width: eventsList.width
                    height: units.fingerUnit
                    border.color: 'black'

                    RowLayout {
                        anchors.fill: parent
                        Text {
                            id: textFrom
                            property real calculatedWidth: 0
                            Layout.fillHeight: true
                            Layout.preferredWidth: calculatedWidth
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            id: eventText
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 2
                            text: (model.event + ' ' + model.desc).replace("\n", " ").replace("\r", " ")
                            color: (model.state == 'done')?'gray':'black'
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: units.readUnit
                        }

                        Text {
                            id: textUntil
                            property real calculatedWidth: 0
                            Layout.fillHeight: true
                            Layout.preferredWidth: calculatedWidth
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Component.onCompleted: {
                            if (eventsArea.convertToDateString(eventsArea.day,eventsArea.month,eventsArea.year) == model.startDate) {
                                textUntil.calculatedWidth = textUntil.parent.width / 2;
                                textUntil.text = qsTr("Fins a ") + model.endDate
                            } else {
                                textFrom.calculatedWidth = textFrom.parent.width / 2;
                                textFrom.text = qsTr("Des de ") + model.startDate
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        propagateComposedEvents: true
                        onClicked: {
                            calendarView.editEvent(model.id,model.event,model.desc,model.startDate,model.startTime,model.endDate,model.endTime);
                            console.log("Model.id: " + model.id);
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
                            var month = eventsArea.month+1;
                            month = ((month<10)?'0':'') + month;
                            var day = eventsArea.day;
                            day = ((day<10)?'0':'') + day;
                            var dateString = eventsArea.year + '-' + month + '-' + day;

                            calendarView.editEvent(-1,'','',dateString,'',dateString,'');
                        }
                    }
                }

                SqlTableModel {
                    id: events
                    tableName: 'schedule'
                    filters: []
                    Component.onCompleted: {
                        setSort(1,Qt.DescendingOrder); // Order by last inclusion
                    }
                }

            }

        }

        function convertToDateString(day, month, year) {
            var monthStr = month+1;
            monthStr = ((monthStr<10)?'0':'') + monthStr;

            var dayStr = ((day<10)?'0':'') + day;

            return year + '-' + monthStr + '-' + dayStr;
        }

        function updateAllContents(day,month,year) {
            eventsArea.day = day;
            eventsArea.month = month;
            eventsArea.year = year;

            // Events
            var previousFilter = scheduleModel.filters;

            var dateString = convertToDateString(day,month,year);
            var dateFilter = "startDate='" + dateString + "' OR endDate='" + dateString + "'";
            events.filters = previousFilter;
            events.filters.push(dateFilter);
            events.select();
            // scheduleModel.filters = previousFilter;
        }

    }


}

