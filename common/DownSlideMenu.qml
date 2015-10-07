import QtQuick 2.5

Item {
    id: downSlideMenu

    property int initialHeight: 0
    property Component menu

    states: [
        State {
            name: 'hidden'
            PropertyChanges {
                target: flickArea
                enabled: false
            }
            PropertyChanges {
                target: shadow
                opacity: 0
            }
            PropertyChanges {
                target: emptyArea
                height: flickArea.height
            }
            PropertyChanges {
                target: flickArea
                contentY: 0
            }
        },
        State {
            name: 'showHeading'
            PropertyChanges {
                target: flickArea
                enabled: true
            }
            PropertyChanges {
                target: shadow
                opacity: 0.5
            }
            PropertyChanges {
                target: menuLoader
                height: menuLoader.requiredHeight
            }
            PropertyChanges {
                target: emptyArea
                height: flickArea.height - downSlideMenu.initialHeight
            }
            PropertyChanges {
                target: flickArea
                contentY: 0
            }
        },
        State {
            name: 'showBody'

            PropertyChanges {
                target: downSlideMenu
                visible: true
            }
            PropertyChanges {
                target: emptyArea
                height: flickArea.height - downSlideMenu.initialHeight
            }
        }
    ]

    state: 'hidden'

    transitions: [
        Transition {
            NumberAnimation {
                target: shadow
                properties: 'opacity'
            }
            NumberAnimation {
                target: emptyArea
                properties: 'height'
            }
            NumberAnimation {
                target: flickArea
                properties: 'contentY'
            }
        }
    ]

    Rectangle {
        id: shadow

        anchors.fill: parent

        color: 'black'
    }

    Flickable {
        id: flickArea

        anchors.fill: parent

        boundsBehavior: Flickable.StopAtBounds

        contentWidth: width
        contentHeight: flickItem.height
//        topMargin: parent.height - parent.initialHeight
//        contentY: -topMargin

        Item {
            id: flickItem
            width: parent.width
            height: emptyArea.height + menuLoader.height

            MouseArea {
                id: emptyArea
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                onClicked: downSlideMenu.state = 'hidden'
            }
            Loader {
                id: menuLoader
                anchors {
                    top: emptyArea.bottom
                    left: parent.left
                    right: parent.right
                }
                height: ((item !== null) && (typeof item.requiredHeight === 'number'))?(item.requiredHeight):0

                sourceComponent: downSlideMenu.menu

                Connections {
                    target: menuLoader.item
                    onCloseMenu: {
                        downSlideMenu.state = 'hidden';
                    }
                }
            }

        }

    }
}
