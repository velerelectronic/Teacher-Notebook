import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import 'common' as Common
import 'Storage.js' as Storage

Common.AbstractEditor {
    id: annotationEditor
    property string pageTitle: qsTr("Editor d'anotacions")

    width: 300
    height: 200

    property int idAnnotation: -1
    property alias annotation: title.text
    property alias desc: contents.text

    signal savedAnnotation(string annotation, string desc)
    signal canceledAnnotation(bool changes)

    Common.UseUnits { id: units }

    MouseArea {
        // Intercept clicks
        anchors.fill: parent
        onClicked: { mouse.accepted = true }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit
        spacing: units.nailUnit

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
                onTextChanged: annotationEditor.setChanges(true)
            }
        }

        Common.TextAreaEditor {
            id: contents
            Layout.fillHeight: true
            Layout.fillWidth: true
            fontPixelSize: units.nailUnit * 2
            toolHeight: units.fingerUnit
            buttonMargins: units.nailUnit
            onTextChanged: annotationEditor.setChanges(true)
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit
            Button {
                text: qsTr('Desa')
                onClicked: {
                    Qt.inputMethod.hide()
                    Storage.saveAnnotation(idAnnotation,annotation,desc);
                    annotationEditor.setChanges(false);
                    annotationEditor.savedAnnotation(annotation,desc);
                }
            }
            Button {
                text: qsTr('Cancela')
                onClicked: {
                    Qt.inputMethod.hide();
                    var prev = annotationEditor.setChanges(false);
                    annotationEditor.canceledAnnotation(prev);
                }
            }

        }
    }

    Component.onCompleted: {
        if (annotationEditor.idAnnotation != -1) {
            var details = Storage.getDetailsAnnotationId(annotationEditor.idAnnotation);
            console.log('Details ' + JSON.stringify(details));
            annotationEditor.annotation = details.title;
            annotationEditor.desc = details.desc;
            annotationEditor.setChanges(false);
        }
    }
}
