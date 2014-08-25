import QtQuick 2.2

ListView {
    id: list
    property int fromNumber: -1
    property int toNumber
    property real itemHeight: units.fingerUnit

    model: toNumber-fromNumber+1
    clip: true
    highlightRangeMode: ListView.StrictlyEnforceRange
    preferredHighlightBegin: list.height / 2 - itemHeight / 2
    preferredHighlightEnd: list.height / 2 + itemHeight / 2

    delegate: Rectangle {
        width: list.width
        height: units.fingerUnit
//        border.color: 'black'
        color: ListView.isCurrentItem?'yellow':'white'
        Text {
            anchors.centerIn: parent
            text: (fromNumber == -1)?model.modelData:(model.modelData+fromNumber)
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                list.currentIndex = model.index;
            }
        }
    }
    keyNavigationWraps: true

    function moveToNumber(number) {
        positionViewAtIndex(number,ListView.Center);
    }
}
