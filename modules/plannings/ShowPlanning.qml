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
                height: Math.max(sessionBasicInfoLayout.height, actionsRect.height)

                property int sessionId: model.id

                MouseArea {
                    anchors.fill: parent
                    onClicked: sessionSelected(singleSessionRect.sessionId)
                }

                Flow {
                    id: sessionBasicInfoLayout

                    anchors {
                        top: parent.top
                        left: parent.left
                        margins: units.nailUnit
                    }
                    width: Math.max(Math.floor(parent.width / (fieldsArray.length+1)), units.fingerUnit * 4)
                    spacing: units.fingerUnit
                    height: childrenRect.height + 2 * units.nailUnit

                    Text {
                        height: contentHeight
                        width: Math.min(contentWidth, parent.width)

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.number
                    }
                    Text {
                        height: contentHeight
                        width: Math.min(contentWidth, parent.width)

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.title
                    }
                    Text {
                        height: contentHeight
                        width: Math.min(contentWidth, parent.width)

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.desc
                    }
                    Text {
                        height: contentHeight
                        width: Math.min(contentWidth, parent.width)

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: {
                            if (model.start !== '') {
                                var date = new Date();
                                return qsTr('Comença ') + date.fromYYYYMMDDHHMMFormat(model.start).toShortReadableDate();
                            } else {
                                return '';
                            }
                        }
                    }
                    Text {
                        height: contentHeight
                        width: Math.min(contentWidth, parent.width)

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: {
                            if (model.end !== '') {
                                var date = new Date();
                                return qsTr('Acaba ') + date.fromYYYYMMDDHHMMFormat(model.end).toShortReadableDate();
                            } else {
                                return '';
                            }
                        }
                    }
                }

                Rectangle {
                    id: actionsRect

                    anchors {
                        top: parent.top
                        left: sessionBasicInfoLayout.right
                        right: parent.right
                    }
                    height: childrenRect.height + units.nailUnit
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
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }
                size: units.fingerUnit * 1.5
                image: 'plus-24844'

                onClicked: {
                    var number = sessionsModel.count+1;
                    sessionsModel.insertObject({planning: planning, number: number, title: qsTr('Sessió ') + number});
                    sessionsModel.refresh();
                    showPlanningItem.updated({});
                }
            }
        }
    }

    function receiveUpdated(object) {
        sessionsModel.refresh();
        showPlanningItem.updated(object);
    }

    Component.onCompleted: {
        planningsModel.getFieldsArray();
        sessionsModel.refresh();
    }

}
