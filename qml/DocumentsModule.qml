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
    signal documentSelected()
    signal documentUpdated()
    signal showDocument()
    signal showDocumentSource()
    signal showSelectFile()

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
            documentSelected();
        }

        onFileSelected: {
            documentSource = file;
            changeDocumentSource();
        }

        onNewDocumentSelected: {
            showSelectFile();
        }

        onDocumentSourceSelected: {
            documentSource = source;
            console.log('show', source);
            showDocumentSource();
        }

        onCloseNewDocument: {
            closeCurrentPage();
        }

        onDocumentUpdated: {
            closeCurrentPage();
        }
    }

    DSM.StateMachine {
        id: documentsModuleSM

        initialState: documentsListState

        DSM.State {
            id: documentsListState

            onEntered: {
                pushButtonsModel();
                setSource('qrc:///components/DocumentsList.qml', {selectedIdentifier: documentId});
            }

            onExited: {
                popButtonsModel();
            }

            DSM.SignalTransition {
                signal: showDocument
                targetState: singleDocumentState
            }

            DSM.SignalTransition {
                signal: documentSelected
                targetState: singleDocumentState
            }

            DSM.SignalTransition {
                signal: showSelectFile
                targetState: selectFileState
            }

            DSM.SignalTransition {
                signal: showDocumentSource
                targetState: documentSourceDisplayState
            }
        }

        DSM.HistoryState {
            id: historyState

            defaultState: documentsListState
        }

        DSM.State {
            id: singleDocumentState

            onEntered: {
                pushButtonsModel();
                setSource('qrc:///components/ShowDocument.qml', {document: documentId});
                buttonsModel.append({icon: 'floppy-35952', object: mainItem, method: 'saveEditorContents'});
                buttonsModel.append({icon: 'road-sign-147409', object: documentsModule, method: 'closeCurrentPage'});
            }

            onExited: {
                popButtonsModel();
            }

            DSM.SignalTransition {
                signal: closeCurrentPage
                targetState: documentsListState
            }

            DSM.SignalTransition {
                signal: changeAnnotation
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
                setSource('qrc:///components/DocumentsSelector.qml', {});
                buttonsModel.append({icon: 'computer-31223', object: mainItem, method: 'gotoParentFolder'});
                buttonsModel.append({icon: 'info-147927', object: mainItem, method: 'toggleDetails'});
                buttonsModel.append({icon: 'road-sign-147409', object: documentsModule, method: 'closeCurrentPage'});
            }

            onExited: {
                popButtonsModel();
            }

            DSM.SignalTransition {
                signal: changeDocumentSource
                targetState: newDocumentState
            }

            DSM.SignalTransition {
                signal: closeCurrentPage
                targetState: historyState
            }
        }

        DSM.State {
            id: changeDocumentAnnotationState

            onEntered: {
                pushButtonsModel();
                buttonsModel.append({icon: 'road-sign-147409', object: documentsModule, method: 'closeCurrentPage'});
                setSource('qrc:///components/RelatedAnnotations.qml', {identifier: annotationTitle});
            }

            onExited: {
                popButtonsModel();
            }

            DSM.SignalTransition {
                signal: changeAnnotation
                targetState: singleDocumentState
            }

            DSM.SignalTransition {
                signal: closeCurrentPage
                targetState: singleDocumentState
            }
        }

        DSM.State {
            id: newDocumentState

            onEntered: {
                pushButtonsModel();
                buttonsModel.append({icon: 'road-sign-147409', object: documentsModule, method: 'closeCurrentPage'});
                setSource('qrc:///components/NewDocument.qml', {source: documentSource});

            }

            onExited: {
                popButtonsModel();
            }

            DSM.SignalTransition {
                signal: closeCurrentPage
                targetState: documentsListState
            }
        }
        DSM.State {
            id: documentSourceDisplayState

            onEntered: {
                pushButtonsModel();
                setSource('qrc:///components/DocumentViewer.qml', {source: documentSource});
                buttonsModel.append({icon: 'box-24557', object: mainItem, method: 'openSourceExternally'});
                buttonsModel.append({icon: 'road-sign-147409', object: documentsModule, method: 'closeCurrentPage'});
            }

            onExited: {
                popButtonsModel();
            }

            DSM.SignalTransition {
                signal: closeCurrentPage
                targetState: historyState
            }
        }
    }

    Component.onCompleted: {
        if (documentId >= 0) {
            switch(state) {
            case 'displaySource':
                documentsModuleSM.initialState = documentSourceDisplayState;
                break;
            default:
                documentsModuleSM.initialState = singleDocumentState;
                break;
            }
        }
        documentsModuleSM.start();
    }
}
