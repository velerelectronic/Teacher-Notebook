import QtQuick 2.5
import QtQml.StateMachine 1.0 as DSM
import PersonalTypes 1.0
import 'qrc:///models' as Models

BasicPage {
    id: documentsModule

    pageTitle: qsTr('Vista de document')

    signal documentsListSelected(string document)
    signal documentSelected()
    signal showDocument()
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

        onDocumentSelected: {
            documentId = document;
            documentSelected();
        }

        onDocumentSourceSelected: {
            console.log('show', source);
            documentSource = source;
            switch(mediaType) {
            case 'Rubric':
                documentsModuleSM.showRubric();
                break;
            default:
                documentsModuleSM.showDocumentSource();
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
            showSelectFile();
        }

    }

    DSM.StateMachine {
        id: documentsModuleSM

        initialState: singleDocumentState

        signal changeAnnotation()
        signal changeDocumentSource()
        signal documentsListSelected()
        signal showDocument()
        signal showDocumentSource()
        signal showRubric()

        // Internal properties

        property string sourceFile

        DSM.State {
            id: singleDocumentState

            onEntered: {
                pushButtonsModel();
                setSource('qrc:///modules/documents/ShowDocument.qml', {document: documentId});
                buttonsModel.append({icon: 'list-153185', object: documentsModule, method: 'reopenDocumentsList'});
            }

            onExited: {
                popButtonsModel();
            }

            DSM.SignalTransition {
                signal: documentsModuleSM.changeAnnotation
                targetState: changeDocumentAnnotationState
            }

            DSM.SignalTransition {
                signal: documentsModuleSM.showDocumentSource
                targetState: documentSourceDisplayState
            }

            DSM.SignalTransition {
                signal: documentsModuleSM.showRubric
                targetState: rubricDisplayState
            }
        }

        DSM.State {
            id: rubricDisplayState

            onEntered: {
                pushButtonsModel();
                setSource('qrc:///modules/rubrics/RubricGroupAssessment.qml', {rubricFile: documentSource});
            }

            onExited: {
                popButtonsModel();
            }
        }

        DSM.State {
            id: selectFileState

            onEntered: {
                pushButtonsModel();
                setSource('qrc:///modules/files/FileSelector.qml', {});
                buttonsModel.append({icon: 'computer-31223', object: mainItem, method: 'gotoParentFolder'});
                buttonsModel.append({icon: 'info-147927', object: mainItem, method: 'toggleDetails'});
                buttonsModel.append({icon: 'road-sign-147409', object: documentsModule, method: 'reopenDocumentsList'});
            }

            onExited: {
                popButtonsModel();
            }

            DSM.SignalTransition {
                signal: documentsModuleSM.changeDocumentSource
                targetState: newDocumentState
            }
        }

        DSM.State {
            id: newDocumentState

            onEntered: {
                pushButtonsModel();
                setSource('qrc:///modules/documents/NewDocument.qml', {title: documentsModuleSM.sourceFile, source: documentsModuleSM.sourceFile});
                buttonsModel.append({icon: 'road-sign-147409', object: documentsModule, method: 'reopenDocumentsList'});
            }

            onExited: {
                popButtonsModel();
            }
        }

        DSM.State {
            id: changeDocumentAnnotationState

            onEntered: {
                pushButtonsModel();
                buttonsModel.append({icon: 'road-sign-147409', object: documentsModuleSM, method: 'showDocument'});
                setSource('qrc:///components/RelatedAnnotations.qml', {identifier: annotationTitle});
            }

            onExited: {
                popButtonsModel();
            }

            DSM.SignalTransition {
                signal: documentsModuleSM.changeAnnotation
                targetState: singleDocumentState
            }

            DSM.SignalTransition {
                signal: documentsModuleSM.showDocument
                targetState: singleDocumentState
            }
        }

        DSM.State {
            id: documentSourceDisplayState

            onEntered: {
                pushButtonsModel();
                setSource('qrc:///modules/documents/DocumentViewer.qml', {source: documentSource});
                buttonsModel.append({icon: 'box-24557', object: mainItem, method: 'openSourceExternally'});
                buttonsModel.append({icon: 'list-153185', object: documentsModule, method: 'reopenDocumentsList'});
            }

            onExited: {
                popButtonsModel();
            }
        }
    }

    function reopenDocumentsList() {
        documentsListSelected(documentId);
    }

    Component.onCompleted: {
        if (documentId == '') {
            documentsModuleSM.initialState = selectFileState;
        } else {
            documentsModuleSM.initialState = singleDocumentState;
        }
        documentsModuleSM.start();
    }

    Component.onDestruction: popButtonsModel()
}
