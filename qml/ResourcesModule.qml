import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQml.StateMachine 1.0 as DSM
import PersonalTypes 1.0
import ClipboardAdapter 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///models' as Models
import 'qrc:///components' as Components
import "qrc:///common/FormatDates.js" as FormatDates
import "qrc:///javascript/Storage.js" as Storage

BasicPage {
    id: resourcesModule

    pageTitle: qsTr('Recursos')

    signal closeCurrentPage()
    signal documentSelected()
    signal showResource()
    signal showSelectFile()

    property int resourceId: -1
    property string documentSource: ''

    Models.ResourcesModel {
        id: resourcesModel
    }

    Connections {
        target: mainItem

        ignoreUnknownSignals: true

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
    }

    DSM.StateMachine {
        id: resourcesModuleSM

        initialState: resourcesListState

        DSM.State {
            id: resourcesListState

            onEntered: {
                pushButtonsModel();
                setSource('qrc:///components/ResourcesList.qml', {});
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
            }

            onExited: {
                popButtonsModel();
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
            id: newResourceState

            onEntered: {
                console.log('Document source', documentSource);
                var obj = {
                    created: Storage.currentTime(),
                    title: qsTr('Nou recurs'),
                    desc: qsTr('Edita la descripció...'),
                    source: documentSource,
                    contents: '',
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
    }

    Component.onCompleted: resourcesModuleSM.start();
}
