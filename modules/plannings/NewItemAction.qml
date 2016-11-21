import QtQuick 2.7
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///modules/basic' as Basic
import 'qrc:///editors' as Editors

Rectangle {
    property string planning: ''
    property string list: ''
    property string context: ''
    property string start: ''
    property string end: ''

    signal savedContents()
    signal close()

    Common.UseUnits {
        id: units
    }

    color: 'gray'

    Models.PlanningItems {
        id: planningItemsModel

        filters: ['planning=?', 'list=?']
        sort: 'number ASC, title ASC'

        function update() {
            bindValues = [planning, list];
            select();
        }

        Component.onCompleted: update()
    }

    Models.PlanningItemsActionsModel {
        id: itemsActionsModel
    }

    ColumnLayout {
        anchors.fill: parent

        Common.BoxedText {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2

            color: '#AAFFAA'
            text: list
        }

        ListView {
            id: listsList

            Layout.fillWidth: true
            Layout.fillHeight: true

            property int selectedItem: -1

            model: planningItemsModel
            spacing: units.nailUnit
            clip: true

            delegate: Rectangle {
                width: listsList.width
                height: units.fingerUnit * 2

                color: (ListView.isCurrentItem)?'yellow':'white'
                Text {
                    anchors.fill: parent
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: model.title + " " + model.desc
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        listsList.currentIndex = model.index;
                        listsList.selectedItem = model.id;
                    }
                }
            }
        }

        Editors.TextAreaEditor3 {
            id: contentsEditor

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 6
        }
        Editors.TextAreaEditor3 {
            id: contextEditor

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 6

            content: context
        }

        Common.TextButton {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            text: qsTr('Desa')

            onClicked: {
                var newAction = {
                    item: listsList.selectedItem,
                    context: contextEditor.content,
                    number: 1,
                    contents: contentsEditor.content,
                    start: start,
                    end: end
                }
                itemsActionsModel.insertObject(newAction);

                savedContents();
                close();
            }
        }
    }
}
