import QtQuick 2.5
import QtQml.StateMachine 1.0 as DSM
import QtQml.Models 2.2
import PersonalTypes 1.0
import 'qrc:///models' as Models
import 'qrc:///common' as Common
import 'qrc:///modules/basic' as Basic
import 'qrc:///modules/buttons' as Buttons
import 'qrc:///modules/documents' as Documents

Basic.BasicPage {
    id: documentsModule

    pageTitle: qsTr('Vista de document')

    signal documentsListSelected(string document)
    signal documentSelected()
    signal showDocument()
    signal showDocumentSource()
    signal showSelectFile()
    signal showRubric(string rubricFile)

    property string documentId: ""
    property string documentSource: ''
    property string annotationTitle: ''

    Models.DocumentsModel {
        id: documentsModel
    }

    Connections {
        target: mainItem

        ignoreUnknownSignals: true

        onAnnotationEditSelected: {
            annotationTitle = annotation;
            documentId = document;
            documentsModuleSM.changeAnnotation();
        }

        onAnnotationSelected: {
            documentsModel.updateObject(documentId, {annotation: title});
            documentsModuleSM.changeAnnotation();
        }

        onCloseNewDocument: {
            documentId = document;
            documentsListSelected(document);
        }

        onDocumentRemoved: {
            documentsListSelected('');
        }

        onDocumentSelected: {
            documentId = document;
            documentSelected();
        }

        onDocumentSourceSelected: {
            console.log('show', source);
            documentSource = source;
            switch(mediaType) {
            case 'Rubric':
                documentsModule.showRubric(source);
                break;
            default:
                documentsModule.showDocumentSource();
            }
        }

        onFileSelected: {
            documentsModuleSM.sourceFile = file;
            documentsModuleSM.changeDocumentSource();
        }

        onFolderSelected: {
            var sourceFolder = folder;
            openPageArgs('RubricsModule',{state: 'newRubricFile', sourceFolder: sourceFolder});
        }

        onNewDocumentSelected: {
            supermenuLoader.headerTitle = qsTr('Tria un document...');
            menuLoader.setSource('qrc:///modules/files/FileSelector.qml');
        }
    }

    buttonsModel: ObjectModel {
        Buttons.MainButton {
            image: 'list-153185'
            onClicked: documentsModule.reopenDocumentsList()
        }
    }

    sourceComponent: Documents.ShowDocument {
        document: documentId
    }

    function reopenDocumentsList() {
        documentsListSelected(documentId);
    }

}
