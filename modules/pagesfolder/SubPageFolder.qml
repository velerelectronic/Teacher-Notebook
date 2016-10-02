import QtQuick 2.5
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

Item {
    id: subPageFolderItem

    signal closeRequested()
    property alias loader: subPageLoader
    property Item primarySource

    Common.UseUnits {
        id: units
    }

    states: [
        State {
            name: 'maximized'
            PropertyChanges {
                target: subPageRect
                scale: 1
                visible: true
            }
        },
        State {
            name: 'minimized'
            PropertyChanges {
                target: subPageRect
                scale: 0.25
                visible: true
            }
        },
        State {
            name: 'hidden'
            PropertyChanges {
                target: subPageRect
                visible: false
            }
        }

    ]
    state: 'hidden'

    Rectangle {
        id: subPageRect

        anchors.fill: parent

        transformOrigin: Item.BottomRight

        Behavior on scale {
            NumberAnimation {
                duration: 200
            }
        }

        color: 'white'

        Loader {
            id: subPageLoader
            anchors.fill: parent

            property string page: ''
            property string parameters: ''

            PageConnections {
                target: subPageLoader.item
                destination: subPageFolderItem
//                primarySource: subPageFolderItem.primarySource
            }

        }

        MouseArea {
            anchors.fill: parent
            enabled: subPageFolderItem.state !== 'maximized'
            onPressed: mouse.accepted = true
            onClicked: {
                subPageFolderItem.state = 'maximized'
            }
            onPressAndHold: closeRequested()
        }
    }

    Rectangle {
        border.color: 'black'
        color: 'transparent'
        anchors.fill: subPageRect
        anchors.leftMargin: subPageRect.width * (1 - subPageRect.scale)
        anchors.topMargin: subPageRect.height * (1 - subPageRect.scale)
        border.width: units.nailUnit / 2
        visible: subPageFolderItem.state == 'minimized'
    }

    function loadPage(page, param) {
        subPageLoader.page = page;
        subPageLoader.parameters = JSON.stringify(param);
        subPageLoader.setSource('qrc:///modules/' + page + '.qml', param);
        console.log('qrc:///modules/' + page + '.qml', param);
        subPageFolderItem.state = 'maximized';
    }

    function trytoLoadContents() {
        if (pageLoader.sourceComponent !== null) {
            if (pageLoader.item.changes)
                confirmDiscardChangesDialog.open();
        } else {
            pageLoader.appendToLastPages(pageLoader.page, pageLoader.page, pageLoader.parameters);
            pageLoader.loadContents();
        }

    }

}
