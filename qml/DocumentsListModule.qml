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
    signal showDocument()
    signal showDocumentSource()
    signal showSelectFile()

    property var sharedObject: null

    property string documentId: ""
    property string documentSource: ''
    property string annotationTitle: ''

    states: [
        State {
            name: 'displaySource'
        },
        State {
            name: 'defaultState'
        }
    ]
    state: 'defaultState'

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
            documentsModuleSM.documentSelected();
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

        signal documentSelected()

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
                signal: documentsModuleSM.documentSelected
                targetState: singleDocumentState
            }
        }

        DSM.FinalState {
            id: singleDocumentState

            onEntered: {
                console.log('selected',documentId);

                documentSelected(documentId);
            }
        }

        DSM.HistoryState {
            id: historyState

            defaultState: documentsListState
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
        documentsModuleSM.initialState = documentsListState;
        documentsModuleSM.start();
    }
}
