import QtQuick 2.0
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

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

    transitions: [
        Transition {
            PropertyAnimation {
                properties: 'color'
                easing.type: Easing.Linear
            }
        }
    ]

    property alias title: titleLabel.text
    property alias desc: descLabel.text
    signal annotationSelected (string title,string desc)

    border.color: "black";
    height: contents.height + units.nailUnit * 2

    Common.UseUnits { id: units }

    Item {
        id: contents
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: childrenRect.height + units.nailUnit
        anchors.margins: units.nailUnit

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            spacing: units.nailUnit
            Text {
                id: titleLabel
    //            anchors { left: parent.left; right: parent.right; margins: units.nailUnit }
                Layout.fillWidth: true
                Layout.preferredHeight: units.nailUnit * 2
                text: title
                font.bold: true
                font.pixelSize: units.nailUnit * 2
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                clip: true
            }
            Text {
                id: descLabel
    //            anchors { left: parent.left; right: parent.right; margins: units.nailUnit }
                Layout.fillWidth: true
                Layout.preferredHeight: units.nailUnit
                text: desc
                font.pixelSize: units.nailUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                clip: true
            }

        }
    }

    MouseArea {
        anchors.fill: contents
        onClicked: annotationItem.annotationSelected(annotationItem.title, annotationItem.desc)
    }
}
