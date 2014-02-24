import QtQuick 2.0
import QtQuick.Layouts 1.1

Rectangle {
    id: annotationItem
    state: 'basic'
    states: [
        State {
            name: 'basic'
            PropertyChanges { target: annotationItem; color: 'white' }
        },
        State {
            name: 'selected'
            PropertyChanges { target: annotationItem; color: 'grey' }
        }
    ]

    property alias title: titleLabel.text
    property alias desc: descLabel.text
    property int esquirolGraphicalUnit: 100
    signal annotationSelected (string title,string desc)

    border.color: "black";
    height: childrenRect.height

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        height: childrenRect.height
        Text {
            id: titleLabel
            anchors { left: parent.left; right: parent.right; margins: 10 }
            text: title
            font.bold: true
            font.pointSize: 18
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            clip: true
        }
        Text {
            id: descLabel
            anchors { left: parent.left; right: parent.right; margins: 10 }
            text: desc
            font.pointSize: 12
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            clip: true
        }

    }

    MouseArea {
        anchors.fill: parent
        onClicked: annotationItem.annotationSelected(annotationItem.title, annotationItem.desc)
    }
}
