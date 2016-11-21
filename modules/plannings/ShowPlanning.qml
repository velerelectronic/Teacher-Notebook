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

    signal planningItemsSelected(string title)
    signal update()

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
            if (lists.length == 0)
                lists.push('');
            listsArray = lists;
            itemsArray = items;
        }
    }

    Models.PlanningItemsActionsModel {
        id: actionDatesModel

        function getDates() {
            var datesArray = [];
            var newContextsArray = [];

            planningItemsModel.getItems();
            console.log('getting dates --------');

            for (var i=0; i<itemsArray.length; i++) {
                console.log('item', itemsArray[i]);
            }

            if (itemsArray.length > 0) {
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
                for (var j=0; j<count; j++) {
                    var newDate = getObjectInRow(j)['start'];
                    if (typeof (newDate) === 'string') {
                        newDate = newDate.trim();
                    } else {
                        newDate = '';
                    }
                    if (datesArray.indexOf(newDate) < 0) {
                        datesArray.push(newDate);
                    }
                    var newContext = getObjectInRow(j)['context'];
                    if (typeof newContext === 'string')
                        newContext = newContext.trim();
                    else
                        newContext = '';
                    if (newContextsArray.indexOf(newContext) < 0) {
                        newContextsArray.push(newContext);
                    }
                }
            }
            if (datesArray.indexOf('') < 0)
                datesArray.push('');
            if (newContextsArray.length == 0)
                newContextsArray.push('');
            contextsArray = newContextsArray;
            return datesArray;
        }
    }

    ListModel {
        id: datesArrayModel
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
            model: datesArrayModel

            property string todayYYYYMMDD: ''
            signal refreshRequested()

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

                            text: qsTr('Afegeix') + "\n" + modelData

                            onClicked: {
                                newActionDialog.openNewActionDialog(modelData, '');
                            }
                            onPressAndHold: {
                                showPlanningItem.planningItemsSelected(planning);
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
                border.color: (datesList.todayYYYYMMDD == dateRowItem.selectedDate)?'yellow':'transparent'

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
                            property bool shouldUpdate: false

                            onRequiredHeightChanged: dateRowLayout.recalculateHeight()
                            property string selectedList: modelData

                            Models.PlanningItems {
                                id: planningItemsForDateAndListModel

                                filters: ['planning=?', 'list=?']
                            }

                            Models.PlanningItemsActionsModel {
                                id: planningItemsActionsForDateAndListModel

                                filters: ['item=?', "IFNULL(context, '')=?", "(IFNULL(start,'')=? OR IFNULL(end,'')=?)"]
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
                                            text: '<p>' + model.itemTitle + '</p><p>' + model.contents + '</p>' + ((model.result !== '')?("<p><font color=\"red\">" + model.result) + "</font></p>":'')
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                listColumnItem.shouldUpdate = true;
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
                                    listColumnItem.shouldUpdate = true;
                                    newActionDialog.openNewActionDialog(modelData, dateRowItem.selectedDate);
                                }
                            }

                            Connections {
                                target: showPlanningItem
                                onContextChanged: {
                                    listColumnItem.getSelectedItems();
                                }
                                onUpdate: {
                                    if (listColumnItem.shouldUpdate) {
                                        listColumnItem.shouldUpdate = false;
                                        listColumnItem.getSelectedItems();
                                    }
                                }
                            }

                            function getSelectedItems() {
                                itemsForDateModel.clear();

                                planningItemsForDateAndListModel.bindValues = [planning, listColumnItem.selectedList];
                                planningItemsForDateAndListModel.select();

                                for (var i=0; i<planningItemsForDateAndListModel.count; i++) {
                                    var itemObj = planningItemsForDateAndListModel.getObjectInRow(i);

                                    // filter actions on item, context and date (start or end)
                                    planningItemsActionsForDateAndListModel.bindValues = [itemObj['id'], showPlanningItem.context, dateRowItem.selectedDate, dateRowItem.selectedDate];
                                    planningItemsActionsForDateAndListModel.select();

                                    for (var j=0; j<planningItemsActionsForDateAndListModel.count; j++) {
                                        var actionObj = planningItemsActionsForDateAndListModel.getObjectInRow(j);
                                        actionObj['itemTitle'] = itemObj['title'];
                                        itemsForDateModel.append(actionObj);
                                    }
                                }
                            }

                            Component.onCompleted: {
                                listColumnItem.getSelectedItems();
                            }
                        }
                    }
                }

            }

            function refreshContents() {
                var today = new Date();
                datesList.todayYYYYMMDD = today.toYYYYMMDDFormat();

                var datesArray = actionDatesModel.getDates();
                datesArray.sort();

                datesArrayModel.clear();
                for (var i=0; i<datesArray.length; i++) {
                    datesArrayModel.append({date: datesArray[i]});
                }
            }

            Component.onCompleted: refreshContents()
        }
    }

    Common.SuperposedWidget {
        id: newActionDialog

        function openNewActionDialog(list, date) {
            load(qsTr("Nova acció"), 'plannings/NewItemAction', {planning: showPlanningItem.planning, list: list, context: context, start: date, end: date});
        }

        Connections {
            target: newActionDialog.mainItem
            onSavedContents: showPlanningItem.update();
        }
    }

    Common.SuperposedWidget {
        id: editActionDialog

        function openEditActionDialog(action) {
            load(qsTr("Edita acció"), 'plannings/EditItemAction', {action: action});
        }

        Connections {
            target: editActionDialog.mainItem
            onSavedContents: showPlanningItem.update();
        }
    }
}
