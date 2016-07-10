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
    property string sourceFolder: ''
    property string group
    property int criterium
    property int individual

    property string rubricFile: ''

    signal closeRubricAssessmentHistory()
    signal closeCurrentPage()
    signal contentsSaved()
    signal showRubricGroupAssessment()
    signal showRubricGroupAssessmentCriterium()
    signal showRubricGroupAssessmentDescriptorEditor()
    signal openRubricGroupAssessment()
    signal showRubricAssessmentHistory()
    signal showRubricsAssessmentList()

    states: [
        State {
            name: 'newRubricFile'
        },
        State {
            name: 'default'
        }
    ]
    state: 'default'

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

        onEditRubricAssessmentDescriptor: {
            rubricsModuleItem.individual = individual;
            showRubricGroupAssessmentDescriptorEditor();
        }

        onExportedXml: {
            rubricsModuleSM.xml = xml;
            rubricsModuleSM.saveXmlRubric();
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

        onRubricGroupAssessmentExportSelected: {
            rubricAssessmentIdentifier = assessment;
            console.log('assessment', assessment);
            rubricsModuleSM.exportRubric();
        }

        onRubricGroupAssessmentDescriptorSelected: {
            showRubricGroupAssessmentDescriptorEditor();
        }
    }

    DSM.StateMachine {
        id: rubricsModuleSM

        initialState: (rubricAssessmentIdentifier<0)?rubricsAssessmentList:singleRubricGroupAssessment

        // Internal signals
        signal exportRubric()
        signal saveXmlRubric()

        // Internal properties
        property string xml

        DSM.State {
            id: rubricsAssessmentList

            onEntered: {
                rubricsModuleItem.pushButtonsModel();
                rubricsModuleItem.setSource('qrc:///modules/rubrics/RubricsAssessmentList.qml',{assessment: rubricsModuleItem.rubricAssessmentIdentifier});
            }
            onExited: {
                rubricsModuleItem.popButtonsModel();
            }

            DSM.SignalTransition {
                signal: rubricsModuleItem.openRubricGroupAssessment
                targetState: singleRubricGroupAssessment
            }

            DSM.SignalTransition {
                signal: rubricsModuleSM.exportRubric
                targetState: rubricGroupAssessmentExportState
            }
        }

        DSM.State {
            id: singleRubricGroupAssessment

            onEntered: {
                rubricsModuleItem.pushButtonsModel();
                rubricsModuleItem.buttonsModel.append({icon: 'list-153185', object: rubricsModuleItem, method: 'showRubricAssessmentHistory'});
                rubricsModuleItem.buttonsModel.append({icon: 'road-sign-147409', object: rubricsModuleItem, method: 'showRubricsAssessmentList'});
                rubricsModuleItem.setSource('qrc:///modules/rubrics/RubricGroupAssessment.qml',{assessment: rubricAssessmentIdentifier});
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
                setSource('qrc:///modules/rubrics/RubricAssessmentHistory.qml', {rubric: mainItem.rubric, group: mainItem.group});
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
                setSource('qrc:///modules/rubrics/RubricGroupAssessmentCriterium.qml', {assessment: rubricsModuleItem.rubricAssessmentIdentifier, group: rubricsModuleItem.group, criterium: rubricsModuleItem.criterium});
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
                setSource('qrc:///modules/rubrics/RubricGroupAssessmentDescriptorEditor.qml',{assessment: rubricAssessmentIdentifier, criterium: criterium, individual: individual});
                rubricsModuleItem.buttonsModel.append({icon: 'floppy-35952', object: mainItem, method: 'saveModifiedContents'});
                rubricsModuleItem.buttonsModel.append({icon: 'road-sign-147409', object: rubricsModuleItem, method: 'closeCurrentPage'});
            }
            onExited: {
                rubricsModuleItem.popButtonsModel();
            }

            DSM.SignalTransition {
                signal: closeCurrentPage
                targetState: historyState
            }

            DSM.SignalTransition {
                signal: contentsSaved
                targetState: historyState
            }
        }

        DSM.HistoryState {
            id: historyState
            historyType: DSM.HistoryState.DeepHistory
            defaultState: rubricsAssessmentList
        }

        DSM.State {
            id: rubricGroupAssessmentExportState

            onEntered: {
                pushButtonsModel();
                setSource('qrc:///modules/rubrics/ExportRubricToXml.qml', {assessment: rubricAssessmentIdentifier});
            }

            onExited: {
                popButtonsModel();
            }

            DSM.SignalTransition {
                signal: rubricsModuleSM.saveXmlRubric
                targetState: xmlRubricSaveState
            }
        }

        DSM.State {
            id: xmlRubricSaveState

            onEntered: {
                pushButtonsModel();
                setSource('qrc:///modules/rubrics/XmlRubricSave.qml', {xml: rubricsModuleSM.xml});
            }
            onExited: {
                popButtonsModel();
            }
        }

        DSM.State {
            id: showRubricFromDocument

            onEntered: {
                rubricsModuleItem.pushButtonsModel();
                rubricsModuleItem.buttonsModel.append({icon: 'road-sign-147409', object: rubricsModuleItem, method: 'closeCurrentPage'});
                setSource('qrc:///modules/rubrics/ExtendedRubricDefinition.qml', {rubricFile: rubricsModuleItem.rubricFile});
            }

            onExited: {
                rubricsModuleItem.popButtonsModel();
            }
        }

        DSM.State {
            id: newRubricState

            onEntered: {
                pushButtonsModel();
                setSource('qrc:///modules/rubrics/NewRubricFile.qml', {sourceFolder: sourceFolder});
            }

            onExited: {
                popButtonsModel();
            }
        }
    }

    Component.onCompleted: {
        if (state == 'newRubricFile') {
            rubricsModuleSM.initialState = newRubricState;
        } else {
            if (rubricFile !== '') {
                console.log('Rubric file', rubricFile);
                rubricsModuleSM.initialState = showRubricFromDocument;
            }
        }

        rubricsModuleSM.start();
    }

}

