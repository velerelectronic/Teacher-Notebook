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
    }

    Flickable {
        id: cardsArea

        anchors.fill: parent

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
        cardsModel.append({title: qsTr('Recents'), cardName: 'RecentPages'});
        cardsModel.append({title: qsTr('Planificacions'), cardName: 'Plannings'});
        cardsModel.append({title: qsTr('Esdeveniments'), cardName: 'TodayEvents'});
        cardsModel.append({title: qsTr('Pendents'), cardName: 'PendingAnnotations'});
        cardsModel.append({title: qsTr('No definides'), cardName: 'InboxAnnotations'});
        cardsModel.append({title: qsTr('Setmanes'), cardName: 'Weeks'});
        cardsModel.append({title: qsTr('Valoracions'), cardName: 'LastCheckLists'});
        cardsModel.append({title: qsTr('Destacades'), cardName: 'PinnedAnnotations'});
        cardsModel.append({title: qsTr('Altres pàgines'), cardName: 'OtherPages'});
        cardsModel.append({title: qsTr('Paperera'), cardName: 'Trash'});
    }
}
