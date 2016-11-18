import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import QtQuick.Dialogs 1.2
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///modules/basic' as Basic
import 'qrc:///editors' as Editors

Rectangle {
    id: editItemActionRect

    property int action
    property alias contents: contentsEditor.content
    property alias result: resultEditor.content
    property string start: ''
    property string end: ''
    property string itemList: ''
    property string itemTitle: ''
    property string itemDesc: ''
    property string stateValue: ''

    signal close()

    Common.UseUnits {
        id: units
    }

    color: 'gray'

    Models.PlanningItems {
        id: itemsModel
    }

    Models.PlanningItemsActionsModel {
        id: itemsActionsModel

        function getItemInfo() {
            var obj = getObject(action);
            contents = obj['contents'];
            result = obj['result'];
            stateValue = obj['state'];
            start = obj['start'];
            end = obj['end'];

            var itemObj = itemsModel.getObject(obj['item']);
            itemList = itemObj['list'];
            itemTitle = itemObj['title'];
            itemDesc = itemObj['desc'];

        }

        Component.onCompleted: getItemInfo()
    }

    ListView {
        id: editorsList

        anchors.fill: parent

        clip: true
        spacing: units.nailUnit

        model: ObjectModel {
            Common.BoxedText {
                width: editorsList.width
                height: units.fingerUnit * 2

                fontSize: units.readUnit
                boldFont: true
                text: itemList
            }
            Common.BoxedText {
                width: editorsList.width
                height: units.fingerUnit * 2

                fontSize: units.readUnit
                text: "<p><b>" + itemTitle + "</b></p><p>" + itemDesc + "</p>"
            }

            Editors.TextAreaEditor3 {
                id: contentsEditor

                width: editorsList.width
                height: units.fingerUnit * 6

                color: 'white'
            }
            Editors.TextAreaEditor3 {
                id: resultEditor

                width: editorsList.width
                height: units.fingerUnit * 6

                color: '#FFAAAA'
                content: result
            }

            Flow {
                id: stateEditor

                width: editorsList.width
                height: childrenRect.height

                spacing: units.fingerUnit

                Repeater {
                    model: ['open', 'completed', 'discarded']

                    Rectangle {
                        width: stateValueText.width + units.nailUnit * 2
                        height: units.fingerUnit * 1.5

                        color: (stateValue == modelData)?'yellow':'#AAAAAA'

                        Text {
                            id: stateValueText

                            anchors {
                                left: parent.left
                                margins: units.nailUnit
                            }
                            anchors.verticalCenter: parent.verticalCenter
                            width: contentWidth

                            font.pixelSize: units.readUnit
                            text: modelData
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: stateValue = modelData
                        }
                    }
                }
            }

            Common.BoxedText {
                width: editorsList.width
                height: units.fingerUnit * 2
                margins: units.nailUnit
                text: {
                    var startDate = new Date();
                    var startString = (start !== '')?startDate.fromYYYYMMDDHHMMFormat(start).toLongDate():qsTr('No definit');

                    var endDate = new Date();
                    var endString = (end !== '')?endDate.fromYYYYMMDDHHMMFormat(end).toLongDate():qsTr('No definit');
                    return "<p>Inici: " + startString + "</p><p>Final: " + endString + "</p>";
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        periodEditor.openPeriodEditor();
                    }
                }
            }

            Common.TextButton {
                width: editorsList.width
                height: units.fingerUnit

                text: qsTr('Desa')

                onClicked: {
                    var updatedAction = {
                        contents: contentsEditor.content,
                        result: resultEditor.content,
                        state: stateValue
                    }
                    itemsActionsModel.updateObject(action, updatedAction);

                    close();
                }
            }

            Common.TextButton {
                width: editorsList.width
                height: units.fingerUnit

                color: 'red'
                text: qsTr('Esborra')

                onClicked: confirmDeletionDialog.open()

                MessageDialog {
                    id: confirmDeletionDialog

                    title: qsTr("Esborrar una acció")

                    text: qsTr("Estàs a punt d'esborrar l'acció. Vols continuar?")

                    standardButtons: StandardButton.Yes | StandardButton.No

                    onYes: {
                        itemsActionsModel.removeObject(action);
                        editItemActionRect.close();
                    }
                }

            }
        }
    }

    Common.SuperposedWidget {
        id: periodEditor

        function openPeriodEditor() {
            load(qsTr('Edita periode'), 'annotations2/PeriodEditor', {});
            mainItem.setContent(start, end);
        }

        Connections {
            target: periodEditor.mainItem

            onPeriodStartChanged: {
                var start = periodEditor.mainItem.getStartDateString();
                itemsActionsModel.updateObject(action, {start: start});
                itemsActionsModel.getItemInfo();
                periodEditor.close();
            }

            onPeriodEndChanged: {
                var end = periodEditor.mainItem.getEndDateString();
                itemsActionsModel.updateObject(action, {end: end});
                itemsActionsModel.getItemInfo();
                periodEditor.close();
            }
        }
    }
}
