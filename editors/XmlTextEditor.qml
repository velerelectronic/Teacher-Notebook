import QtQuick 2.2

Rectangle {
    id: editor
    property string title: ''
    signal updatedTitle(string newtitle)

    states: [
        State {
            name: 'show'
            PropertyChanges {
                target: editor
                height: Math.max(mainText.height + 2 * units.nailUnit, units.fingerUnit * 1.5)
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
                height: mainText.height + textEditor.height + 2 * units.nailUnit
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
    Text {
        id: mainText
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: contentHeight
        anchors.margins: units.nailUnit

        text: editor.title
        font.pixelSize: units.readUnit
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (editor.state == 'show') {
                    editor.state = 'edit';
                    textEditor.content = title;
                } else {
                    editor.state = 'show';
                }
            }
        }
    }
    TextAreaEditor {
        id: textEditor
        anchors.top: mainText.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        onChangesAccepted: {
            title = textEditor.content;
            editor.state = 'show';
            updatedTitle(title);
        }
        onChangesCanceled: editor.state = 'show'
    }
    Component.onCompleted: {
        console.log("Titol " + editor.title);
        console.log(height);
    }
}
