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
    property alias verticalHeadingModel: verticalHeading.model
    property alias verticalHeadingDelegate: verticalHeading.delegate

    property alias mainTabularItem: tableItem.children
    property alias mainTabularItemHeight: tableItem.height
    property alias mainTabularItemWidth: tableItem.width

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
                tableItem.contentX = contentX;
            }
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
                tableItem.contentY = contentY;
            }
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

        Item {
            id: tableItem
            height: tableItemFlickable.contentHeight
            width: tableItemFlickable.contentWidth
        }

        onContentHeightChanged: {
            console.log('content height ' + contentHeight)
        }

        onContentWidthChanged: {
            console.log('content width ' + contentWidth)
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
}
