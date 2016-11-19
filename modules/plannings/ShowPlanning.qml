import QtQuick 2.7
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///modules/basic' as Basic
import "qrc:///common/FormatDates.js" as FormatDates

Rectangle {
    id: showPlanningItem

    property string planning: ''

    property var fieldsArray: []

    signal sessionSelected(int session)
    signal updated(var object)

    color: 'gray'

    Common.UseUnits {
        id: units
    }

    Models.PlanningsModel {
        id: planningsModel

        filters: ['title=?']

        function getFieldsArray() {
            bindValues = [planning];
            select();
            if (count>0) {
                console.log('planning inside');
                var fieldsString = getObjectInRow(0)['fields'];
                fieldsArray = fieldsString.split(',');
                console.log(fieldsArray);
            }
        }
    }

    Models.PlanningSessionsModel {
        id: sessionsModel

        filters: ['planning=?']

        sort: 'start ASC, end ASC, number ASC'

        function refresh() {
            bindValues = [planning];
            select();

            orphanActionsModel.getOrphanActions();
        }
    }

    Models.PlanningActionsModel {
        id: orphanActionsModel

        function getOrphanActions() {
            var newFilters = [];
            var newBindValues = [];

            for (var i=0; i<fieldsArray.length; i++) {
                newFilters.push('field != ?');
                newBindValues.push(fieldsArray[i]);
            }

            filters = newFilters;
            bindValues = newBindValues;
            select();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight

            font.pixelSize: units.readUnit
            text: planning
        }
        ListView {
            id: sessionsList

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            model: sessionsModel
            spacing: units.nailUnit

            delegate: Rectangle {
                id: singleSessionRect

                width: sessionsList.width
                height: Math.max(sessionNumberText.height, sessionBasicInfoLayout.requiredHeight, actionsRect.requiredHeight)

                property int sessionId: model.id

                MouseArea {
                    anchors.fill: parent
                    onClicked: sessionSelected(singleSessionRect.sessionId)
                }

                Text {
                    id: sessionNumberText

                    anchors {
                        top: parent.top
                        left: parent.left
                        margins: units.nailUnit
                    }

                    height: contentHeight
                    width: contentWidth

                    verticalAlignment: Text.AlignTop
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: model.number
                }

                Flow {
                    id: sessionBasicInfoLayout

                    anchors {
                        top: parent.top
                        left: sessionNumberText.right
                        bottom: parent.bottom
                        margins: units.nailUnit
                    }
                    width: Math.max(Math.floor(parent.width / (fieldsArray.length+1)), units.fingerUnit * 4)
                    spacing: units.nailUnit
                    property int requiredHeight: childrenRect.height + 2 * units.nailUnit

                    Text {
                        height: contentHeight
                        width: parent.width

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.title
                    }
                    Text {
                        height: contentHeight
                        width: parent.width

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.desc
                    }
                    Text {
                        height: contentHeight
                        width: parent.width

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                        text: {
                            var startStr = '';
                            var date1 = new Date();
                            var returnString = '';
                            if (model.start !== '') {
                                var startObj = date1.fromYYYYMMDDHHMMFormat(model.start);
                            }
                            var endStr = '';
                            var date2 = new Date();
                            if (model.end !== '') {
                                var endObj = date2.fromYYYYMMDDHHMMFormat(model.end);
                            }
                            if ((date1.definedDate) && (date2.definedDate)) {
                                // Start and end have been defined
                                if ((date1.differenceInDays(date2) == 0)) {
                                    // Start and end have the same date

                                    returnString = date1.toShortReadableDate();

                                    if ((date1.definedTime) || (date2.definedTime)) {
                                        // Start time OR end time have not been defined

                                        if ((date1.definedTime) && (date2.definedTime) && (date1.differenceInMinutes(date2) == 0)) {
                                            // Start time AND end time have been defined
                                            // Start and end have the same time in hours and minutes
                                            returnString += "\n" + qsTr("A les ") + date1.toHHMMFormat();
                                        } else {
                                            returnString += "\n[ " + (date1.definedTime?date1.toHHMMFormat():'-') + " , ";
                                            returnString += (date2.definedTime?date2.toHHMMFormat():'-') + ' ]';
                                        }
                                    }
                                } else {
                                    // Start and end have been defined with different dates
                                    returnString = qsTr('Comença ') + date1.toShortReadableDate();
                                    if (date1.definedTime)
                                        returnString += " " + date1.toHHMMFormat();
                                    returnString += "\n" + qsTr('Acaba ') + date2.toShortReadableDate();
                                    if (date2.definedTime)
                                        returnString += " " + date2.toHHMMFormat();
                                }
                            } else {
                                // Only start date or end date have been specified
                                if (date1.definedDate) {
                                    returnString = qsTr('Comença ') + date1.toShortReadableDate();
                                    if (date1.definedTime)
                                        returnString += " " + date1.toHHMMFormat();
                                }
                                if (date2.definedDate) {
                                    returnString = qsTr('Acaba ') + date2.toShortReadableDate();
                                    if (date2.definedTime)
                                        returnString += " " + date2.toHHMMFormat();
                                }
                            }
                            return returnString;
                        }
                    }
                }

                Rectangle {
                    id: actionsRect

                    anchors {
                        top: parent.top
                        left: sessionBasicInfoLayout.right
                        right: parent.right
                        bottom: parent.bottom
                    }
                    property int requiredHeight: childrenRect.height + units.nailUnit
                    color: '#E6E6E6'

                    RowLayout {
                        id: actionsLayout
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: units.nailUnit
                        }
                        spacing: units.nailUnit
                        height: childrenRect.height

                        Repeater {
                            model: fieldsArray

                            Item {
                                id: singleFieldColumn

                                Layout.preferredWidth: Math.round((actionsLayout.width - (fieldsArray.length-1) * actionsLayout.spacing) / fieldsArray.length)
                                Layout.preferredHeight: childrenRect.height
                                Layout.alignment: Qt.AlignTop

                                property string field: modelData

                                Column {
                                    anchors {
                                        top: parent.top
                                        left: parent.left
                                        right: parent.right
                                    }
                                    spacing: units.nailUnit
                                    height: childrenRect.height

                                    Text {
                                        width: parent.width
                                        height: contentHeight

                                        font.pixelSize: units.readUnit
                                        font.bold: true
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                        text: singleFieldColumn.field
                                    }

                                    Repeater {
                                        model: Models.PlanningActionsModel {
                                            id: actionsModel

                                            filters: ['session=?', 'field=?']
                                            sort: 'number ASC'

                                            function getActions() {
                                                bindValues = [singleSessionRect.sessionId, singleFieldColumn.field];
                                                select();
                                            }

                                            Component.onCompleted: actionsModel.getActions()
                                        }

                                        Connections {
                                            target: showPlanningItem

                                            onUpdated: actionsModel.getActions()
                                        }

                                        ActionStateRectangle {
                                            width: parent.width
                                            height: childrenRect.height + units.nailUnit

                                            stateValue: model.state
                                            Text {
                                                anchors {
                                                    top: parent.top
                                                    left: parent.left
                                                    right: parent.right
                                                    margins: units.nailUnit
                                                }
                                                height: contentHeight + units.nailUnit

                                                font.pixelSize: units.readUnit
                                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                                textFormat: Text.RichText
                                                text: model.contents + ((model.pending !== '')?" <font color=\"red\">" + model.pending + "</font>":'')
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            footer: (orphanActionsModel.count>0)?orphanActionsComponent:null

            Component {
                id: orphanActionsComponent

                Item {
                    width: sessionsList.width
                    height: units.fingerUnit * 3

                    ListView {
                        id: orphanActionsList

                        anchors.fill: parent
                        anchors.topMargin: units.fingerUnit

                        model: orphanActionsModel
                        orientation: ListView.Horizontal
                        spacing: units.nailUnit

                        header: Text {
                            height: orphanActionsList.height
                            width: contentWidth

                            font.pixelSize: units.readUnit
                            font.bold: true
                            text: qsTr('Accions orfes')
                        }

                        delegate: Rectangle {
                            width: units.fingerUnit * 4
                            height: orphanActionsList.height

                            Text {
                                anchors.fill: parent
                                anchors.margins: units.nailUnit

                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                text: model.field + " " + model.contents
                            }
                        }
                    }
                }
            }

            Common.ImageButton {
                id: addSessionButton

                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }
                size: units.fingerUnit * 1.5
                padding: units.fingerUnit
                image: 'plus-24844'

                onClicked: {
                    var number = sessionsModel.count+1;
                    sessionsModel.insertObject({planning: planning, number: number, title: qsTr('Sessió ') + number});
                    sessionsModel.refresh();
                    showPlanningItem.updated({});
                }
            }

            Common.ImageButton {
                anchors {
                    bottom: parent.bottom
                    right: addSessionButton.left
                    rightMargin: units.fingerUnit
                }
                size: units.fingerUnit * 1.5
                padding: units.fingerUnit
                image: 'box-24557'

                onClicked: exportSessions()
            }
        }
    }

    function receiveUpdated(object) {
        sessionsModel.refresh();
        showPlanningItem.updated(object);
    }

    Models.PlanningItems {
        id: planningItemsModel

    }

    Models.PlanningActionsModel {
        id: importActionsModel

        filters: ['session=?', 'field=?']
        sort: 'number ASC'
    }

    Models.PlanningItemsActionsModel {
        id: exportActionsModel
    }

    function exportSessions() {
        console.log('Exporting data...');
        console.log('* Each «field» will become a «list»');
        console.log('* Each «session» will become an «item» en each «list»');
        console.log('* Each «action» of each «session» will become an «itemAction» of some «item»');

        for (var i=0; i<fieldsArray.length; i++) {
            var field = fieldsArray[i];
            console.log('Field', field, 'will become a list.');
            sessionsModel.bindValues = [planning];
            sessionsModel.select();

            for (var j=0; j<sessionsModel.count; j++) {
                var sessionObj = sessionsModel.getObjectInRow(j);
                var newPlanningItem = {
                    planning: planning,
                    list: field,
                    title: sessionObj['title'],
                    desc: sessionObj['desc'] + '\n' + sessionObj['start'] + '\n' + sessionObj['end'],
                    number: sessionObj['number']
                };

                var start = sessionObj['start'];
                var end = sessionObj['end'];
                var sessionId = sessionObj['id'];

                var itemId = planningItemsModel.insertObject(newPlanningItem);
                console.log('Session «', sessionId, '» with title «', sessionObj['title'], '» becomes new list «', field, '» with new item id «', itemId, '» with the same title.');

                importActionsModel.bindValues = [sessionId, field];
                importActionsModel.select();

                console.log('Transforming actions of session into itemActions')
                for (var k=0; k<importActionsModel.count; k++) {
                    var actionObj = importActionsModel.getObjectInRow(k);

                    console.log('Action', JSON.stringify(actionObj));
                    var newItemActionObj = {
                        item: itemId,
                        context: qsTr('Context únic'),
                        number: actionObj['number'],
                        contents: actionObj['contents'],
                        state: actionObj['state'],
                        result: actionObj['pending'],
                        start: start,
                        end: end
                    };
                    console.log('becomes', JSON.stringify(newItemActionObj));
                    exportActionsModel.insertObject(newItemActionObj);
                }
            }
        }

        console.log('Export finished!');
    }

    Component.onCompleted: {
        planningsModel.getFieldsArray();
        sessionsModel.refresh();
    }

}
