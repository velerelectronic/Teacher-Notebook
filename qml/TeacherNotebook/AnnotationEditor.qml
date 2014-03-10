import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import 'common' as Common
import 'Storage.js' as Storage

Rectangle {
    id: annotationEditor
    property string pageTitle: qsTr("Editor d'anotacions")

    width: 300
    height: 200

    property int idAnnotation: -1
    property alias annotation: title.text
    property alias desc: contents.text

    signal savedAnnotation(string annotation, string desc)
    signal canceledAnnotation

    Common.UseUnits { id: units }

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
                    text: qsTr('Edita')
                    onClicked: editMenu.popup()
                }
                Menu {
                    id: editMenu
                    title: qsTr('Edició')
                    MenuItem {
                        text: qsTr('Copia')
                        onTriggered: contents.copy()
                    }
                    MenuItem {
                        text: qsTr('Retalla')
                        onTriggered: contents.cut()
                    }
                    MenuItem {
                        text: qsTr('Enganxa')
                        onTriggered: contents.paste()
                    }
                    MenuSeparator {}
                    MenuItem {
                        text: qsTr('Refer')
                        onTriggered: contents.redo()
                    }
                    MenuItem {
                        text: qsTr('Desfer')
                        onTriggered: contents.undo()
                    }
                }

                ToolButton {
                    enabled: false
                }

                ToolButton {
                    text: qsTr('Desa')
                    onClicked: {
                        Qt.inputMethod.hide()
                        Storage.saveAnnotation(annotation,desc);
                        annotationEditor.savedAnnotation(annotation,desc);
                    }
                }
                ToolButton {
                    text: qsTr('Cancela')
                    onClicked: {
                        Qt.inputMethod.hide();
                        annotationEditor.close();
                    }
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
    function close() {
        if (annotationEditor.state != 'closing') {
            annotationEditor.state = 'closing';
            annotationEditor.canceledAnnotation();
            return false;
        } else {
            return true;
        }
    }

    Component.onCompleted: {
        if (annotationEditor.idAnnotation != -1) {
            var details = Storage.getDetailsAnnotationId(annotationEditor.idAnnotation);
            console.log('Details ' + JSON.stringify(details));
            annotationEditor.annotation = details.title;
            annotationEditor.desc = details.desc;
        }
    }
}
