import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import FileIO 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///models' as Models

Item {
    id: imageImporterItem

    property string fileURL: ''

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
        var title = newTitleEditor.content.trim();
        var dateStr = (new Date()).toISOString()
        if (title == '') {
            title = qsTr('Imatge importada ') + fileURL + ' ' + dateStr;
        }
        console.log('nova anotacio', title);

        var contents = imageFile.readBinary();
        console.log('read binary', contents);
        var annotation = annotationsModel.insertObject(
                    {
                        title: title,
                        created: dateStr,
                        labels: 'imported',
                        source: fileURL,
                        contents: contents
                    });

        if (annotation>=0) {
            if (removeOriginalButton.checked) {
                imageFile.removeSource();
            }
            importedFileIntoAnnotation(fileURL, annotation);
        }
    }
}
