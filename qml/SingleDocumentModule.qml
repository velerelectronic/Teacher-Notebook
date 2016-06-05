import QtQuick 2.5
import QtQml.StateMachine 1.0 as DSM
import PersonalTypes 1.0
import 'qrc:///models' as Models

BasicPage {
    id: documentsModule

    pageTitle: qsTr('Vista de document')

    signal changeAnnotation()
    signal changeDocumentSource()
    signal closeCurrentPage()
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
            closeCurrentPage();
        }
    }

    DSM.StateMachine {
        id: documentsModuleSM

        initialState: documentsListState

        signal documentsListSelected()

        DSM.HistoryState {
            id: historyState

            defaultState: documentsListState
        }

        DSM.State {
            id: singleDocumentState

            onEntered: {
                pushButtonsModel();
                setSource('qrc:///components/ShowDocument.qml', {document: documentId});
                buttonsModel.append({icon: 'list-153185', object: documentsModuleSM, method: 'documentsListSelected'});
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

            DSM.SignalTransition {
                signal: documentsModuleSM.documentsListSelected
                targetState: documentsListState
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

            DSM.SignalTransition {
                signal: closeCurrentPage
                targetState: historyState
            }
        }

        DSM.FinalState {
            id: documentsListState

            onEntered: {
                console.log('document id', documentId);
                documentsListSelected(documentId);
            }
        }
    }

    Component.onCompleted: {
        documentsModuleSM.initialState = singleDocumentState;
        documentsModuleSM.start();
    }
}
