import QtQuick 2.0

Rectangle {
    id: messageBox
    height: message.height + internalMargins * 2

    property alias interval: messageTimer.interval
    property int fontSize: 0
    property int internalMargins: 0

    states: [
        State {
            name: 'hidden'
            PropertyChanges { target: messageBox; opacity: 0 }
        },
        State {
            name: 'shown'
            PropertyChanges { target: messageBox; opacity: 1 }
        }
    ]
    state: 'hidden'
    transitions: [
        Transition {
            PropertyAnimation {
                properties: 'opacity'
                easing.type: Easing.Linear
            }
        }
    ]

    Text {
        id: message
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: messageBox.internalMargins
        font.pixelSize: messageBox.fontSize
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }
    Timer {
        id: messageTimer
        interval: messageBox.interval
        onTriggered: messageBox.state = 'hidden'
    }

    function publishMessage(text) {
        messageTimer.restart();
        if (messageBox.state == 'hidden') {
            message.text = text;
            messageBox.state = 'shown';
        } else {
            message.text += '\n' + text;
        }
    }

}
