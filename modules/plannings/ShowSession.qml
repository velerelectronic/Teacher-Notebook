import QtQuick 2.7
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///modules/basic' as Basic
import 'qrc:///modules/annotations2' as Annotations
import "qrc:///common/FormatDates.js" as FormatDates

Item {
    id: showSessionItem

    property int session

    property string sessionPlanning
    property int sessionNumber
    property string sessionTitle
    property string sessionDesc
    property string sessionStart
    property string sessionEnd

    property var fieldsArray: []

    signal updateChanges()
    signal updated(var object)

    Common.UseUnits {
        id: units
    }

    Models.PlanningSessionsModel {
        id: sessionsModel

        function getSessionInfo() {
            var object = getObject(session);

            sessionPlanning = object['planning'];
            sessionNumber = object['number'];
            sessionTitle = object['title'];
            sessionDesc = object['desc'];
            sessionStart = object['start'];
            sessionEnd = object['end'];

            planningsModel.getFieldsArray();
        }

        Component.onCompleted: getSessionInfo()
    }

    Models.PlanningsModel {
        id: planningsModel

        filters: ['title=?']

        function getFieldsArray() {
            bindValues = [sessionPlanning];
            select();
            if (count>0) {
                console.log('planning inside');
                var fieldsString = getObjectInRow(0)['fields'];
                fieldsArray = fieldsString.split(',');
                console.log(fieldsArray);
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: units.nailUnit

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(units.fingerUnit, childrenRect.height)

            GridLayout {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                height: childrenRect.height

                rows: 4
                columns: 2

                Text {
                    Layout.preferredWidth: parent.width / 3
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Planificació')
                }
                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    font.pixelSize: units.readUnit
                    text: sessionPlanning
                }

                Text {
                    Layout.preferredWidth: parent.width / 3
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Número')
                }
                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    font.pixelSize: units.readUnit
                    text: sessionNumber
                }
                Text {
                    Layout.preferredWidth: parent.width / 3
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Títol')
                }
                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    font.pixelSize: units.readUnit
                    text: sessionTitle
                }
                Text {
                    Layout.preferredWidth: parent.width / 3
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Descripció')
                }
                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    font.pixelSize: units.readUnit
                    text: sessionDesc
                }
                Text {
                    Layout.preferredWidth: parent.width / 3
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Període')
                    MouseArea {
                        anchors.fill: parent
                        onClicked: periodEditorDialog.openPeriodEditor()
                    }
                }
                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    font.pixelSize: units.readUnit
                    text: {
                        var start = new Date();
                        var startString = (sessionStart !== '')?start.fromYYYYMMDDHHMMFormat(sessionStart).toLongDate():qsTr('No definit');

                        var end = new Date();
                        var endString = (sessionEnd !== '')?end.fromYYYYMMDDHHMMFormat(sessionEnd).toLongDate():qsTr('No definit');
                        return qsTr('Inici: ') + startString + "\n" + qsTr('Final: ') + endString;
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: periodEditorDialog.openPeriodEditor()
                    }
                }
            }
        }

        Item {
            id: fieldsList

            Layout.fillHeight: true
            Layout.fillWidth: true

            RowLayout {
                id: fieldsLayout

                anchors.fill: parent

                Repeater {
                    model: fieldsArray

                    Item {
                        id: singleFieldColumn

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        property string field: modelData
                        property bool updateable: false

                        ListView {
                            id: actionsList

                            anchors.fill: parent
                            clip: true

                            headerPositioning: ListView.OverlayHeader
                            header: Text {
                                z: 2
                                width: actionsList.width
                                height: contentHeight
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.bold: true

                                text: singleFieldColumn.field
                            }

                            model: Models.PlanningActionsModel {
                                id: actionsModel

                                filters: ['session=?', 'field=?']
                                sort: 'number ASC'

                                function update() {
                                    singleFieldColumn.updateable = false;
                                    bindValues = [session, singleFieldColumn.field];
                                    select();
                                }
                            }

                            Connections {
                                target: showSessionItem

                                onUpdateChanges: {
                                    if (singleFieldColumn.updateable) {
                                        actionsModel.update();
                                        showSessionItem.updated({});
                                    }
                                }
                            }

                            spacing: units.nailUnit
                            delegate: ActionStateRectangle {
                                id: singleActionRect

                                z: 1
                                width: actionsList.width
                                height: Math.max(childrenRect.height, units.fingerUnit) + units.nailUnit * 2

                                stateValue: model.state

                                ColumnLayout {
                                    id: singleActionLayout

                                    anchors {
                                        top: parent.top
                                        left: parent.left
                                        right: parent.right
                                        margins: units.nailUnit
                                    }

                                    spacing: units.nailUnit

                                    Text {
                                        Layout.fillWidth: true
                                        height: Math.max(contentHeight, units.fingerUnit)

                                        font.pixelSize: units.fingerUnit
                                        color: '#DDDDDD'

                                        text: model.number
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        height: Math.max(contentHeight, units.fingerUnit)

                                        font.pixelSize: units.readUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                        text: model.contents
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        height: Math.max(contentHeight, units.fingerUnit)

                                        color: 'red'
                                        font.pixelSize: units.readUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                        text: model.pending
                                    }
                                }

                                MouseArea {
                                    anchors.fill: singleActionLayout
                                    onClicked: {
                                        singleFieldColumn.updateable = true;
                                        actionEditorDialog.openActionEditor(model.id);
                                    }
                                }
                            }

                            footer: Item {
                                width: actionsList.width
                                height: units.fingerUnit * 2

                                Common.ImageButton {
                                    anchors.centerIn: parent
                                    size: units.fingerUnit
                                    image: 'plus-24844'

                                    onClicked: {
                                        actionsModel.insertObject({session: session, number: actionsModel.count+1, field: singleFieldColumn.field});
                                        actionsModel.update();
                                        showSessionItem.updated({});
                                    }
                                }
                            }
                        }

                        Component.onCompleted: actionsModel.update();
                    }
                }
            }

        }
    }

    Common.SuperposedWidget {
        id: actionEditorDialog

        function openActionEditor(action) {
            load(qsTr("Edita acció"), 'plannings/ActionEditor', {action: action});
            actionEditorConnecions.target = actionEditorDialog.mainItem;
        }

        Connections {
            id: actionEditorConnecions

            ignoreUnknownSignals: true

            onActionSaved: {
                actionEditorDialog.close();
                updateChanges();
            }
        }
    }

    Common.SuperposedMenu {
        id: periodEditorDialog

        title: qsTr('Edita les dates')

        parentWidth: showSessionItem.width
        parentHeight: showSessionItem.height * 0.5

        function openPeriodEditor() {
            periodEditorItem.setContent(sessionStart, sessionEnd);
            open();
        }

        Annotations.PeriodEditor {
            id: periodEditorItem

            width: periodEditorDialog.parentWidth * 0.8
            height: periodEditorDialog.parentHeight * 0.8

            onPeriodStartChanged: {
                var start = getStartDateString();
                sessionsModel.updateObject(session, {start: start});
                sessionsModel.getSessionInfo();
            }

            onPeriodEndChanged: {
                var end = getEndDateString();
                sessionsModel.updateObject(session, {end: end});
                sessionsModel.getSessionInfo();
            }
        }
    }

    function receiveUpdated(object) {
        showSessionItem.updated(object);
    }
}
