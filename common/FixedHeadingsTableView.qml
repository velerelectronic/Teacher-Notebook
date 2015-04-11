import QtQuick 2.3
import QtQuick.Layouts 1.1

GridLayout {
    id: mainGrid
    rows: 2
    columns: 2
    columnSpacing: headingsSpacing
    rowSpacing: headingsSpacing

    property int horizontalHeadingHeight
    property int verticalHeadingWidth
    property int headingsSpacing
    property alias crossHeadingItem: crossItem.children
    property alias horizontalHeadingModel: horizontalHeading.model
    property alias horizontalHeadingDelegate: horizontalHeading.delegate
    property alias horizontalHeadingHighlight: horizontalHeading.highlight
    property alias verticalHeadingModel: verticalHeading.model
    property alias verticalHeadingDelegate: verticalHeading.delegate
    property alias verticalHeadingHighlight: verticalHeading.highlight
    property alias verticalHeadingFooter: verticalHeading.footer

    property alias currentHorizontalIndex: horizontalHeading.currentIndex
    property alias currentVerticalIndex: verticalHeading.currentIndex

    property alias mainTabularItem: tableItem.children
    property alias mainTabularItemHeight: tableItem.height
    property alias mainTabularItemWidth: tableItem.width
    property int highlightMoveDuration: 250

    Item {
        id: crossItem
        Layout.preferredHeight: horizontalHeadingHeight
        Layout.preferredWidth: verticalHeadingWidth
    }

    ListView {
        id: horizontalHeading
        Layout.fillWidth: true
        Layout.preferredHeight: horizontalHeadingHeight
        orientation: ListView.Horizontal
        clip: true

        onContentXChanged: {
            if (movingHorizontally) {
                tableItemFlickable.contentX = contentX;
            }
        }
        highlightMoveDuration: mainGrid.highlightMoveDuration

        Rectangle {
            color: 'white'
            anchors.fill: horizontalHeading.contentItem
            z: -100
        }
    }

    ListView {
        id: verticalHeading
        Layout.fillHeight: true
        Layout.preferredWidth: verticalHeadingWidth
        orientation: ListView.Vertical
        clip: true

        onContentYChanged: {
            if (movingVertically) {
                tableItemFlickable.contentY = contentY;
            }
        }
        highlightMoveDuration: mainGrid.highlightMoveDuration

        Rectangle {
            color: 'white'
            anchors.fill: verticalHeading.contentItem
            z: -100
        }
    }
    Flickable {
        id: tableItemFlickable
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        contentHeight: verticalHeading.contentItem.height
        contentWidth: horizontalHeading.contentItem.width
        interactive: true

        Rectangle {
            id: tableItem
            color: 'white'
            height: tableItemFlickable.contentHeight
            width: tableItemFlickable.contentWidth
        }

        onContentXChanged: {
            if (movingHorizontally) {
                horizontalHeading.contentX = contentX;
            }
        }

        onContentYChanged: {
            if (movingVertically) {
                verticalHeading.contentY = contentY;
            }
        }
    }

    function changeCurrentHorizontalIndex(index) {
        if (horizontalHeading.currentIndex !== index)
            horizontalHeading.currentIndex = index;
        else
            horizontalHeading.currentIndex = -1;
    }

    function changeCurrentVerticalIndex(index) {
        if (verticalHeading.currentIndex !== index)
            verticalHeading.currentIndex = index;
        else
            verticalHeading.currentIndex = -1;
    }
}
