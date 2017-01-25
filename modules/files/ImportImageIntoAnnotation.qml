import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import FileIO 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///models' as Models

Item {
    id: imageImporterItem

    property string fileURL: ''

    property int annotation: -1

    signal importedFileIntoAnnotation(string file, int annotation)

    Common.UseUnits {
        id: units
    }

    Models.DocumentAnnotations {
        id: annotationsModel
    }

    ColumnLayout {
        anchors.fill: parent

        Editors.TextAreaEditor3 {
            id: newTitleEditor

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 3

            content: qsTr('Imatge importada ') + fileURL + (new Date()).toISOString()
        }

        Image {
            id: imageView

            Layout.fillHeight: true
            Layout.fillWidth: true

            fillMode: Image.PreserveAspectFit
            source: imageImporterItem.fileURL
        }
        Button {
            id: removeOriginalButton

            checked: false
            checkable: true

            text: qsTr('Esborra original')
        }
        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            text: qsTr('Importa')

            onClicked: importImage()
        }
    }

    FileIO {
        id: imageFile

        source: fileURL
    }

    function importImage() {
        if (imageImporterItem.annotation < 0) {
            var title = newTitleEditor.content.trim();
            var dateStr = (new Date()).toISOString()
            if (title == '') {
                title = qsTr('Imatge importada ') + fileURL + ' ' + dateStr;
            }

            var contents = imageFile.readBinary();
            imageImporterItem.annotation = annotationsModel.insertObject(
                        {
                            title: title,
                            created: dateStr,
                            labels: 'imported',
                            source: fileURL,
                            contents: contents
                        });

            removeSourceFile();
        } else {
            replaceImageDialog.open();
        }

    }

    function removeSourceFile() {
        if (imageImporterItem.annotation>=0) {
            if (removeOriginalButton.checked) {
                imageFile.removeSource();
            }
            importedFileIntoAnnotation(fileURL, imageImporterItem.annotation);
        }

    }

    function importAndReplaceImage() {
        var contents = imageFile.readBinary();
        annotationsModel.updateObject(imageImporterItem.annotation,
                                      {
                                          source: fileURL,
                                          contents: contents
                                      });
        removeSourceFile();
    }

    MessageDialog {
        id: replaceImageDialog

        title: qsTr('Substituir imatge')

        text: qsTr("Estàs a punt de substituir els continguts originals per uns altres. Vols continuar?")

        standardButtons: StandardButton.Ok | StandardButton.Cancel

        onAccepted: importAndReplaceImage()
    }
}
