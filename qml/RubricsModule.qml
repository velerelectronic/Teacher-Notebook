import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQml.StateMachine 1.0 as DSM
import 'qrc:///common' as Common

BasicPage {
    id: rubricsModuleItem

    pageTitle: qsTr("Rúbriques")

    property string initialState: ''
    property int rubricAssessmentIdentifier: -1
    property string group
    property int criterium
    property int individual

    signal closeRubricAssessmentHistory()
    signal closeCurrentPage()
    signal contentsSaved()
    signal showRubricGroupAssessment()
    signal showRubricGroupAssessmentCriterium()
    signal showRubricGroupAssessmentDescriptorEditor()
    signal openRubricGroupAssessment()
    signal showRubricAssessmentHistory()
    signal showRubricsAssessmentList()

    function openRubricHistory(group) {
        openPageArgs('RubricAssessmentHistory',{group: group});
    }

    function openRubricAssessmentDetails(assessment, rubric, group, rubricsModel, rubricsAssessmentModel) {
        openPageArgs('RubricAssessmentEditor', {idAssessment: assessment, rubric: rubric, group: group, rubricsModel: rubricsModel, rubricsAssessmentModel: rubricsAssessmentModel}, units.fingerUnit);
    }

    Common.UseUnits { id: units }

    property string searchString: ''
    property var searchFields: []

    Connections {
        target: mainItem
        ignoreUnknownSignals: true

        onContentsSaved: rubricsModuleItem.contentsSaved();

        onAnnotationSelected: {
            openPageArgs('AnnotationsModule', {identifier: annotation});
        }

        onRubricAssessmentCriteriumSelected: {
            console.log('ctierium', criterium);
            rubricsModuleItem.criterium = criterium;
            rubricsModuleItem.showRubricGroupAssessmentCriterium();
        }

        onRubricGroupAssessmentSelected: {
            rubricsModuleItem.rubricAssessmentIdentifier = assessment;
            rubricsModuleItem.openRubricGroupAssessment();
        }

        onEditRubricAssessmentDescriptor: {
            rubricsModuleItem.individual = individual;
            showRubricGroupAssessmentDescriptorEditor();
        }

        onRubricGroupAssessmentDescriptorSelected: {
            showRubricGroupAssessmentDescriptorEditor();
        }
    }

    DSM.StateMachine {
        id: rubricsModuleSM

        initialState: (rubricAssessmentIdentifier<0)?rubricsAssessmentList:singleRubricGroupAssessment

        DSM.State {
            id: rubricsAssessmentList

            onEntered: {
                rubricsModuleItem.pushButtonsModel();
                rubricsModuleItem.setSource('qrc:///components/RubricsAssessmentList.qml',{assessment: rubricsModuleItem.rubricAssessmentIdentifier});
            }
            onExited: {
                rubricsModuleItem.popButtonsModel();
            }

            DSM.SignalTransition {
                signal: rubricsModuleItem.openRubricGroupAssessment
                targetState: singleRubricGroupAssessment
            }
        }

        DSM.State {
            id: singleRubricGroupAssessment

            onEntered: {
                rubricsModuleItem.pushButtonsModel();
                rubricsModuleItem.buttonsModel.append({icon: 'list-153185', object: rubricsModuleItem, method: 'showRubricAssessmentHistory'});
                rubricsModuleItem.buttonsModel.append({icon: 'road-sign-147409', object: rubricsModuleItem, method: 'showRubricsAssessmentList'});
                rubricsModuleItem.setSource('qrc:///components/RubricGroupAssessment.qml',{assessment: rubricAssessmentIdentifier});
            }
            onExited: {
                rubricsModuleItem.popButtonsModel();
            }

            DSM.SignalTransition {
                signal: rubricsModuleItem.showRubricsAssessmentList
                targetState: rubricsAssessmentList
            }

            DSM.SignalTransition {
                signal: rubricsModuleItem.showRubricAssessmentHistory
                targetState: rubricGroupAssessmentHistory
            }

            DSM.SignalTransition {
                signal: showRubricGroupAssessmentCriterium
                targetState: rubricGroupAssessmentCriterium
            }
        }

        DSM.State {
            id: rubricGroupAssessmentHistory

            onEntered: {
                rubricsModuleItem.pushButtonsModel();
                rubricsModuleItem.buttonsModel.append({icon: 'road-sign-147409', object: rubricsModuleItem, method: 'closeRubricAssessmentHistory'});
                setSource('qrc:///components/RubricAssessmentHistory.qml', {rubric: mainItem.rubric, group: mainItem.group});
            }
            onExited: {
                rubricsModuleItem.popButtonsModel();
            }

            DSM.SignalTransition {
                signal: rubricsModuleItem.closeRubricAssessmentHistory
                targetState: historyState
            }
        }

        DSM.State {
            id: rubricGroupAssessmentCriterium

            onEntered: {
                rubricsModuleItem.pushButtonsModel();
                rubricsModuleItem.buttonsModel.append({icon: 'window-27140', object: rubricsModuleItem, method: 'showRubricGroupAssessment'});
                setSource('qrc:///components/RubricGroupAssessmentCriterium.qml', {assessment: rubricsModuleItem.rubricAssessmentIdentifier, group: rubricsModuleItem.group, criterium: rubricsModuleItem.criterium});
            }

            onExited: {
                rubricsModuleItem.popButtonsModel();
            }

            DSM.SignalTransition {
                signal: showRubricGroupAssessment
                targetState: singleRubricGroupAssessment
            }

            DSM.SignalTransition {
                signal: showRubricGroupAssessmentDescriptorEditor
                targetState: rubricAssessmentDescriptorEditor
            }
        }

        DSM.State {
            id: rubricAssessmentDescriptorEditor

            onEntered: {
                rubricsModuleItem.pushButtonsModel();
                setSource('qrc:///components/RubricGroupAssessmentDescriptorEditor.qml',{assessment: rubricAssessmentIdentifier, criterium: criterium, individual: individual});
                rubricsModuleItem.buttonsModel.append({icon: 'floppy-35952', object: mainItem, method: 'saveModifiedContents'});
                rubricsModuleItem.buttonsModel.append({icon: 'road-sign-147409', object: rubricsModuleItem, method: 'closeCurrentPage'});
            }
            onExited: {
                rubricsModuleItem.popButtonsModel();
            }

            DSM.SignalTransition {
                signal: closeCurrentPage
                targetState: rubricGroupAssessmentCriterium
            }

            DSM.SignalTransition {
                signal: contentsSaved
                targetState: rubricGroupAssessmentCriterium
            }
        }

        DSM.HistoryState {
            id: historyState
            historyType: DSM.HistoryState.DeepHistory
            defaultState: rubricsAssessmentList
        }
    }

    Component.onCompleted: {
        rubricsModuleSM.start();
    }

}

