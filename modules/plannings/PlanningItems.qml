import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors

Rectangle {
    property string planning: ''

    color: 'gray'

    Common.UseUnits {
        id: units
    }


    Models.PlanningItems {
        id: planningItemsModel

        filters: ['planning=?']
        sort: 'list ASC, number ASC, title ASC'

        function refresh() {
            bindValues = [planning];
            select();
        }

        Component.onCompleted: refresh()
    }

    ColumnLayout {
        anchors.fill: parent
        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            text: planning
        }
        ListView {
            id: itemsList

            Layout.fillHeight: true
            Layout.fillWidth: true

            section.property: 'list'
            section.delegate: Rectangle {
                width: itemsList.width
                height: units.fingerUnit

                z: 1
                color: 'grey'

                Text {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    color: 'white'
                    font.pixelSize: units.readUnit
                    elide: Text.ElideRight
                    text: section
                }
            }

            spacing: units.nailUnit
            model: planningItemsModel
            clip: true

            headerPositioning: ListView.OverlayHeader
            header: Rectangle {
                width: itemsList.width
                height: units.fingerUnit

                z: 2
                color: '#AAFFAA'

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit

                    Text {
                        Layout.preferredWidth: units.fingerUnit * 2
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        text: '#'
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 3
                        Layout.fillHeight: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: units.readUnit
                        font.bold: true
                        text: qsTr('Títol')
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: units.readUnit
                        font.bold: true
                        text: qsTr('Descripció')
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: units.readUnit
                        font.bold: true
                        text: qsTr('Accions')
                    }
                }
            }

            delegate: Rectangle {
                id: singlePlanningItemRect

                width: itemsList.width
                height: units.fingerUnit * 2

                z: 1
                property int itemId: model.id

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit

                    Text {
                        Layout.preferredWidth: units.fingerUnit * 2
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        text: model.number
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 3
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        text: model.title

                        MouseArea {
                            anchors.fill: parent
                            onClicked: titleEditorDialog.openTitleEditor(model.id, model.title)
                            onPressAndHold: listEditorDialog.openListEditor(model.id, model.list)
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        text: model.desc

                        MouseArea {
                            anchors.fill: parent
                            onClicked: descEditorDialog.openDescEditor(model.id, model.desc)
                            onPressAndHold: confirmItemDeletionDialog.openConfirmItemDeletion(model.id, model.title)
                        }
                    }

                    Loader {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4

                        asynchronous: true

                        sourceComponent: Text {
                            id: actionsText
                            text: 'holaaa'

                            Models.PlanningItemsActionsModel {
                                id: itemsActionsModel

                                filters: ['item=?']

                                function update() {
                                    bindValues = [singlePlanningItemRect.itemId];
                                    select();
                                    if (count>0)
                                        actionsText.text = count + " " + qsTr("accions");
                                    else
                                        actionsText.text = '-';
                                }
                            }

                            Component.onCompleted: itemsActionsModel.update();
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: newActionDialog.openNewActionDialog(model.list)
                        }
                    }
                }
            }
            Common.ImageButton {
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                }
                padding: units.fingerUnit
                image: 'plus-24844'

                onClicked: {
                    var nextNumber = planningItemsModel.count + 1;
                    planningItemsModel.insertObject({planning: planning, title: qsTr('Element ') + nextNumber, number: nextNumber, list: qsTr('# Nova llista')});
                    planningItemsModel.refresh();
                }
            }
        }
    }

    Common.SuperposedMenu {
        id: titleEditorDialog

        title: qsTr("Edita el títol")
        property int itemId

        standardButtons: StandardButton.Save | StandardButton.Cancel

        Editors.TextAreaEditor3 {
            id: titleEditorItem

            width: titleEditorDialog.parentWidth
            height: units.fingerUnit * 8
        }

        function openTitleEditor(itemId, title) {
            titleEditorDialog.itemId = itemId;
            titleEditorItem.content = title;
            open();
        }

        onAccepted: {
            planningItemsModel.updateObject(titleEditorDialog.itemId, {title: titleEditorItem.content});
            titleEditorDialog.close();
            planningItemsModel.refresh();
        }
    }

    Common.SuperposedMenu {
        id: descEditorDialog

        title: qsTr("Edita la descripció")
        property int itemId

        standardButtons: StandardButton.Save | StandardButton.Cancel

        Editors.TextAreaEditor3 {
            id: descEditorItem

            width: titleEditorDialog.parentWidth
            height: units.fingerUnit * 8
        }

        function openDescEditor(itemId, desc) {
            descEditorDialog.itemId = itemId;
            descEditorItem.content = desc;
            open();
        }

        onAccepted: {
            planningItemsModel.updateObject(descEditorDialog.itemId, {desc: descEditorItem.content});
            descEditorDialog.close();
            planningItemsModel.refresh();
        }
    }

    Common.SuperposedMenu {
        id: listEditorDialog

        title: qsTr("Edita la llista")
        property int itemId

        standardButtons: StandardButton.Save | StandardButton.Cancel

        Editors.TextAreaEditor3 {
            id: listEditorItem

            width: titleEditorDialog.parentWidth
            height: units.fingerUnit * 8
        }

        function openListEditor(itemId, list) {
            listEditorDialog.itemId = itemId;
            listEditorItem.content = list;
            open();
        }

        onAccepted: {
            planningItemsModel.updateObject(listEditorDialog.itemId, {list: listEditorItem.content.trim()});
            listEditorDialog.close();
            planningItemsModel.refresh();
        }
    }

    Common.SuperposedWidget {
        id: newActionDialog

        function openNewActionDialog(list) {
            load(qsTr("Nova acció"), 'plannings/NewItemAction', {planning: planning, list: list});
        }
    }

    MessageDialog {
        id: confirmItemDeletionDialog

        title: qsTr("Esborrar element")

        property int itemId
        property string itemTitle: ''

        text: qsTr("Estàs a punt d'esborrar l'element «") +  confirmItemDeletionDialog.itemTitle + qsTr("». N'estàs segur?")

        standardButtons: StandardButton.Yes | StandardButton.No

        function openConfirmItemDeletion(itemId, title) {
            confirmItemDeletionDialog.itemId = itemId;
            confirmItemDeletionDialog.itemTitle = title;
            open();
        }

        onYes: {
            planningItemsModel.removeObject(confirmItemDeletionDialog.itemId);
            planningItemsModel.refresh();
        }
    }
}
