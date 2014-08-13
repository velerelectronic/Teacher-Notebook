import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

Rectangle {
    id: inboxElement

    property int closedSize: units.fingerUnit
    property int openedSize: units.fingerUnit * 5
    signal savedQuickAnnotation(string contents)

    states: [
        State {
            name: 'closed'
            PropertyChanges {
                target: inboxElement
                height: closedSize
            }
            PropertyChanges {
                target: editColumn
                visible: false
            }
        },
        State {
            name: 'write'
            PropertyChanges {
                target: inboxElement
                height: openedSize
            }
            PropertyChanges {
                target: editColumn
                visible: true
            }
            PropertyChanges {
                target: contentsArea
                focus: true
            }
        },
        State {
            name: 'photo'
            PropertyChanges {
                target: inboxElement
                height: openedSize
            }
            PropertyChanges {
                target: editColumn
                visible: true
            }
        },
        State {
            name: 'sound'
            PropertyChanges {
                target: inboxElement
                height: openedSize
            }
            PropertyChanges {
                target: editColumn
                visible: true
            }
        }
    ]
    state: 'closed'

    color: 'yellow'
    border.color: 'black'
    radius: closedSize / 2

    Text {
        id: basicMenu
        anchors.centerIn: parent
        text: qsTr('Anotació ràpida')
        visible: inboxElement.state == 'closed'
    }

    MouseArea {
        anchors.fill: parent
        onClicked: inboxElement.state = 'write'
    }

    ColumnLayout {
        id: editColumn

        anchors.fill: parent
        anchors.margins: units.fingerUnit / 2
        spacing: units.nailUnit

        RowLayout {
            Layout.preferredHeight: units.fingerUnit * 1.5

            Common.Button {
                Layout.fillHeight: true
                text: 'Escriu'
                color: '#FF9999'
                onClicked: inboxElement.state = 'write'
            }
            Common.Button {
                Layout.fillHeight: true
                text: 'Fotografia'
                color: '#99FF99'
                onClicked: inboxElement.state = 'photo'
            }
            Common.Button {
                Layout.fillHeight: true
                text: 'Veu'
                color: '#9999FF'
                onClicked: inboxElement.state = 'sound'
            }
            Item {
                Layout.fillWidth: true
            }
        }

        TextArea {
            id: contentsArea
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 1.5
            Item {
                Layout.fillWidth: true
            }

            Button {
                Layout.fillHeight: true
                text: qsTr('Desa')
                onClicked: {
                    savedQuickAnnotation(contentsArea.text);
                    inboxElement.state = 'closed';
                }
            }
            Button {
                Layout.fillHeight: true
                text: qsTr('Cancel·la')
                onClicked: inboxElement.state = 'closed'
            }
        }
    }

    function annotationWasSaved() {
        contentsArea.text = "";
    }
}
