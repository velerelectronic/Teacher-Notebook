import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import 'qrc:///common' as Common
import 'qrc:///modules/pagesfolder' as PagesFolder

Item {
    id: cardsListItem

    signal selectedPage(string page, var parameters, string title)
    property int columnsNumber: Math.max(Math.round(width / (units.fingerUnit * 10)),1)
    property Item slotsObject

    Common.UseUnits {
        id: units
    }

    ListModel {
        id: cardsModel

        dynamicRoles: true

        // Fields:
        // * title: card title
        // * cardName: card name to define page. cardName + "Card.qml" is the complete page name
        // * column: horizontal position in the screen
        // * posY: the vertical position of the widget
        // * height: the vertical extent of the widget

        onCountChanged: cardsSecondArea.setupOffset()

        function appendR(obj) {
            obj['column'] = 0;
            obj['posY'] = 0;
            obj['height'] = 0;
            append(obj);
        }
    }


    Flickable {
        id: flickArea

        anchors.fill: parent

        contentWidth: cardsSecondArea.width
        contentHeight: cardsSecondArea.height

        Item {
            id: cardsSecondArea

            width: flickArea.width
            height: childrenRect.height

            property int availableWidth: cardsSecondArea.width - units.fingerUnit * (columnsNumber-1)
            property int columnWidth: cardsSecondArea.availableWidth / columnsNumber

            Repeater {
                model: cardsModel

                delegate: SingleCard {
                    id: singleCardItem
                    // Set up position

                    property int col: model.column
                    x: col * (cardsSecondArea.columnWidth + units.fingerUnit)
                    y: Math.floor(model.posY)

                    onColChanged: { console.log('new col', singleCardItem.col); }

                    width: cardsSecondArea.columnWidth
                    height: Math.max(requiredHeight, units.fingerUnit)

                    title: model.title

                    MouseArea {
                        enabled: false
                        anchors.fill: parent
                        drag.target: singleCardItem
                        drag.axis: Drag.XAxis
                        drag.minimumX: 0
                        drag.filterChildren: true

                        onReleased: {
                            singleCardItem.x = 0;
                        }
                    }

                    PagesFolder.PageConnections {
                        target: singleCardItem.subCardTarget
                        destination: slotsObject
                    }

                    cardItem: model.cardName

                    onSelectedPage: cardsListItem.selectedPage(page, parameters, title)

                    onWidthChanged: cardsSecondArea.setupOffset()
                    onHeightChanged: cardsSecondArea.setupOffset()
                    onRequiredHeightChanged: {
                        cardsModel.setProperty(model.index, "height", requiredHeight)
                        cardsSecondArea.setupOffset();
                    }

                    Component.onCompleted: {
                        cardsModel.setProperty(model.index, "height", requiredHeight)
                        cardsSecondArea.setupOffset();
                    }
                }
            }

            function setupOffset() {
                // Set up offset and extent of each card
                // Return index and minimum value
                // Preconditions:
                // * Array must have at least one item

                var extentsArray = [];
                for (var i=0; i<columnsNumber; i++) {
                    extentsArray.push(0);
                }
                var idx = 0;
                var extent = extentsArray[idx];

                // Traverse all cards
                for (var i=0; i<cardsModel.count; i++) {
                    // Traverse extents of each column
                    for (var j=0; j<columnsNumber; j++) {
                        if (extentsArray[j] < extent) {
                            idx = j;
                            extent = extentsArray[j];
                        }
                    }
                    cardsModel.setProperty(i, "column", idx);
                    cardsModel.setProperty(i, "posY", extent);
                    extent = extent + cardsModel.get(i)['height'] + units.fingerUnit;
                    extentsArray[idx] = extent;
                }
            }
        }
    }

    Flickable {
        id: cardsArea

        anchors.fill: parent

        visible: false
        contentHeight: cardsListView.height
        contentWidth: cardsListView.width

        Flow {
            id: cardsListView
            height: cardsListView.childrenRect.height
            width: cardsListItem.width
            flow: Flow.LeftToRight
            spacing: units.fingerUnit

            property int availableWidth: cardsListView.width - cardsListView.spacing * (columnsNumber-1)

            Repeater {

                model: cardsModel

                delegate: SingleCard {
                    id: singleCardItem

                    width: cardsListView.availableWidth / columnsNumber
                    height: singleCardItem.requiredHeight

                    title: model.title

                    MouseArea {
                        enabled: false
                        anchors.fill: parent
                        drag.target: singleCardItem
                        drag.axis: Drag.XAxis
                        drag.minimumX: 0
                        drag.filterChildren: true

                        onReleased: {
                            singleCardItem.x = 0;
                        }
                    }

                    PagesFolder.PageConnections {
                        target: singleCardItem.subCardTarget
                        destination: slotsObject
                    }

                    cardItem: model.cardName

                    onSelectedPage: cardsListItem.selectedPage(page, parameters, title)
                }
            }
        }
    }


    Component.onCompleted: {
        cardsModel.appendR({title: qsTr('Recents'), cardName: 'RecentPages'});
        cardsModel.appendR({title: qsTr('Planificacions'), cardName: 'Plannings'});
        cardsModel.appendR({title: qsTr('Esdeveniments'), cardName: 'TodayEvents'});
        cardsModel.appendR({title: qsTr('Pendents'), cardName: 'PendingAnnotations'});
        cardsModel.appendR({title: qsTr('No definides'), cardName: 'InboxAnnotations'});
        cardsModel.appendR({title: qsTr('Setmanes'), cardName: 'Weeks'});
        cardsModel.appendR({title: qsTr('Valoracions'), cardName: 'LastCheckLists'});
        cardsModel.appendR({title: qsTr('Destacades'), cardName: 'PinnedAnnotations'});
        cardsModel.appendR({title: qsTr('Altres pàgines'), cardName: 'OtherPages'});
        cardsModel.appendR({title: qsTr('Paperera'), cardName: 'Trash'});
    }
}
