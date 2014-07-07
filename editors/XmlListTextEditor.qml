import QtQuick 2.2

Rectangle {
    id: editor
    property alias title: mainText.text

    states: [
        State {
            name: 'show'
            PropertyChanges {
                target: editor
                height: mainText.height + 2 * units.nailUnit
            }
        },
        State {
            name: 'edit'
            PropertyChanges {
                target: editor
                height: mainText.height + textEditor.height + 2 * units.nailUnit
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

        font.pixelSize: units.readUnit
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

        MouseArea {
            anchors.fill: parent
            onClicked: (editor.state === 'show')?'edit':'show'
        }
    }
    TextAreaEditor {
        id: textEditor
        anchors.top: mainText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }
}
