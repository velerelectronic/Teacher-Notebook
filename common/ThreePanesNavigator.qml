import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import 'qrc:///common' as Common

Item {
    id: visibleNavigatorArea

    property Component firstPane: Rectangle { color: '#FFFFFF' }
    property Component secondPane: Rectangle { color: '#AAAAAA' }
    property Component thirdPane: Rectangle { color: '#555555' }

    property int minimumFirstPaneHeight: units.fingerUnit * 2
    property int minimumSecondPaneHeight: units.fingerUnit * 2
    property int minimumThirdPaneHeight: units.fingerUnit * 2

    property alias firstPaneItem: firstPaneLoader.item
    property alias secondPaneItem: secondPaneLoader.item
    property alias thirdPaneItem: thirdPaneLoader.item

    property int visibleFirstPaneHeight
    property int visibleSecondPaneHeight
    property int visibleThirdPaneHeight


    Common.UseUnits {
        id: units
    }

    state: 'first'

    states: [
        State {
            name: 'interstate'
        },
        State {
            name: 'first'
            PropertyChanges {
                target: secondPaneLoader
                y: visibleNavigatorArea.height - minimumSecondPaneHeight
            }
            PropertyChanges {
                target: thirdPaneLoader
                y: secondPaneLoader.y + secondPaneLoader.height
            }
        },
        State {
            name: 'second'
            PropertyChanges {
                target: secondPaneLoader
                y: minimumFirstPaneHeight
            }
            PropertyChanges {
                target: thirdPaneLoader
                y: visibleNavigatorArea.height - minimumThirdPaneHeight
            }
        },
        State {
            name: 'third'
            PropertyChanges {
                target: secondPaneLoader
                y: minimumFirstPaneHeight
            }
            PropertyChanges {
                target: thirdPaneLoader
                y: minimumFirstPaneHeight + minimumSecondPaneHeight
            }
        }
    ]

    transitions: [
        Transition {
            PropertyAnimation {
                property: 'y'
                duration: 100
            }
        }

    ]
    Loader {
        id: firstPaneLoader

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: visibleNavigatorArea.height - minimumSecondPaneHeight

        z: 1

        sourceComponent: firstPane

        Connections {
            target: firstPaneLoader.item

            ignoreUnknownSignals: true

            onHeadingSelected: openPane('first')
        }
    }

    Loader {
        id: secondPaneLoader

        anchors {
            left: parent.left
            right: parent.right
        }
        height: visibleNavigatorArea.height - minimumFirstPaneHeight - minimumThirdPaneHeight

        z: 2

        sourceComponent: secondPane

        MouseArea {
            anchors.fill: parent

            drag.target: parent
            drag.axis: Drag.YAxis
            drag.minimumY: minimumFirstPaneHeight
            drag.maximumY: visibleNavigatorArea.height - minimumSecondPaneHeight
        }

        Connections {
            target: secondPaneLoader.item

            ignoreUnknownSignals: true

            onHeadingSelected: openPane('second')
        }
    }

    Loader {
        id: thirdPaneLoader

        anchors {
            left: parent.left
            right: parent.right
        }
        height: visibleNavigatorArea.height - minimumFirstPaneHeight - minimumSecondPaneHeight

        z: 3

        sourceComponent: thirdPane

        MouseArea {
            anchors.fill: parent

            drag.target: parent
            drag.axis: Drag.YAxis
            drag.minimumY: minimumFirstPaneHeight + minimumSecondPaneHeight
            drag.maximumY: visibleNavigatorArea.height - minimumThirdPaneHeight
        }

        Connections {
            target: thirdPaneLoader.item

            ignoreUnknownSignals: true

            onHeadingSelected: openPane('third')
        }
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

    function openPane(newstate) {
        visibleNavigatorArea.state = 'interstate';
        visibleNavigatorArea.state = newstate;
    }

    function setFirstPaneSource(url, properties, paneProps) {
        for (var prop in paneProps) {
            firstPaneLoader.item[prop] = paneProps[prop];
        }

        return firstPaneLoader.item.setSource('qrc:/modules/' + url + '.qml', properties);
    }

    function setSecondPaneSource(url, properties, paneProps) {
        for (var prop in paneProps) {
            secondPaneLoader.item[prop] = paneProps[prop];
        }

        return secondPaneLoader.item.setSource('qrc:/modules/' + url + '.qml', properties);
    }

    function setThirdPaneSource(url, properties, paneProps) {
        for (var prop in paneProps) {
            thirdPaneLoader.item[prop] = paneProps[prop];
        }

        return thirdPaneLoader.item.setSource('qrc:/modules/' + url + '.qml', properties);

    }

}

