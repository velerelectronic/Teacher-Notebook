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
import 'qrc:///modules/annotations' as AnnotationComponents
import "qrc:///common/FormatDates.js" as FormatDates


BasicPage {
    id: annotationView

    pageTitle: qsTr('Anotació')

    signal openAttachmentsPage()
    signal changeAnnotationTitle()
    signal changeAnnotationDescription()
    signal changeAnnotationLabels()
    signal changeAnnotationPeriod()
    signal changeAnnotationState()
    signal closeCurrentPage()
    signal closeNewAnnotation()
    signal closeNewRubricAssessment()

    signal editorContentsSaved()
    signal editorContentsDeclined()
    signal hideHistory()
    signal importAnnotations()
    signal newIntelligentAnnotation()
    signal newRubricAssessment()
    signal newTimetableAnnotation()
    signal openExternalViewer(string identifier)

    signal saveNewAnnotation()
    signal showAnnotationsList()
    signal showNewAnnotation()
    signal showRelatedAnnotationsByLabels()
    signal showRelatedAnnotationsByPeriod()
    signal showSingleAnnotation()
    signal showHistory()

    property string identifier: ''
    property var editContent
    property string labels: ''

    property var lastItemSelected: null

    Common.UseUnits {
        id: units
    }

    Models.ExtendedAnnotations {
        id: annotationsModel

        Component.onCompleted: select()
    }

    Connections {
        target: mainItem

        ignoreUnknownSignals: true

        onAnnotationDescriptionSelected: {
            lastItemSelected = widget;
            editContent = description;
            annotationView.changeAnnotationDescription();
        }
        onAnnotationLabelsSelected: {
            editContent = labels;
            annotationView.changeAnnotationLabels();
        }
        onAnnotationPeriodSelected: {
            console.log('start-end',start,end);
            editContent = {start: start, end: end};
            annotationView.changeAnnotationPeriod();
        }

        onAnnotationSelected: {
            annotationView.identifier = title;
            showSingleAnnotation();
        }

        onAnnotationStateSelected: {
            editContent = stateValue;
            annotationView.changeAnnotationState();
        }

        onAnnotationTitleSelected: {
            editContent = annotationView.identifier;
            lastItemSelected = widget;
            annotationView.changeAnnotationTitle();
        }

        onAttachmentsSelected: {
            console.log('select');
            openAttachmentsPage();
        }

        onCloseNewAnnotation: {
            annotationView.closeNewAnnotation();
        }

        onCloseNewRubricAssessment: annotationView.closeNewRubricAssessment()

        onNewRubricAssessment: {
            identifier = annotation;
            annotationView.newRubricAssessment();
        }
    }

    Connections {
        target: subItem

        ignoreUnknownSignals: true

        onSaveAnnotationTitleRequest: {
            console.log('content', content);
            var newIdentifier = content;
            annotationsModel.updateObject(annotationView.identifier, {title: newIdentifier});
            annotationView.identifier = newIdentifier;
            editorContentsSaved();
        }

        onSaveAnnotationDescriptionRequest: {
            annotationsModel.updateObject(annotationView.identifier, {desc: content});
            editorContentsSaved();
        }
    }

    Components.AnnotationsHistory {
        id: annotationsHistoryComponent
        anchors.fill: parent
        anchors.topMargin: units.fingerUnit * 2
        visible: false
        clip: true

        onHideHistory: annotationView.hideHistory()

        onAnnotationSelected: {
            annotationView.identifier = title;
            annotationView.showSingleAnnotation();
        }
    }

    function closeAnnotationsList() {
        // Restore buttons and hide the related annotations
        annotationView.popButtonsModel();
    }

    function loadEditorComponent(page) {
        var args = {};
        args['identifier'] = annotationView.identifier;
        args['content'] = editContent;
        setSource('qrc:///modules/annotations/' + page + '.qml', args);
    }

    function openNewAnnotation() {
        console.log('labels',mainItem.labels);
        annotationView.labels = mainItem.labels;
        showNewAnnotation();
    }

    function prepareAnnotationsList(parameters) {
        // Change buttons
        annotationView.pushButtonsModel();
        annotationView.buttonsModel.append({icon: 'list-153185', object: annotationView, method: 'showHistory'});
        annotationView.buttonsModel.append({icon: 'plus-24844', object: annotationView, method: 'openNewAnnotation'});
        annotationView.buttonsModel.append({icon: 'road-sign-147409', object: annotationView, method: 'showSingleAnnotation'});

        // Show related annotations
        annotationView.setSource('qrc:///components/RelatedAnnotations.qml', parameters);
    }

    function prepareAnnotationPartEditor() {
        annotationView.pushButtonsModel();
        annotationView.buttonsModel.append({icon: 'floppy-35952', object: annotationView, method: 'saveAnnotationEditorContents'});
        annotationView.buttonsModel.append({icon: 'road-sign-147409', object: annotationView, method: 'editorContentsDeclined'});
    }

    function saveAnnotationEditorContents() {
        console.log('Saving', mainItem.annotationContent);
        for (var prop in mainItem.annotationContent) {
            console.log(prop, '=>', mainItem.annotationContent[prop]);
        }

        annotationsModel.updateObject(annotationView.identifier, mainItem.annotationContent);
        if ('title' in mainItem.annotationContent) {
            identifier = mainItem.annotationContent['title'];
        }

        editorContentsSaved();
    }






    MarkDownParser {
        id: parser
    }

    DSM.StateMachine {
        id: annotationStateMachine

        initialState: (identifier == '')?annotationsList:singleAnnotation

        DSM.State {
            id: singleAnnotation

            onEntered: {
                annotationsHistoryComponent.addAnnotation(annotationView.identifier);
                annotationView.setSource('qrc:///components/ShowAnnotation.qml', {identifier: annotationView.identifier});

                annotationView.pushButtonsModel();
                annotationView.buttonsModel.append({icon: 'hierarchy-35795', object: annotationView, method: 'showAnnotationsList'});
                annotationView.buttonsModel.append({icon: 'copy-97584', object: mainItem, method: 'copyAnnotationDescription'});
                annotationView.buttonsModel.append({icon: 'list-153185', object: annotationView, method: 'showHistory'});

                mainItem.getText();
            }

            onExited: {
                annotationView.popButtonsModel();
            }

            DSM.SignalTransition {
                signal: annotationView.showSingleAnnotation
                targetState: singleAnnotation
            }

            DSM.SignalTransition {
                signal: annotationView.showAnnotationsList
                targetState: annotationsList
            }

            DSM.SignalTransition {
                signal: annotationView.showRelatedAnnotationsByLabels
                targetState: relatedAnnotationsByLabels
            }

            DSM.SignalTransition {
                signal: annotationView.showRelatedAnnotationsByPeriod
                targetState: relatedAnnotationsByPeriod
            }

            DSM.SignalTransition {
                signal: openAttachmentsPage
                targetState: attachmentsState
            }

            DSM.SignalTransition {
                signal: annotationView.showHistory
                targetState: annotationsHistory
            }

            DSM.SignalTransition {
                signal: annotationView.showNewAnnotation
                targetState: addAnnotation
            }

            DSM.SignalTransition {
                signal: annotationView.newRubricAssessment
                targetState: addRubricAssessment
            }

            DSM.SignalTransition {
                signal: annotationView.changeAnnotationTitle
                targetState: titleEditorState
            }

            DSM.SignalTransition {
                signal: annotationView.changeAnnotationDescription
                targetState: descEditorState
            }

            DSM.SignalTransition {
                signal: annotationView.changeAnnotationPeriod
                targetState: periodEditor
            }

            DSM.SignalTransition {
                signal: annotationView.changeAnnotationLabels
                targetState: labelsEditor
            }

            DSM.SignalTransition {
                signal: annotationView.changeAnnotationState
                targetState: stateEditor
            }
        }

        DSM.State {
            id: annotationsList

            onEntered: {
                prepareAnnotationsList({labelBase: '', labels: '', mainIdentifier: annotationView.identifier});
            }

            onExited: {
                closeAnnotationsList();
            }

            DSM.SignalTransition {
                signal: annotationView.showSingleAnnotation
                targetState: singleAnnotation
            }

            DSM.SignalTransition {
                signal: annotationView.showHistory
                targetState: annotationsHistory
            }

            DSM.SignalTransition {
                signal: annotationView.showNewAnnotation
                targetState: addAnnotation
            }
        }

        DSM.State {
            id: relatedAnnotationsByLabels

            onEntered: {
                prepareAnnotationsList({labelBase: '', labels: annotationView.labels, initialState: 'labels', mainIdentifier: annotationView.identifier});
            }
            onExited: {
                closeAnnotationsList();
            }

            DSM.SignalTransition {
                targetState: singleAnnotation
                signal: annotationView.showSingleAnnotation
            }
        }

        DSM.State {
            id: relatedAnnotationsByPeriod
            onEntered: {
                prepareRelatedAnnotations({labelBase: '', labels: annotationView.labels, initialState: 'pending', mainIdentifier: annotationView.identifier});
            }
            onExited: {
                closeAnnotationsList();
            }

            DSM.SignalTransition {
                targetState: singleAnnotation
                signal: annotationView.hideRelatedAnnotations
            }
        }

        DSM.State {
            id: annotationsHistory

            onEntered: {
                annotationsHistoryComponent.visible = true;
                annotationView.pushButtonsModel();
                annotationView.buttonsModel.append({icon: 'road-sign-147409', object: annotationView, method: 'hideHistory'});
            }

            onExited: {
                annotationsHistoryComponent.visible = false;
                annotationView.popButtonsModel();
            }

            DSM.SignalTransition {
                targetState: singleAnnotation
                signal: annotationView.showSingleAnnotation
            }

            DSM.SignalTransition {
                targetState: historyState
                signal: annotationView.hideHistory
            }
        }

        DSM.HistoryState {
            id: historyState
            defaultState: singleAnnotation
        }

        DSM.State {
            id: addAnnotation

            onEntered: {
                annotationView.pushButtonsModel();

                annotationView.setSource('qrc:///components/NewAnnotation.qml', {labels: annotationView.labels});

                annotationView.buttonsModel.append({icon: 'floppy-35952', object: mainItem, method: 'saveNewAnnotation'});
                annotationView.buttonsModel.append({icon: 'questionnaire-158862', object: mainItem, method: 'newIntelligentAnnotation'});
                annotationView.buttonsModel.append({icon: 'calendar-23684', object: mainItem, method: 'newTimetableAnnotation'});
                annotationView.buttonsModel.append({icon: 'upload-25068', object: mainItem, method: 'importAnnotations'});
                annotationView.buttonsModel.append({icon: 'road-sign-147409', object: annotationView, method: 'closeNewAnnotation'});
            }

            onExited: {
                annotationView.popButtonsModel();
            }

            DSM.SignalTransition {
                targetState: singleAnnotation
                signal: annotationView.showSingleAnnotation
            }
            DSM.SignalTransition {
                targetState: historyState
                signal: annotationView.editorContentsDeclined || annotationView.closeNewAnnotation
            }
            DSM.SignalTransition {
                targetState: historyState
                signal: annotationView.closeNewAnnotation
            }
        }

        DSM.State {
            id: addRubricAssessment

            onEntered: {
                annotationView.pushButtonsModel();
                console.log('ARA');
                annotationView.setSource('qrc:///components/AddRubricAssessmentComponent.qml', {annotation: identifier});
                annotationView.buttonsModel.append({icon: 'road-sign-147409', object: annotationView, method: 'closeNewRubricAssessment'});
            }

            onExited: {
                annotationView.popButtonsModel();
            }

            DSM.SignalTransition {
                targetState: historyState
                signal: annotationView.closeNewRubricAssessment
            }
        }

        DSM.State {
            id: titleEditorState

            onEntered: {
                openSuperposedMenu(lastItemSelected, annotationView.width, units.fingerUnit * 4, 'qrc:///modules/annotations/TitleEditorComponent.qml', {identifier: annotationView.identifier, content: annotationView.identifier});
            }

            onExited: {
                closeSuperposedMenu();
            }

            DSM.SignalTransition {
                signal: annotationView.editorContentsSaved
                targetState: singleAnnotation
            }
            DSM.SignalTransition {
                signal: annotationView.editorContentsDeclined
                targetState: historyState
            }
        }

        DSM.State {
            id: descEditorState

            onEntered: {
                openSuperposedMenu(lastItemSelected, annotationView.width, height / 2, 'qrc:///modules/annotations/DescriptionEditorComponent.qml', {identifier: annotationView.identifier, content: annotationView.editContent});
            }

            onExited: {
                closeSuperposedMenu();
            }

            DSM.SignalTransition {
                signal: annotationView.editorContentsSaved
                targetState: singleAnnotation
            }
            DSM.SignalTransition {
                signal: annotationView.editorContentsDeclined
                targetState: historyState
            }
        }

        DSM.State {
            id: periodEditor

            onEntered: {
                prepareAnnotationPartEditor();
                loadEditorComponent('PeriodEditorComponent');
            }

            onExited: {
                annotationView.popButtonsModel();
            }

            DSM.SignalTransition {
                signal: annotationView.editorContentsSaved
                targetState: singleAnnotation
            }
            DSM.SignalTransition {
                signal: annotationView.editorContentsDeclined
                targetState: historyState
            }
        }

        DSM.State {
            id: labelsEditor

            onEntered: {
                prepareAnnotationPartEditor();
                loadEditorComponent('LabelsEditorComponent');
            }

            onExited: {
                annotationView.popButtonsModel();
            }

            DSM.SignalTransition {
                signal: annotationView.editorContentsSaved
                targetState: singleAnnotation
            }
            DSM.SignalTransition {
                signal: annotationView.editorContentsDeclined
                targetState: historyState
            }
        }

        DSM.State {
            id: stateEditor

            onEntered: {
                prepareAnnotationPartEditor();
                loadEditorComponent('AnnotationStateEditorComponent');
            }

            onExited: {
                annotationView.popButtonsModel();
            }

            DSM.SignalTransition {
                signal: annotationView.editorContentsSaved
                targetState: singleAnnotation
            }
            DSM.SignalTransition {
                signal: annotationView.editorContentsDeclined
                targetState: historyState
            }
        }

        DSM.State {
            id: attachmentsState

            onEntered: {
                pushButtonsModel();
                setSource('qrc:///components/AnnotationAttachedItems.qml', {annotation: annotationView.identifier});
                buttonsModel.append({icon: 'road-sign-147409', object: annotationView, method: 'closeCurrentPage'});
            }

            onExited: {
                popButtonsModel();
            }

            DSM.SignalTransition {
                signal: newRubricAssessment
                targetState: addRubricAssessment
            }

            DSM.SignalTransition {
                signal: closeCurrentPage
                targetState: singleAnnotation
            }
        }
    }

    Component.onCompleted: {
        annotationStateMachine.start();
    }
}

