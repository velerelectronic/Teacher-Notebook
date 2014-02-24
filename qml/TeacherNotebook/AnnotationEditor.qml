import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

Rectangle {
    id: annotationEditor
    width: 300
    height: 200

    property alias title: title.text
    property int esquirolGraphicalUnit: 100
    property alias desc: contents.text
    property int globalMargin: 10
    signal saveAnnotation(string title, string desc)
    signal cancelAnnotation

    border.color: 'green'

    Item {
        anchors.fill: parent
        anchors.margins: globalMargin * 2

        Rectangle {
            id: titleRect
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: globalMargin
            height: childrenRect.height
            border.color: 'green'

            TextInput {
                id: title
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                font.pointSize: 20
                inputMethodHints: Qt.ImhNoPredictiveText
            }
        }
        ToolBar {
            id: toolbar
            anchors.top: titleRect.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: globalMargin
            anchors.bottomMargin: 0

            RowLayout {
                ToolButton {
                    text: 'Predictive'
                    checkable: true
                    onClicked: {
                        if (checked) {
                            contents.inputMethodHints = Qt.ImhNone
                            title.inputMethodHints = Qt.ImhNone
                        } else {
                            contents.inputMethodHints = Qt.ImhNoPredictiveText
                            title.inputMethodHints = Qt.ImhNoPredictiveText
                        }
                    }
                }

                ToolButton {
                    text: 'Copia'
                    onClicked: contents.copy()
                }
                ToolButton {
                    text: 'Enganxa'
                    onClicked: contents.paste()
                }
                ToolButton {
                    text: 'Retalla'
                    onClicked: contents.cut()
                }
                ToolButton {
                    text: 'Desfer'
                    onClicked: contents.undo()
                    visible: false
                }
                ToolButton {
                    text: 'Refer'
                    onClicked: contents.redo()
                }
            }
        }

        TextArea {
            id: contents
            anchors.top: toolbar.bottom
            anchors.bottom: buttons.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: globalMargin
            anchors.topMargin: 0
            font.pointSize: 20
            inputMethodHints: Qt.ImhNoPredictiveText
        }
        Row {
            id: buttons
            anchors.bottom: parent.bottom
            height: childrenRect.height
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: globalMargin
            Button {
                text: qsTr('Desa')
                onClicked: annotationEditor.saveAnnotation(title.text,contents.text)
            }
            Button {
                text: qsTr('Cancela')
                onClicked: annotationEditor.cancelAnnotation()
            }
        }

    }

}
