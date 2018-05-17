import QtQuick 2.7

Generic {
    requiredHeight: 100
    requiredWidth: 100

    Rectangle {
        anchors.fill: parent

        border.color: 'black'
        color: 'red'
    }

    Component.onCompleted: {
        console.log('MarkDown NONE');
    }
}
