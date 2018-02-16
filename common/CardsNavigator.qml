import QtQuick 2.7
import QtQml.Models 2.3

Item {
    id: cardsNavigatorBase

    objectName: "CardsNavigator"

    ObjectModel {
        id: cardsModel
    }

    property int totalCount: cardsModel.children.length


    Component {
        id: navigationCardComponent

        NavigationCard {
            anchors.fill: cardsNavigatorBase

            totalCount: cardsNavigatorBase.totalCount

            onOpenIndexedCard: {
                removeNextCards(index);
                console.log('appending indexed', page, pageProperties, cardProperties);
                appendCardComponent(page, pageProperties, cardProperties);
                openCard(index+1);
            }

            onCardSelected: {
                closeNextCard(index);
            }

            onCardHasMoved: {
                movePreviousCards(index);
                moveNextCards(index+1);
            }

            onConnectToNextCard: {
                if (index+1<totalCount) {
                    connections.target = cardsModel.get(index+1).innerPageItem;
                }
            }
        }
    }

    function paintCards() {
        for (var i=0; i<cardsModel.count; i++) {

        }
    }

    function appendCardComponent(pageComp, pageProperties, cardProperties) {
        // Add a card at the end of the cards list. The card is an existing object

        cardProperties['navigator'] = cardsNavigatorBase;
        var navCard = navigationCardComponent.createObject(cardsNavigatorBase, cardProperties);

        console.log('setting ', pageComp);
        if (typeof pageComp !== 'string') {
            navCard.setSourceComponent(pageComp, pageProperties);
        } else {
            navCard.setPageSource(pageComp, pageProperties);
        }

//        navCard.parent = cardsModel;
        cardsModel.append(navCard);
    }

    function popCard() {
        // Remove the last card of the list

        cardsModel.get(cardsModel.count-1).destroy();
        cardsModel.remove(cardsModel.count-1);
    }

    function setConnections(connectionsObj, page) {
        connectionsObj.target = getNextItem(page);
    }

    function insertFirstPage(page, pageProperties, cardProperties) {
        removeNextCards(-1);
        appendCardComponent(page, pageProperties, cardProperties, false)
    }

    function removeNextCards(index) {
        while (cardsModel.count > index+1) {
            popCard();
        }
    }

    function closeNextCard(index) {
        console.log('closing next', index);
        if (index+1 < totalCount)
            cardsModel.get(index+1).closeCard();
    }

    function openPreviousCard(index) {
        console.log('opening previous', index);
        if (index>0)
            cardsModel.get(index-1).openCard();
    }

    function openNextCard(index) {
        if (index+1 < totalCount)
            cardsModel.get(index+1).openCard();
    }

    function movePreviousCards(index) {
        console.log('moving previous', index);
        for (var i=index; i>0; i--) {
            var prev = cardsModel.get(i-1);
            var actual = cardsModel.get(i);
            if (prev.actualCardVerticalOffset + prev.headingHeight > actual.actualCardVerticalOffset) {
                prev.actualCardVerticalOffset = actual.actualCardVerticalOffset - prev.headingHeight;
            } else
                break;
        }
    }

    function moveNextCards(index) {
        console.log('moving next', index);
        for (var i=index; i<totalCount-1; i++) {
            var next = cardsModel.get(i+1);
            var actual = cardsModel.get(i);
            console.log('obj name', next.objectName, 'obj name', actual.objectName);
            if (actual.actualCardVerticalOffset + actual.headingHeight > next.actualCardVerticalOffset) {
                next.actualCardVerticalOffset = actual.actualCardVerticalOffset + actual.headingHeight;
            } else
                break;
        }

    }

    function getNextItem(page) {
        return cardsModel.get(page.parent.index+1).innerPageItem;
    }
}
