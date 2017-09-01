import QtQuick 2.6
import QtQuick.Layouts 1.3

Rectangle {
    id: insideEditorItem

    signal accepted()
    signal cancelled()

    signal editorLoaded()

    property alias item: subItemPlace.item

    clip: true

    states: [
        State {
            name: 'shown'

            PropertyChanges {
                target: insideEditorItem
                visible: true
            }
        },
        State {
            name: 'hidden'

            PropertyChanges {
                target: insideEditorItem
                visible: false
                width: 0
                height: 0
            }
        }
    ]
    state: 'hidden'

    UseUnits {
        id: units
    }
    border.color: 'black'

    ColumnLayout {
        anchors.fill: parent

        Loader {
            id: subItemPlace
            Layout.fillHeight: true
            Layout.fillWidth: true

            onLoaded: editorLoaded()
        }

        Item {
            Layout.preferredHeight: units.fingerUnit * 2
            Layout.fillWidth: true
            RowLayout {
                anchors.fill: parent

                Button {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    text: qsTr('Accepta')

                    color: 'green'
                    fontSize: units.readUnit

                    onClicked: accepted()
                }

                TextButton {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: qsTr('Cancela')

                    color: 'red'
                    fontSize: units.readUnit
                    onClicked: cancelled()
                }
            }
        }
    }

    function open() {
        state = 'shown';
    }

    function close() {
        state = 'hidden';
    }

    function setComponent(component, args) {
        subItemPlace.sourceComponent = component;
        for (var prop in args) {
            subItemPlace.item[prop] = args[prop];
        }
    }

    function loadComponent(source, args) {
        subItemPlace.setSource('qrc:///modules/' + source + ".qml", args);
    }

    function getContent() {
        return subItemPlace.item.content;
    }
}
