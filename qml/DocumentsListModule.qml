import QtQuick 2.5
import QtQml.StateMachine 1.0 as DSM
import PersonalTypes 1.0
import 'qrc:///models' as Models

BasicPage {
    id: documentsModule

    pageTitle: qsTr('Documents')

    signal changeAnnotation()
    signal changeDocumentSource()
    signal closeCurrentPage()
    signal documentSelected(string document)
    signal newDocumentSelected()
    signal showDocument()
    signal showDocumentSource()
    signal showSelectFile()

    property var sharedObject: null

    property string documentId: ""
    property string documentSource: ''
    property string annotationTitle: ''

    Models.DocumentsModel {
        id: documentsModel
    }

    Connections {
        target: mainItem

        ignoreUnknownSignals: true

        onAnnotationSelected: {
            documentsModel.updateObject(documentId, {annotation: title});
            changeAnnotation();
        }

        onAnnotationEditSelected: {
            annotationTitle = annotation;
            documentId = document;
            changeAnnotation();
        }

        onDocumentSelected: {
            documentId = document;
            documentsModule.documentSelected(document);
        }

        onFileSelected: {
            documentSource = file;
            changeDocumentSource();
        }

        onFolderSelected: {
            var sourceFolder = folder;
            openPageArgs('RubricsModule',{state: 'newRubricFile', sourceFolder: sourceFolder});
        }

        onNewDocumentSelected: {
            documentsModule.newDocumentSelected();
        }

        onDocumentSourceSelected: {
            console.log('show', source);
            documentSource = source;
            if (/\.rubricxml$/g.test(source)) {
                // Show Rubric FromFile
                documentsModule.openPageArgs('RubricsModule', {rubricFile: documentSource});
            } else {
                showDocumentSource();
            }
        }

        onCloseNewDocument: {
            closeCurrentPage();
        }
    }


    Component.onCompleted: {
        setSource('qrc:///modules/documents/DocumentsList.qml', {selectedIdentifier: documentId});
    }
}
