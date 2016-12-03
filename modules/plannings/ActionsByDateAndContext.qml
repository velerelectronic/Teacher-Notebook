import QtQuick 2.7
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///modules/basic' as Basic
import "qrc:///common/FormatDates.js" as FormatDates

Item {
    id: actionsByDateAndContextItem

    property string planning: ''
    property var selectedDate
    property string selectedContext: ''

    property var contexts
    property var itemIdentifiersDict
    property var itemListsList

    signal planningItemsSelected(string title, string list)
    signal updateAll()

    Common.UseUnits {
        id: units
    }

    Models.PlanningsModel {
        id: planningsModel
    }

    Models.PlanningItems {
        id: planningItemsModel

        filters: ['planning=?']

        function getItems() {
            bindValues = [planning];
            select();
            var newIdentifiersDict = {};
            var newListsList = [];
            for (var i=0; i<count; i++) {
                var itemObj = getObjectInRow(i);
                var newItem = itemObj['list'];
                if (newListsList.indexOf(newItem) < 0) {
                    newListsList.push(newItem);
                    newIdentifiersDict[newItem] = [itemObj['id']];
                } else {
                    newIdentifiersDict[newItem].push(itemObj['id']);
                }
            }
            itemIdentifiersDict = newIdentifiersDict;
            itemListsList = newListsList;
        }
    }

    Models.PlanningItemsActionsModel {
        id: contextsModel

        function getContexts() {
            var newContexts = [];
            select();
            for (var i=0; i<count; i++) {
                var obj = getObjectInRow(i);
                var newCtx = obj['context'];
                if (newContexts.indexOf(newCtx) < 0) {
                    newContexts.push(newCtx);
                }
            }
            contexts = newContexts;
        }
    }

    Connections {
        target: actionsByDateAndContextItem

        onUpdateAll: contextsModel.getContexts()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: units.nailUnit

        Common.BoxedText {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            margins: units.nailUnit
            text: planning
        }

        ListView {
            id: contextsView

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2

            orientation: ListView.Horizontal

            model: contexts

            delegate: Common.BoxedText {
                width: contextsView.height * 3
                height: contextsView.height

                color: (ListView.isCurrentItem)?'yellow':'white'
                margins: units.nailUnit
                horizontalAlignment: Text.AlignHCenter
                text: modelData

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        contextsView.currentIndex = model.index;
                        selectedContext = modelData;
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            RowLayout {
                anchors.fill: parent

                Common.ImageButton {
                    Layout.fillHeight: true

                    image: 'arrow-145769'

                    onClicked: {
                        selectedDate = selectedDate.addDays(-1);
                        updateAll();
                    }
                }

                Common.BoxedText {
                    id: selectedDateBox

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    margins: units.nailUnit
                    horizontalAlignment: Text.AlignHCenter
                    fontSize: units.readUnit

                    Connections {
                        target: actionsByDateAndContextItem

                        onUpdateAll: {
                            selectedDateBox.text = selectedDate.toLongDate();
                            planningItemsModel.getItems();
                            itemsActionsModel.refresh();
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            selectedDate = new Date();
                            updateAll();
                        }
                    }

                    Component.onCompleted: {
                        selectedDate = new Date();
                        updateAll();
                    }
                }

                Common.ImageButton {
                    Layout.fillHeight: true

                    image: 'arrow-145766'

                    onClicked: {
                        selectedDate = selectedDate.addDays(+1);
                        updateAll();
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                anchors.fill: parent

                Repeater {
                    model: itemListsList

                    ListView {
                        id: itemsListView

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        property string itemList: modelData

                        model: listItemsActionsModel
                        clip: true
                        spacing: units.nailUnit

                        headerPositioning: ListView.OverlayHeader
                        header: Rectangle {
                            width: itemsListView.width
                            height: units.fingerUnit * 2

                            z: 2

                            color: '#BBFFBB'

                            MouseArea {
                                anchors.fill: parent
                                onClicked: newActionDialog.openNewActionDialog(itemsListView.itemList, selectedDate.toYYYYMMDDFormat())
                                onPressAndHold: planningItemsSelected(planning, itemsListView.itemList)
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: units.nailUnit

                                Text {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: units.readUnit
                                    font.bold: true

                                    text: itemsListView.itemList
                                }
                                Common.ImageButton {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: size
                                    size: units.fingerUnit
                                    image: 'plus-24844'
                                }
                            }
                        }

                        delegate: ActionStateRectangle {
                            width: itemsListView.width
                            height: childrenRect.height

                            z: 1

                            stateValue: model.state

                            Text {
                                anchors {
                                    top: parent.top
                                    right: parent.right
                                    left: parent.left
                                }
                                height: contentHeight

                                padding: units.nailUnit

                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                text: {
                                    var obj = planningItemsModel.getObject(model.item);
                                    return '<p>' + obj['title'] + '<p>' + model.contents + '</p>' + ((model.result !== '')?'<p>' + model.result + '</p>':'');
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: editActionDialog.openEditActionDialog(model.id)
                            }
                        }

                        Models.PlanningItemsActionsModel {
                            id: listItemsActionsModel

                            sort: 'start ASC, end ASC, number ASC'

                            function getItemsActionsInList() {
                                // set items filtering

                                var specificItems = itemIdentifiersDict[itemsListView.itemList];

                                var itemFilters = [];
                                var itemCount = specificItems.length
                                for (var i=0; i<itemCount; i++) {
                                    itemFilters.push('item=?');
                                }

                                var newFilters = [];
                                newFilters.push('INSTR(start,?) OR INSTR(end,?)');
                                if (selectedContext !== '')
                                    newFilters.push('context=?');
                                if (itemCount>0) {
                                    newFilters.push(itemFilters.join(' OR '));
                                }
                                filters = newFilters;

                                var periodStart = selectedDate.toYYYYMMDDFormat();
                                bindValues = [periodStart, periodStart].concat((selectedContext !== '')?[selectedContext]:[]).concat(specificItems);
                                select();
                            }
                        }

                        Connections {
                            target: actionsByDateAndContextItem

                            onSelectedContextChanged: listItemsActionsModel.getItemsActionsInList()
                            onUpdateAll: listItemsActionsModel.getItemsActionsInList()
                        }

                        Component.onCompleted: listItemsActionsModel.getItemsActionsInList()
                    }

                }
            }
        }
    }

    Common.SuperposedWidget {
        id: newActionDialog

        function openNewActionDialog(list, date) {
            load(qsTr("Nova acció"), 'plannings/NewItemAction', {planning: planning, list: list, context: selectedContext, start: date, end: date});
        }

        Connections {
            target: newActionDialog.mainItem
            onSavedContents: updateAll()
        }
    }

    Common.SuperposedWidget {
        id: editActionDialog

        function openEditActionDialog(action) {
            load(qsTr("Edita acció"), 'plannings/EditItemAction', {action: action});
        }

        Connections {
            target: editActionDialog.mainItem
            onSavedContents: updateAll()
        }
    }

}
