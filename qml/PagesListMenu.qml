import QtQuick 2.2

Rectangle {
    id: pagesList

    property int readUnit
    property int menuWidth
    property int sectionsHeight: units.fingerUnit * 2
    property int durationEffect
    property alias model: list.model
    property int textMargins: units.nailUnit
    signal pageSelected(int index)
    signal pageCloseRequested(int index)

    states: [
        State {
            name: 'hidden'
            PropertyChanges {
                target: pagesList
                width: 0
            }
        },
        State {
            name: 'show'
            PropertyChanges {
                target: pagesList
                width: menuWidth
            }
        }
    ]
    state: 'hidden'
    Behavior on width {
        NumberAnimation {
            duration: durationEffect
        }
    }

    color: 'white'
    clip: true

    ListView {
        id: list
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: menuWidth

        delegate: Rectangle {
            height: sectionsHeight
            width: parent.width
            Text {
                anchors.fill: parent
                anchors.margins: textMargins
                font.pixelSize: readUnit
                text: model.pageTitle
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
            }
            MouseArea {
                anchors.fill: parent
                onClicked: pageSelected(model.index)
                onPressAndHold: pageCloseRequested(model.index)
            }
        }
    }

    function switchState() {
        pagesList.state = (pagesList.state == 'hidden')?'show':'hidden';
    }

}
