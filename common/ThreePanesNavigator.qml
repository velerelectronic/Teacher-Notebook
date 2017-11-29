import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import 'qrc:///common' as Common

Item {
    id: visibleNavigatorArea

    property Component firstPane
    property Component secondPane
    property Component thirdPane

    property int minimumFirstPaneHeight: units.fingerUnit * 2
    property int minimumSecondPaneHeight: units.fingerUnit * 4
    property int minimumThirdPaneHeight: units.fingerUnit * 8

    property int visibleFirstPaneHeight
    property int visibleSecondPaneHeight
    property int visibleThirdPaneHeight

    Common.UseUnits {
        id: units
    }

    ListView {
        id: flickArea

        anchors.fill: parent

        snapMode: ListView.SnapOneItem
        boundsBehavior: ListView.StopAtBounds

        model: ObjectModel {
            Rectangle {
                id: firstBlankArea

                width: flickArea.width
                height: firstPaneLoader.height
                color: '#FF0000'
            }
            Rectangle {
                id: secondBlankArea

                width: flickArea.width
                height: secondPaneLoader.height + minimumFirstPaneHeight
                color: '#FF5500'
            }
            Rectangle {
                id: thirdBlankArea

                width: flickArea.width
                height: thirdPaneLoader.height + minimumFirstPaneHeight + minimumSecondPaneHeight
                color: '#FFAA00'
            }
        }
    }

    Loader {
        id: firstPaneLoader

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: flickArea.height - minimumSecondPaneHeight

        z: 1

        sourceComponent: firstPane
    }

    Loader {
        id: secondPaneLoader

        anchors {
            left: parent.left
            right: parent.right
        }
        height: flickArea.height - minimumFirstPaneHeight - minimumThirdPaneHeight

        y: Math.max(minimumFirstPaneHeight, firstBlankArea.height - flickArea.contentY)

        z: 2

        sourceComponent: secondPane
    }

    Loader {
        id: thirdPaneLoader

        anchors {
            left: parent.left
            right: parent.right
        }
        height: flickArea.height - minimumFirstPaneHeight - minimumSecondPaneHeight

        y: Math.max(minimumFirstPaneHeight + minimumSecondPaneHeight, firstBlankArea.height + secondBlankArea.height - flickArea.contentY)

        z: 3

        sourceComponent: thirdPane
    }

    function setFirstPane(component) {
        firstPaneLoader.sourceComponent = component;
    }

    function setSecondPane(component) {
        secondPaneLoader.sourceComponent = component;
    }

    function setThirdPane(component) {
        thirdPaneLoader.sourceComponent = component;
    }

    function openPane(number) {
        flickArea.positionViewAtIndex(number-1, ListView.Beginning);
    }

    Component.onCompleted: {
        console.log('Three pane layout');
    }

}

