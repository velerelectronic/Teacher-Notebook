import QtQuick 2.0

Rectangle {
    id: planningCollector

    ListView {
        id: planningList
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: units.fingerUnit
    }

    Loader {
        anchors {
            top: planningList.bottom
            bottom: parent.bottom
            right: parent.right
            left: parent.left
        }
    }
}

