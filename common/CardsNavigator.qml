import QtQuick 2.7
import QtQml.Models 2.3

Item {
    id: cardsNavigatorBase

    ObjectModel {
        id: cardsModel
    }

    property int totalCount: cardsModel.children.length


    Component {
        id: navigationCardComponent

        NavigationCard {
            anchors.fill: cardsNavigatorBase

            totalCount: cardsNavigatorBase.totalCount
        }
    }

    function paintCards() {
        for (var i=0; i<cardsModel.count; i++) {

        }
    }

    function appendCardPage(title, page, properties) {
        // Add a card at the end of the cards list. The card is defined as a qml page

        var navPane = Qt.createQmlObject();

        appendCardObject(title, navPane, properties);
    }

    function appendCardComponent(pageComp, cardProperties, pageProperties) {
        // Add a card at the end of the cards list. The card is an existing object

        cardProperties['navigator'] = cardsNavigatorBase;
        var navCard = navigationCardComponent.createObject(cardsNavigatorBase, cardProperties);

        /*
        for (var prop in cardProperties) {
            navCard[prop] = cardProperties[prop];
        }
        */

        console.log('setting ', pageComp);
        navCard.setSourceComponent(pageComp, pageProperties);

//        navCard.parent = cardsModel;
        cardsModel.append(navCard);
    }

    Component {
        id: tempComp

        Rectangle {
            border.color: 'black'
            color: 'pink'
        }
    }

    function popCard() {
        // Remove the last card of the list

        cardsModel.remove(cardsModel.count-1);
    }

    function setNextComponent(index, pageComp, cardProperties, pageProperties) {
        console.log('index', index, totalCount);
        if (index+1 < totalCount) {
            cardsModel.get(index+1).setSourceComponent(pageComp, pageProperties);
        } else {
            appendCardComponent(pageComp, cardProperties, pageProperties);
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
            if (actual.actualCardVerticalOffset + actual.headingHeight > next.actualCardVerticalOffset) {
                next.actualCardVerticalOffset = actual.actualCardVerticalOffset + actual.headingHeight;
            } else
                break;
        }

    }
}
