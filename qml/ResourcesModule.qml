import QtQuick 2.5
import QtQml.StateMachine 1.0 as DSM
import PersonalTypes 1.0
import 'qrc:///models' as Models
import "qrc:///javascript/Storage.js" as Storage

BasicPage {
    id: resourcesModule

    pageTitle: qsTr('Recursos')

    signal changeAnnotation()
    signal closeCurrentPage()
    signal documentSelected()
    signal showResource()
    signal showResourceSource()
    signal showSelectFile()

    property int resourceId: -1
    property string documentSource: ''
    property string annotationTitle: ''

    Models.ResourcesModel {
        id: resourcesModel
    }

    Connections {
        target: mainItem

        ignoreUnknownSignals: true

        onAnnotationSelected: {
            resourcesModel.updateObject(resourceId, {annotation: title});
            changeAnnotation();
        }

        onAnnotationEditSelected: {
            annotationTitle = annotation;
            resourceId = resource;
            changeAnnotation();
        }

        onDocumentSelected: {
            documentSource = document;
            documentSelected();
        }

        onNewResourceSelected: {
            showSelectFile();
        }

        onResourceSelected: {
            resourceId = resource;
            showResource();
        }

        onResourceSourceSelected: {
            resourceId = resource;
            showResourceSource();
        }

        onResourceUpdated: {
            closeCurrentPage();
        }
    }

    DSM.StateMachine {
        id: resourcesModuleSM

        initialState: resourcesListState

        DSM.State {
            id: resourcesListState

            onEntered: {
                pushButtonsModel();
                setSource('qrc:///components/ResourcesList.qml', {selectedIdentifier: resourceId});
            }

            onExited: {
                popButtonsModel();
            }

            DSM.SignalTransition {
                signal: showResource
                targetState: singleResourceState
            }

            DSM.SignalTransition {
                signal: showSelectFile
                targetState: selectFileState
            }

            DSM.SignalTransition {
                signal: showResourceSource
                targetState: resourceSourceDisplayState
            }
        }

        DSM.HistoryState {
            id: historyState

            defaultState: resourcesListState
        }

        DSM.State {
            id: singleResourceState

            onEntered: {
                pushButtonsModel();
                setSource('qrc:///components/ShowSingleResource.qml', {resource: resourceId});
                buttonsModel.append({icon: 'floppy-35952', object: mainItem, method: 'saveEditorContents'});
                buttonsModel.append({icon: 'road-sign-147409', object: resourcesModule, method: 'closeCurrentPage'});
            }

            onExited: {
                popButtonsModel();
            }

            DSM.SignalTransition {
                signal: closeCurrentPage
                targetState: resourcesListState
            }

            DSM.SignalTransition {
                signal: changeAnnotation
                targetState: changeResourceAnnotationState
            }
        }

        DSM.State {
            id: selectFileState

            onEntered: {
                pushButtonsModel();
                setSource('qrc:///components/DocumentsList.qml', {});
                buttonsModel.append({icon: 'computer-31223', object: mainItem, method: 'gotoParentFolder'});
                buttonsModel.append({icon: 'info-147927', object: mainItem, method: 'toggleDetails'});
                buttonsModel.append({icon: 'road-sign-147409', object: resourcesModule, method: 'closeCurrentPage'});
            }

            onExited: {
                popButtonsModel();
            }

            DSM.SignalTransition {
                signal: documentSelected
                targetState: newResourceState
            }

            DSM.SignalTransition {
                signal: closeCurrentPage
                targetState: historyState
            }
        }

        DSM.State {
            id: changeResourceAnnotationState

            onEntered: {
                pushButtonsModel();
                buttonsModel.append({icon: 'road-sign-147409', object: resourcesModule, method: 'closeCurrentPage'});
                setSource('qrc:///components/RelatedAnnotations.qml', {identifier: annotationTitle});
            }

            onExited: {
                popButtonsModel();
            }

            DSM.SignalTransition {
                signal: changeAnnotation
                targetState: singleResourceState
            }

            DSM.SignalTransition {
                signal: closeCurrentPage
                targetState: singleResourceState
            }
        }

        DSM.State {
            id: newResourceState

            onEntered: {
                console.log('Document source', documentSource);
                var extension = /[^.]+$/.exec(documentSource);
                var obj = {
                    created: Storage.currentTime(),
                    title: qsTr('Nou recurs'),
                    desc: qsTr('Edita la descripció...'),
                    source: documentSource,
                    contents: '',
                    type: extension.toString().toUpperCase(),
                    hash: '',
                    annotation: ''
                }
                resourcesModel.insertObject(obj);
            }

            onExited: {}

            DSM.TimeoutTransition {
                timeout: 0
                targetState: resourcesListState
            }
        }
        DSM.State {
            id: resourceSourceDisplayState

            onEntered: {
                pushButtonsModel();
                setSource('qrc:///components/ResourceSourceViewer.qml', {resource: resourceId});
                buttonsModel.append({icon: 'road-sign-147409', object: resourcesModule, method: 'closeCurrentPage'});
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
        if (resourceId >= 0) {
            switch(state) {
            case 'displaySource':
                resourcesModuleSM.initialState = resourceSourceDisplayState;
                break;
            default:
                resourcesModuleSM.initialState = singleResourceState;
                break;
            }
        }
        resourcesModuleSM.start();
    }
}
