import QtQuick 2.7

Item {
    id: pointsDiagramItem

    property int dotsSize: 1
    property int maxDots: 10
    property int interSpacing: 0
    property string color: 'black'
    property int dotsNumber: 3

    Flow {
        anchors.fill: parent

        spacing: interSpacing

        Repeater {
            model: Math.min(dotsNumber, maxDots)

            Rectangle {
                width: dotsSize
                height: dotsSize
                color: pointsDiagramItem.color
            }
        }
    }
}

