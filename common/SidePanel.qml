import QtQuick 2.2

Item {
    id: wholePanel
    property alias mainItem: panelItem.children

    property string side: ''
    property bool isVertical: (wholePanel.side == 'T') || (wholePanel.side == 'B')

    property alias panelHeight: bottomPanel.contentHeight
    property alias panelWidth: bottomPanel.contentWidth

    Rectangle {
        id: shadow
        anchors.fill: parent

        property real shownWidth: (bottomPanel.contentX>=0)?(panelWidth - bottomPanel.contentX):(width + bottomPanel.contentX)
        property real shownHeight: (bottomPanel.contentY>=0)?(panelHeight - bottomPanel.contentY):(height + bottomPanel.contentY)

        color: 'black'
        opacity: 0.5 * ((isVertical)?(shadow.shownHeight/panelHeight):(shadow.shownWidth/panelWidth))
    }

    Flickable {
        id: bottomPanel

        interactive: false
        anchors.fill: parent

        topMargin: (wholePanel.side == 'B')?height:0
        bottomMargin: (wholePanel.side == 'T')?height:0
        leftMargin: (wholePanel.side == 'R')?width:0
        rightMargin: (wholePanel.side == 'L')?width:0

        flickableDirection: (isVertical)?Flickable.VerticalFlick:Flickable.HorizontalFlick
        contentHeight: height
        contentWidth: width
        boundsBehavior: Flickable.StopAtBounds

        contentX: rightMargin
        contentY: -topMargin+bottomMargin

        Item {
            id: panelItem
            height: bottomPanel.contentHeight
            width: bottomPanel.contentWidth
        }
    }
}

