import QtQuick 2.3
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import "qrc:///common/FormatDates.js" as FormatDates

Rectangle {
    id: gantDiagram

    Common.UseUnits { id: units }

    property string pageTitle: qsTr('Diagrama de Gantt')
    signal showEvent(int idEvent,string event, string desc,string startDate,string startTime,string endDate,string endTime,int project)

    property string searchString: ''
    property SqlTableModel projectsModel
    property int rowsHeight: units.fingerUnit * 2

    property var startDateLimit: new Date()
    property var endDateLimit: new Date()

    onSearchStringChanged: gantList.initializeList()

    ListView {
        id: eventList
        z: 2
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }
        width: parent.width / 3
        clip: true

        model: scheduleModel
        section.property: 'ref'
        section.delegate: Rectangle {
            border.color: 'black'
            color: '#aaffaa'
            width: eventList.width
            height: rowsHeight

            property var refNumber: section

            Text {
                id: sectionText
                anchors.fill: parent
                anchors.margins: units.nailUnit
                font.pixelSize: units.readUnit
                text: {
                    var num = parseInt(refNumber);
                    if ((section == '') || (num<0)) {
                        return qsTr('-- Sense secció --');
                    } else {
                        var obj = projectsModel.getObject(refNumber);
                        return obj['name'];
                    }
                }

                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        delegate: Rectangle {
            id: eventTitle
            width: eventList.width
            height: rowsHeight
            border.color: 'grey'
            Text {
                anchors {
                    fill: parent
                    margins: units.nailUnit
                }
                font.pixelSize: units.readUnit
                color: (model.state === 'done')?'gray':'black'
                text: model.event
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
        }

        onContentYChanged: {
            if (movingVertically) {
                gantList.contentY = contentY;
            }
        }
    }

    Flickable {
        id: flickable
        flickableDirection: Flickable.HorizontalFlick
        anchors {
            top: parent.top
            left: eventList.right
            right: parent.right
            bottom: parent.bottom
        }
        z: 1
        clip: true

        contentHeight: height
        contentWidth: gantList.width

        ListView {
            id: gantList
            height: flickable.contentHeight
            width: Math.max(daysWidth * daysDifference  + 2 * units.nailUnit, gantDiagram.width - eventList.width)

            onWidthChanged: flickable.contentWidth = gantList.width
            onContentYChanged: {
                if (movingVertically) {
                    eventList.contentY = contentY;
                }
            }
            clip: true

//            property string startLimit: ''
//            property string endLimit: ''

            property int daysDifference: 0
            property real daysWidth: units.fingerUnit * 4

            property int todayOffset: 0

            model: scheduleModel
            section.property: 'ref'
            section.delegate: Item {
                width: gantList.width
                height: rowsHeight
                ListView {
                    anchors {
                        fill: parent
                        leftMargin: units.nailUnit
                        rightMargin: units.nailUnit
                    }
                    orientation: ListView.Horizontal
                    interactive: false
                    model: gantList.daysDifference
                    delegate: Rectangle {
                        width: gantList.daysWidth
                        height: rowsHeight
                        border.color: 'black'
                        Text {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.pixelSize: units.readUnit
                            fontSizeMode: Text.Fit
                            text: {
                                var date = new Date(startDateLimit.getFullYear(),startDateLimit.getMonth(),startDateLimit.getDate());
                                date.setDate(date.getDate()+modelData);
                                return date.toShortReadableDate();
                            }
                        }
                    }
                }
            }
            delegate: Rectangle {
                id: singleItem
                border.color: 'grey'
                width: gantList.width
                height: rowsHeight
                property string startDate: model.startDate
                property string endDate: model.endDate
                property string desc: model.desc

                ListView {
                    anchors {
                        fill: parent
                        leftMargin: units.nailUnit
                        rightMargin: units.nailUnit
                    }
                    orientation: ListView.Horizontal
                    interactive: false
                    model: gantList.daysDifference
                    delegate: Item {
                        width: gantList.daysWidth
                        height: rowsHeight
                        // border.color: 'black'
                        Text {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            color: 'gray'
                            font.pixelSize: units.readUnit
                            fontSizeMode: Text.Fit
                            text: {
                                if ((singleItem.startDate === '') && (singleItem.endDate === '')) {
                                    var date = new Date(startDateLimit.getFullYear(),startDateLimit.getMonth(),startDateLimit.getDate() + modelData);
                                    return date.toShortReadableDate();
                                } else {
                                    if (singleItem.startDate !== '') {
                                        var date = new Date();
                                        date.fromYYYYMMDDFormat(singleItem.startDate);
                                        var days = -date.differenceInDays(startDateLimit) - 1 - modelData;
                                        if (days>0)
                                            return (days) + qsTr(' dies abans');
                                    }
                                    if (singleItem.endDate !== '') {
                                        var date = new Date();
                                        date.fromYYYYMMDDFormat(singleItem.endDate);
                                        var days = date.differenceInDays(startDateLimit) + 1 + modelData;
                                        if (days>0)
                                            return days + qsTr(' dies després');
                                    }
                                }
                                return '';
                            }
                        }
                    }
                }

                Rectangle {
                    id: barItem
                    color: (model.state !== 'done')?'red':'grey'
                    clip: true
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        topMargin: units.nailUnit
                        bottomMargin: units.nailUnit
                    }
                    Text {
                        anchors {
                            fill: parent
                            margins: units.nailUnit
                        }
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        text: (model.desc !== '')?model.desc:model.event
                    }
                }
                Rectangle {
                    id: nowItem
                    color: 'yellow'
                    opacity: 0.5
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        margins: 0
                    }
                    x: gantList.todayOffset
                    width: gantList.daysWidth
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var ref = parseInt(model.ref);
                        if (typeof ref !== 'int') {
                            ref = -1;
                        }

                        showEvent(model.id,model.event,model.desc,model.startDate,model.startTime,model.endDate,model.endTime,ref)
                    }
                }

                Connections {
                    target: gantList
                    onDaysDifferenceChanged: singleItem.recalculateRectangle()
                    onWidthChanged: singleItem.recalculateRectangle()
                }

                function recalculateRectangle() {
                    var start = new Date();
                    if (singleItem.startDate === '') {
                        barItem.x = units.nailUnit;

                        if (singleItem.endDate === '') {
                            barItem.width = 0;
                        } else {
                            var end = new Date();
                            end.fromYYYYMMDDFormat(singleItem.endDate);
                            var days = startDateLimit.differenceInDays(end) + 1;
                            console.log('DAYSSSSSS ' + days);
                            barItem.width = days * gantList.daysWidth; // barItem.parent.width / gantList.daysDifference;
                        }
                    } else {
                        start.fromYYYYMMDDFormat(singleItem.startDate);
                        var days = startDateLimit.differenceInDays(start);

                        barItem.x = days * gantList.daysWidth + units.nailUnit; // barItem.parent.width / gantList.daysDifference;

                        if (singleItem.endDate === '') {
                            barItem.width = (gantList.daysDifference - days) * gantList.daysWidth;
                        } else {
                            var end = new Date();
                            end.fromYYYYMMDDFormat(singleItem.endDate);
                            days = start.differenceInDays(end) + 1;
                            barItem.width = days * gantList.daysWidth; // barItem.parent.width / gantList.daysDifference;
                        }
                    }

                    // Show today mark
                    var today = new Date();
                    gantList.todayOffset = startDateLimit.differenceInDays(today) * gantList.daysWidth + units.nailUnit;
                }

                onStartDateChanged: gantList.recalculateDifference()
                onEndDateChanged: gantList.recalculateDifference()

                Component.onCompleted: {
                    gantList.recalculateDifference();
                    recalculateRectangle();
                }
            }

            function recalculateDifference() {
                daysDifference = startDateLimit.differenceInDays(endDateLimit) + 1;
            }
        }
    }


    Component.onCompleted: {
/*
        scheduleModel.setSort(4,Qt.AscendingOrder);
        scheduleModel.select();
        scheduleModel.setSort(9,Qt.AscendingOrder);
        scheduleModel.filters = ["ifnull(state,'') != 'done'"];
        scheduleModel.searchFields = ['event','desc'];
        scheduleModel.select();
        */
    }

    /*
    SqlTableModel {
        id: events
        tableName: 'schedule'
        filters: []
        Component.onCompleted: {
            setSort(4,Qt.DescendingOrder); // Order by startDate
        }
    }
    */
}
