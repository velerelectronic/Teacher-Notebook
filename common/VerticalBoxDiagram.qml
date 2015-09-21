import QtQuick 2.0

Item {
    property int value
    property int minimum: 1
    property int maximum: 10
    property alias boxColor: box.color
    property Component legend

    Rectangle {
        id: box
        color: 'red'
        anchors {
            left: parent.left
            right: parent.right
        }
        property int divisions: maximum-minimum+1
        height: parent.height / box.divisions
        y: parent.height - (value - minimum + 1) * box.height
        Loader {
            anchors.fill: parent
            sourceComponent: legend
        }
    }
}

