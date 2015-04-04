import QtQuick 2.3
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import "qrc:///common/FormatDates.js" as FormatDates

Rectangle {
    id: gantDiagram

    Common.UseUnits { id: units }

    property string pageTitle: qsTr('Projectes')

    signal editEvent(int idEvent,string event, string desc,string startDate,string startTime,string endDate,string endTime)
    signal newProjectRequest(var model)

    property string documents: ''
    property int sectionsHeight: units.fingerUnit * 3
    property int sectionsWidth: units.fingerUnit * 5

    property alias buttons: buttonsModel

    ListModel {
        id: buttonsModel

        ListElement {
            method: 'newProject'
            image: 'plus-24844'
        }
    }

    SqlTableModel {
        id: projectsModel

        tableName: 'projects'
        fieldNames: ['id','name','desc']
    }

    ListView {
        id: projectsList
        z: 2
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }
        width: sectionsWidth
        clip: true

        model: projectsModel

        delegate: Rectangle {
            id: eventTitle
            width: projectsList.width
            height: sectionsHeight
            border.color: 'grey'
            clip: true
            Text {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                font.pixelSize: units.readUnit
                text: model.name
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight
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
            left: projectsList.right
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
            width: Math.max(spaceAtSides * 2 + daysWidth * daysDifference  + 2 * units.nailUnit, gantDiagram.width - projectsList.width)

            onWidthChanged: flickable.contentWidth = gantList.width
            onContentYChanged: {
                if (movingVertically) {
                    projectsList.contentY = contentY;
                }
            }
            clip: true

            property string startLimit: ''
            property string endLimit: ''

            property var startDateLimit: new Date()
            property var endDateLimit: new Date()

            property int daysDifference: 0
            property real daysWidth: units.fingerUnit
            property real spaceAtSides: units.fingerUnit * 5

            model: projectsModel

            delegate: Rectangle {
                id: singleItem
                border.color: 'grey'
                width: gantList.width
                height: units.fingerUnit
                property string startDate: ''
                property string endDate: ''

                Rectangle {
                    id: barItem
                    color: 'red'
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        margins: units.nailUnit
                    }
                }
                Text {
                    id: leftText
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: barItem.left
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    text: singleItem.startDate
                }
                Text {
                    id: rightText
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: barItem.right
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    text: singleItem.endDate
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log('Edit event ' + model.id);
                        editEvent(model.id,model.event,model.desc,model.startDate,model.startTime,model.endDate,model.endTime)
                    }
                }

                Connections {
                    target: gantList
                    onDaysDifferenceChanged: singleItem.recalculateRectangle()
                    onWidthChanged: singleItem.recalculateRectangle()
                }

                function recalculateRectangle() {
                    var start = new Date();
                    start.fromYYYYMMDDFormat(singleItem.startDate);
                    var days = gantList.startDateLimit.differenceInDays(start);
                    barItem.x = days * gantList.daysWidth + gantList.spaceAtSides + units.nailUnit; // barItem.parent.width / gantList.daysDifference;

                    var end = new Date();
                    end.fromYYYYMMDDFormat(singleItem.endDate);
                    days = start.differenceInDays(end) + 1;
                    barItem.width = days * gantList.daysWidth; // barItem.parent.width / gantList.daysDifference;
                }

                onStartDateChanged: gantList.updateStartLimit(startDate)
                onEndDateChanged: gantList.updateEndLimit(endDate)

                Component.onCompleted: recalculateRectangle()
            }

            function updateStartLimit(date) {
                if (date !== '') {
                    if ((startLimit == '') || (startLimit > date)) {
                        startLimit = date;
                        startDateLimit.fromYYYYMMDDFormat(startLimit);
                        recalculateDifference();
                    }
                }
            }

            function updateEndLimit(date) {
                if (date !== '') {
                    if ((endLimit == '') || (endLimit < date)) {
                        endLimit = date;
                        endDateLimit.fromYYYYMMDDFormat(endLimit);
                        recalculateDifference();
                    }
                }
            }

            function recalculateDifference() {
                daysDifference = startDateLimit.differenceInDays(endDateLimit) + 1;
            }

            onDaysDifferenceChanged: console.log('Days difference: ' + daysDifference + " from " + startLimit + " till " + endLimit)

            function initializeList() {
                startDateLimit = new Date();
                endDateLimit = new Date();
                startLimit = '';
                endLimit = '';
                daysDifference = 0;
            }

            Component.onCompleted: initializeList()
        }
    }

    function newProject() {
        newProjectRequest(projectsModel);
    }

    Component.onCompleted: {
        projectsModel.select();
        console.log(projectsModel.count)
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
