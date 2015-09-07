import QtQuick 2.0
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

Rectangle {
    id: annotationItem
    state: 'basic'
    states: [
        State {
            name: 'basic'
            PropertyChanges {
                target: annotationItem
                color: 'white'
                height: units.fingerUnit * 2
            }
        },
        State {
            name: 'selected'
            PropertyChanges {
                target: annotationItem
                color: 'grey'
                height: units.fingerUnit * 2
            }
        },
        State {
            name: 'expanded'
            PropertyChanges {
                target: annotationItem
                color: 'white'
                height: contents.height + units.nailUnit * 2
            }
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
    property alias image: imageLabel.source
    property string labels: ''

    property bool isSelected: false

    signal annotationSelected (string title,string desc)
    signal annotationLongSelected(string title,string desc)

    border.color: "black";

    Common.UseUnits { id: units }

    clip: true

    Behavior on height {
        NumberAnimation {
            duration: 200
        }
    }

    ColumnLayout {
        id: contents
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: units.nailUnit
        height: childrenRect.height //+ 2 * spacing

        spacing: units.nailUnit

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(titleLabel.height,eventsLabel.height,labelsLabel.height)

            RowLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }
                spacing: units.nailUnit

                Text {
                    id: titleLabel
        //            anchors { left: parent.left; right: parent.right; margins: units.nailUnit }
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    text: title
                    font.bold: true
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    clip: true
                }

                Text {
                    id: eventsLabel
                    Layout.preferredWidth: contents.width / 4
                    Layout.fillHeight: true
                    clip: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: 'red'
                    font.pixelSize: units.readUnit
                    text: (model.events>0)?model.events+qsTr(" esdeveniments"):''
                }

                Text {
                    id: resourcesLabel
                    Layout.preferredWidth: contents.width / 4
                    Layout.fillHeight: true
                    clip: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: 'red'
                    font.pixelSize: units.readUnit
                    text: (model.resources>0)?model.resources+qsTr(" recursos"):''
                }

                Text {
                    id: labelsLabel
                    Layout.preferredWidth: contents.width / 4
                    Layout.fillHeight: true
                    clip: true
                    text: labels
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: 'green'
                    font.pixelSize: units.readUnit
                }
            }
        }

        Text {
            id: descLabel
//            anchors { left: parent.left; right: parent.right; margins: units.nailUnit }
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            text: desc
            font.pixelSize: units.readUnit
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            clip: true
        }

        Image {
            id: imageLabel
            Layout.fillWidth: true
            Layout.preferredHeight: sourceSize.height * (width / sourceSize.width)
            source: image
            fillMode: Image.PreserveAspectFit
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: annotationItem.annotationSelected(annotationItem.title, annotationItem.desc)
        onPressAndHold: annotationItem.annotationLongSelected(annotationItem.title, annotationItem.desc)
    }

    Common.ExtraInfo {
        minHeight: units.fingerUnit * 2
        contentHeight: contents.height + units.nailUnit * 2
        available: annotationItem.state == 'basic'
    }
}
