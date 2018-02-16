import QtQuick 2.7
import QtQml.Models 2.3

Item {
    id: navCardBase

    objectName: "NavigationCard"

    property int    index: ObjectModel.index
    property int    totalCount: 0

    property int    fontSize: units.readUnit
    property string headingColor: 'black'
    property string backgroundColor: '#AAAAAA'
    property int    headingHeight: units.fingerUnit * 2
    property string headingText: ''
    property Item navigator
    property alias innerPageItem: innerPageLoader.item

    property alias actualCardVerticalOffset: cardRect.y

    signal cardHasMoved(int index)
    signal cardSelected(int index)
    signal openIndexedCard(int index, string page, var pageProperties, var cardProperties)
    signal connectToNextCard(int index, var connections)

//    property CardsNavigator navigator

    anchors.margins: units.nailUnit

    UseUnits {
        id: units
    }

    Rectangle {
        id: cardRect

        height: parent.height - (totalCount-1) * headingHeight
        width: parent.width
        x: 0
        y: finalY

        property int initialY: index * headingHeight
        property int finalY: (index == 0)?initialY:(cardRect.height + (index-1) * headingHeight)

        color: backgroundColor

        onYChanged: {
            cardHasMoved(index);
        }

        Text {
            id: textItem

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                leftMargin: units.fingerUnit
                rightMargin: units.fingerUnit
            }
            height: headingHeight

            color: headingColor
            padding: units.nailUnit
            font.bold: true
            font.pixelSize: fontSize
            verticalAlignment: Text.AlignVCenter

            text: headingText
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                openCard();
                cardSelected(index);
            }

            drag.target: parent
            drag.axis: Drag.YAxis
            drag.maximumY: parent.finalY
            drag.minimumY: parent.initialY
        }

        Loader {
            id: innerPageLoader

            property int index: navCardBase.index

            anchors {
                top: textItem.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                leftMargin: units.fingerUnit
                rightMargin: units.fingerUnit
            }


            //onLoaded: innerPageConnections.target = innerPageLoader.item
        }

        Connections {
            id: innerPageConnections

            target: innerPageLoader.item

            ignoreUnknownSignals: true

            onNewHeading: {
                console.log('new heading', heading)
                //headingText = heading;
            }

            onChangeHeading: {
            }
            onOpenCard: {
                console.log('opening::', page);
                navCardBase.openIndexedCard(index, page, pageProperties, cardProperties);
            }

            onConnectToNextCard: navCardBase.connectToNextCard(index, connections)
        }

    }

    function setSourceComponent(comp, properties) {
        innerPageLoader.sourceComponent = comp;
        for (var prop in properties) {
            innerPageLoader.item[prop] = properties[prop];
        }
    }

    function setPageSource(page, properties) {
        innerPageLoader.setSource("qrc:/modules/" + page + ".qml", properties);
    }

    function openCard() {
        // Propagate opening previous cards
        // and closing next cards

        cardRect.y = cardRect.initialY;

        cardHasMoved(index);
    }

    function closeCard() {
        // Propagate closing next cards
        // Previous cards remain in their current state

        navigator.closeNextCard(index);

        cardRect.y = cardRect.finalY;
    }
}
