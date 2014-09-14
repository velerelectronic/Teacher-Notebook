import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common

Common.AbstractEditor {
    id: editor
    property string title: ''
    property bool editable: false
    signal updatedTitle(string newtitle)
    signal eraseContent()
    signal moveToPrevious()
    signal moveToNext()

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
            anchors.right: (editor.editable)?buttons.left:parent.right
            anchors.top: parent.top
            height: Math.max(contentHeight,units.fingerUnit * 1.5)

            text: editor.title
            font.pixelSize: units.readUnit
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
        RowLayout {
            id: buttons
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: units.nailUnit

            visible: editor.editable
            Button {
                Layout.fillHeight: true
                text: qsTr('Amunt')
                onClicked: moveToPrevious()
            }
            Button {
                Layout.fillHeight: true
                text: qsTr('Avall')
                onClicked: moveToNext()
            }
            Button {
                Layout.fillHeight: true
                text: qsTr('Elimina')
                onClicked: eraseDialog.open()
            }
        }

        MouseArea {
            enabled: editor.state == 'show'
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: (buttons.visible)?buttons.left:parent.right
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
            editor.setChanges(true);
        }
        onChangesCanceled: editor.state = 'show'
    }

    MessageDialog {
        id: eraseDialog
        standardButtons: StandardButton.Ok | StandardButton.No
        text: qsTr('Eliminar «' + editor.title + '»')
        informativeText: qsTr("S'eliminarà «" + editor.title + "». Vols continuar?");
        onAccepted: eraseContent()
        onDiscard: eraseDialog.visible = false
    }
}
