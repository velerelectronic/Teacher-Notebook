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
            documentsModuleSM.changeAnnotation();
        }

        onAnnotationEditSelected: {
            annotationTitle = annotation;
            documentId = document;
            documentsModuleSM.changeAnnotation();
        }

        onDocumentSelected: {
            documentId = document;
            documentSelected();
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
            documentId = document;
            documentsListSelected(document);
        }
    }

    DSM.StateMachine {
        id: documentsModuleSM

        initialState: singleDocumentState

        signal changeAnnotation()
        signal changeDocumentSource()
        signal documentsListSelected()
        signal showDocument()

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
                signal: showDocumentSource
                targetState: documentSourceDisplayState
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
                setSource('qrc:///components/DocumentViewer.qml', {source: documentSource});
                buttonsModel.append({icon: 'box-24557', object: mainItem, method: 'openSourceExternally'});
                buttonsModel.append({icon: 'list-153185', object: documentsModule, method: 'openDocumentsList'});
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
}
