import QtQuick 2.0

Rectangle {
    id: arisenWidget

    signal close

    anchors.fill: parent
    color: "gray"
    opacity: 0.5

    MouseArea {
        anchors.fill: parent
        onClicked: arisenWidget.close()
    }
}
