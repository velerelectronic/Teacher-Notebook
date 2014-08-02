import QtQuick 2.2
import QtQuick.Controls 1.1

Rectangle {
    id: editor
    property string title: ''
    property bool editable: false
    signal updatedTitle(string newtitle)

    states: [
        State {
            name: 'show'
            PropertyChanges {
                target: editor
                height: mainItem.height + 2 * units.nailUnit
            }
            PropertyChanges {
                target: textEditor
                visible: false
            }
        },
        State {
            name: 'edit'
            PropertyChanges {
                target: editor
                height: mainItem.height + textEditor.height + 2 * units.nailUnit
            }
            PropertyChanges {
                target: textEditor
                visible: true
            }
        }
    ]
    state: 'show'
    clip: true

    border.color: 'gray'

    Item {
        id: mainItem
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: mainText.height
        anchors.margins: units.nailUnit
        Text {
            id: mainText
            anchors.left: parent.left
            anchors.right: (editor.editable)?deleteButton.left:parent.right
            anchors.top: parent.top
            height: Math.max(contentHeight,units.fingerUnit * 1.5)

            text: editor.title
            font.pixelSize: units.readUnit
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
        Button {
            id: deleteButton
            visible: editor.editable
            text: qsTr('Elimina')
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: units.nailUnit
        }
        MouseArea {
            enabled: editor.state == 'show'
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: (deleteButton.visible)?deleteButton.left:parent.right
            onClicked: {
                if (editor.editable) {
                    editor.state = 'edit';
                    textEditor.content = title;
                }
            }
            onPressAndHold: {
                editor.state = 'edit';
                textEditor.content = title;
            }
        }
    }

    TextAreaEditor {
        id: textEditor
        anchors.top: mainItem.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        onChangesAccepted: {
//            title = textEditor.content;
            editor.state = 'show';
            updatedTitle(textEditor.content);
        }
        onChangesCanceled: editor.state = 'show'
    }
}
