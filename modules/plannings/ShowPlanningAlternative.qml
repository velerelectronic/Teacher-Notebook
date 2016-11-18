import QtQuick 2.7
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///modules/basic' as Basic
import "qrc:///common/FormatDates.js" as FormatDates

Rectangle {
    id: showPlanningItem

    property string planning: ''
    property string context: ''
    property var listsArray
    property var itemsArray
    property var contextsArray

    color: 'gray'

    Common.UseUnits {
        id: units
    }

    Models.PlanningItems {
        id: planningItemsModel

        filters: ['planning=?']

        function getItems() {
            bindValues = [planning];
            select();
            var lists = [];
            var items = [];
            for (var i=0; i<count; i++) {
                var itemObj = getObjectInRow(i);
                items.push(itemObj['id']);
                if (lists.indexOf(itemObj['list']) < 0) {
                    lists.push(itemObj['list']);
                }
            }
            listsArray = lists;
            itemsArray = items;
        }
    }

    Models.PlanningItemsActionsModel {
        id: actionDatesModel

        function getDates() {
            planningItemsModel.getItems();
            var newFilters = [];
            var newBindValues = [];
            for (var i=0; i<itemsArray.length; i++) {
                var newItem = itemsArray[i];
                if (newBindValues.indexOf(newItem) < 0) {
                    newFilters.push('item=?');
                    newBindValues.push(newItem);
                }
            }
            filters = newFilters.join(' OR ');
            bindValues = newBindValues;
            select();
            var datesArray = [];
            var newContextsArray = [];
            for (var j=0; j<count; j++) {
                var newDate = getObjectInRow(j)['start'];
                if (typeof (newDate) === 'string') {
                    newDate = newDate.trim();
                } else {
                    newDate = '';
                }
                if (datesArray.indexOf(newDate) < 0) {
                    console.log('nova data', newDate);
                    datesArray.push(newDate);
                }
                var newContext = getObjectInRow(j)['context'];
                if (newContextsArray.indexOf(newContext) < 0) {
                    newContextsArray.push(newContext);
                }
            }
            contextsArray = newContextsArray;
            return datesArray;
        }
    }

    ColumnLayout {
        anchors.fill: parent

        ListView {
            id: contextsList

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            model: contextsArray
            spacing: units.nailUnit
            orientation: ListView.Horizontal

            delegate: Rectangle {
                id: singleContextRect

                width: contextsList.height * 2
                height: contextsList.height

                color: (ListView.isCurrentItem)?'yellow':'white'

                property string context: modelData

                Text {
                    anchors.fill: parent
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: singleContextRect.context
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        contextsList.currentIndex = model.index;
                        showPlanningItem.context = singleContextRect.context;
                        datesList.refreshContents();
                    }
                }
            }
        }

        ListView {
            id: datesList

            Layout.fillHeight: true
            Layout.fillWidth: true

            spacing: units.nailUnit
            clip: true

            headerPositioning: ListView.OverlayHeader
            header: Rectangle {
                width: datesList.width
                height: units.fingerUnit * 2

                z: 2

                color: '#BBFFBB'

                RowLayout {
                    anchors.fill: parent
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: Math.max(parent.width / 4, units.fingerUnit * 4)

                        font.pixelSize: units.readUnit
                        font.bold: true

                        text: qsTr('Data')
                    }

                    Repeater {
                        model: listsArray

                        Common.TextButton {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            font.pixelSize: units.readUnit
                            font.bold: true

                            text: qsTr('Afegeix')

                            onClicked: {
                                newActionDialog.openNewActionDialog(modelData, '');
                            }
                        }
                    }
                }
            }

            delegate: Rectangle {
                id: dateRowItem

                width: datesList.width

                z: 1
                color: '#DDDDDD'
                property string selectedDate: modelData

                RowLayout {
                    id: dateRowLayout

                    anchors.fill: parent
                    spacing: units.nailUnit

                    function recalculateHeight() {
                        var max = units.fingerUnit;
                        for (var i=0; i<children.length; i++) {
                            var h = children[i].requiredHeight;
                            if (h>max)
                                max = h;
                        }
                        dateRowItem.height = max;
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: Math.max(parent.width / 4, units.fingerUnit * 4)

                        Text {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit

                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                            text: {
                                if (dateRowItem.selectedDate !== '') {
                                    var dateObj = new Date();
                                    dateObj.fromYYYYMMDDHHMMFormat(dateRowItem.selectedDate);
                                    return dateObj.toShortReadableDate();
                                } else {
                                    return '';
                                }
                            }
                        }
                    }
                    Repeater {
                        model: listsArray

                        Item {
                            id: listColumnItem

                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            property int requiredHeight: childrenRect.height

                            onRequiredHeightChanged: dateRowLayout.recalculateHeight()
                            property string selectedList: modelData

                            Models.PlanningItems {
                                id: planningItemsForDateAndListModel

                                filters: ['planning=?', 'list=?']
                            }

                            Models.PlanningItemsActionsModel {
                                id: planningItemsActionsForDateAndListModel

                                filters: ['item=?', 'context=?', "(IFNULL(start,'')=? OR IFNULL(end,'')=?)"]
                            }

                            ListModel {
                                id: itemsForDateModel

                                dynamicRoles: true
                            }

                            ColumnLayout {
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    right: parent.right
                                }

                                height: childrenRect.height

                                Text {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: units.fingerUnit

                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: units.readUnit
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    font.bold: true
                                    text: modelData
                                }

                                ListView {
                                    id: specificActionsList

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: childrenRect.height

                                    model: itemsForDateModel
                                    spacing: units.nailUnit
                                    interactive: false

                                    delegate: ActionStateRectangle {
                                        width: specificActionsList.width
                                        height: Math.max(actionStateText.height, units.fingerUnit) + units.nailUnit * 2

                                        stateValue: model.state

                                        Text {
                                            id: actionStateText
                                            anchors {
                                                top: parent.top
                                                left: parent.left
                                                right: parent.right
                                                margins: units.nailUnit
                                            }
                                            height: contentHeight
                                            font.pixelSize: units.readUnit
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            text: model.contents + ((model.result !== '')?(" >> " + model.result):'')
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                editActionDialog.openEditActionDialog(model.id);
                                            }
                                        }
                                    }
                                }
                                Item {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: units.fingerUnit + units.nailUnit
                                }
                            }

                            Common.ImageButton {
                                anchors {
                                    bottom: parent.bottom
                                    horizontalCenter: parent.horizontalCenter
                                    margins: units.nailUnit
                                }
                                size: units.fingerUnit
                                image: 'plus-24844'
                                onClicked: {
                                    newActionDialog.openNewActionDialog(modelData, dateRowItem.selectedDate);
                                }
                            }

                            Connections {
                                target: showPlanningItem
                                onContextChanged: {
                                    listColumnItem.getSelectedItems();
                                }
                            }

                            function getSelectedItems() {
                                itemsForDateModel.clear();

                                planningItemsForDateAndListModel.bindValues = [planning, listColumnItem.selectedList];
                                planningItemsForDateAndListModel.select();

                                for (var i=0; i<planningItemsForDateAndListModel.count; i++) {
                                    var itemObj = planningItemsForDateAndListModel.getObjectInRow(i);

                                    // filter actions on item, context and date (start or end)
                                    planningItemsActionsForDateAndListModel.bindValues = [itemObj['id'], context, dateRowItem.selectedDate, dateRowItem.selectedDate];
                                    planningItemsActionsForDateAndListModel.select();

                                    for (var j=0; j<planningItemsActionsForDateAndListModel.count; j++) {
                                        var actionObj = planningItemsActionsForDateAndListModel.getObjectInRow(j);
                                        itemsForDateModel.append(actionObj);
                                    }
                                }
                            }

                            Component.onCompleted: getSelectedItems()
                        }
                    }
                }
            }

            function refreshContents() {
                model = [];
                var datesArray = actionDatesModel.getDates();

                datesArray.sort();
                model = datesArray;
            }

            Component.onCompleted: refreshContents()
        }
    }

    Common.SuperposedWidget {
        id: newActionDialog

        function openNewActionDialog(list, date) {
            load(qsTr("Nova acció"), 'plannings/NewItemAction', {planning: showPlanningItem.planning, list: list, context: context, start: date, end: date});
        }
    }

    Common.SuperposedWidget {
        id: editActionDialog

        function openEditActionDialog(action) {
            load(qsTr("Edita acció"), 'plannings/EditItemAction', {action: action});
        }
    }
}
