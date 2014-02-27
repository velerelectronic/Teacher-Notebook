import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import 'common' as Common

Rectangle {
    id: annotationEditor
    width: 300
    height: 200

    property alias title: title.text
    property alias desc: contents.text
    property int globalMargin: 10
    signal saveAnnotation(string title, string desc)
    signal cancelAnnotation

    Common.UseUnits { id: units }

    border.color: 'green'
    anchors.margins: units.fingerUnit

    MouseArea {
        // Intercept clicks
        anchors.fill: parent
        onClicked: { mouse.accepted = true }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit

        Rectangle {
            anchors.margins: units.nailUnit
            Layout.preferredHeight: childrenRect.height
            Layout.fillWidth: true
            border.color: 'green'

            TextInput {
                id: title
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: units.nailUnit * 2
                inputMethodHints: Qt.ImhNoPredictiveText
                clip: true
            }
        }
        ToolBar {
            id: toolbar
            Layout.fillWidth: true
            anchors.margins: units.nailUnit

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
                    text: qsTr('Copia')
                    onClicked: contents.copy()
                }
                ToolButton {
                    text: qsTr('Enganxa')
                    onClicked: contents.paste()
                }
                ToolButton {
                    text: qsTr('Retalla')
                    onClicked: contents.cut()
                }
                ToolButton {
                    text: qsTr('Desfer')
                    onClicked: contents.undo()
                }
                ToolButton {
                    text: qsTr('Refer')
                    onClicked: contents.redo()
                }
                ToolButton {}

                ToolButton {
                    text: qsTr('Desa')
                    onClicked: annotationEditor.saveAnnotation(title.text,contents.text)
                }
                ToolButton {
                    text: qsTr('Cancela')
                    onClicked: annotationEditor.cancelAnnotation()
                }
            }
        }

        TextArea {
            id: contents
            Layout.fillHeight: true
            Layout.fillWidth: true
            anchors.margins: units.nailUnit
            font.pixelSize: units.nailUnit * 2
            inputMethodHints: Qt.ImhNoPredictiveText
        }
    }
}
