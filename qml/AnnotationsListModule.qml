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
import 'qrc:///modules/annotations' as AnnotationsComponents
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
    signal rubricSelected(string assessment)

    signal saveNewAnnotation()
    signal showAnnotationsList()
    signal showNewAnnotation()
    signal showRelatedAnnotationsByLabels()
    signal showRelatedAnnotationsByPeriod()
    signal showSingleAnnotation()
    signal showHistory()

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

        onAnnotationStateSelected: {
            editContent = stateValue;
            annotationView.changeAnnotationState();
        }

        onAnnotationTitleSelected: {
            editContent = annotationSM.identifier;
            lastItemSelected = widget;
            annotationView.changeAnnotationTitle();
        }

        onAttachmentsSelected: {
            console.log('select');
            openAttachmentsPage();
        }

        onCloseNewRubricAssessment: annotationView.closeNewRubricAssessment()

        onNewAnnotation: {
            console.log('labels',mainItem.labels);
            annotationView.labels = mainItem.labels;
            lastItemSelected = annotationView;
            showNewAnnotation();
        }

        onNewRubricAssessment: {
            annotationSM.identifier = annotation;
            annotationView.newRubricAssessment();
        }

        onRubricAssessmentSelected: {
            console.log('---');
            annotationSM.assessment = assessment;
            annotationSM.openRubricAssessment();
        }

    }

    Connections {
        target: subItem

        ignoreUnknownSignals: true

        onCloseNewAnnotation: {
            closeSuperposedMenu();
            annotationView.closeNewAnnotation();
        }

        onCloseNewRubricAssessment: {
            closeSuperposedMenu();
            annotationSM.superposedMenuClosed();
        }

        onNewTimetableAnnotationSelected: {
            openSuperposedMenu(lastItemSelected, width, height, 'qrc:///modules/annotations/NewAnnotationFromTimetable.qml', {labels: labels});
        }

        onSaveAnnotationTitleRequest: {
            console.log('content', content);
            var newIdentifier = content;
            annotationsModel.updateObject(annotationSM.identifier, {title: newIdentifier});
            annotationSM.identifier = newIdentifier;
            editorContentsSaved();
        }

        onSaveAnnotationDescriptionRequest: {
            annotationsModel.updateObject(annotationSM.identifier, {desc: content});
            editorContentsSaved();
        }
    }

    AnnotationsComponents.AnnotationsHistory {
        id: annotationsHistoryComponent
        anchors.fill: parent
        anchors.topMargin: units.fingerUnit * 2
        visible: false
        clip: true

        onHideHistory: annotationView.hideHistory()

        onAnnotationSelected: {
            annotationSM.identifier = title;
            annotationView.showSingleAnnotation();
        }
    }

    function closeAnnotationsList() {
        // Restore buttons and hide the related annotations
        annotationView.popButtonsModel();
    }

    function loadEditorComponent(page) {
        var args = {};
        args['identifier'] = annotationSM.identifier;
        args['content'] = editContent;
        setSource('qrc:///modules/annotations/' + page + '.qml', args);
    }

    function prepareAnnotationsList(parameters) {
        // Change buttons
        annotationView.pushButtonsModel();
        annotationView.buttonsModel.append({icon: 'list-153185', object: annotationView, method: 'showHistory'});
        annotationView.buttonsModel.append({icon: 'road-sign-147409', object: annotationView, method: 'showSingleAnnotation'});

        // Show related annotations
        annotationView.setSource('qrc:///modules/annotations/RelatedAnnotations.qml', parameters);
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

        annotationsModel.updateObject(annotationSM.identifier, mainItem.annotationContent);
        if ('title' in mainItem.annotationContent) {
            identifier = mainItem.annotationContent['title'];
        }

        editorContentsSaved();
    }






    MarkDownParser {
        id: parser
    }

    DSM.StateMachine {
        id: annotationSM

        initialState: (identifier == '')?annotationsListState:singleAnnotationState

        // Shared variables

        property string identifier: ''
        property int assessment: -1

        // Internal signals

        // * Must be moved here

        signal openRubricAssessment()
        signal superposedMenuClosed()

        DSM.State {
            id: singleAnnotationState

            onEntered: {
                annotationsHistoryComponent.addAnnotation(annotationSM.identifier);
                annotationView.setSource('qrc:///modules/annotations/ShowAnnotation.qml', {identifier: annotationSM.identifier});

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
                targetState: singleAnnotationState
            }

            DSM.SignalTransition {
                signal: annotationView.showAnnotationsList
                targetState: annotationsListState
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
                signal: annotationSM.openRubricAssessment
                targetState: openRubricAssessmentState
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
            id: annotationsListState

            onEntered: {
                prepareAnnotationsList({labelBase: '', labels: '', mainIdentifier: annotationSM.identifier});
            }

            onExited: {
                annotationSM.identifier = mainItem.mainIdentifier;
                closeAnnotationsList();
            }

            DSM.SignalTransition {
                signal: mainItem.annotationSelected
                // signal: annotationView.showSingleAnnotation
                targetState: singleAnnotationState
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
            id: dummyState
            onEntered: {
                console.log('DUMMY');
            }
        }

        DSM.State {
            id: relatedAnnotationsByLabels

            onEntered: {
                prepareAnnotationsList({labelBase: '', labels: annotationView.labels, initialState: 'labels', mainIdentifier: annotationSM.identifier});
            }
            onExited: {
                closeAnnotationsList();
            }

            DSM.SignalTransition {
                signal: annotationView.showSingleAnnotation
                targetState: singleAnnotationState
            }
        }

        DSM.State {
            id: relatedAnnotationsByPeriod
            onEntered: {
                prepareRelatedAnnotations({labelBase: '', labels: annotationView.labels, initialState: 'pending', mainIdentifier: annotationSM.identifier});
            }
            onExited: {
                closeAnnotationsList();
            }

            DSM.SignalTransition {
                targetState: singleAnnotationState
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
                targetState: singleAnnotationState
                signal: annotationView.showSingleAnnotation
            }

            DSM.SignalTransition {
                targetState: historyState
                signal: annotationView.hideHistory
            }
        }

        DSM.HistoryState {
            id: historyState
            defaultState: singleAnnotationState
        }

        DSM.State {
            id: addAnnotation

            onEntered: {
                openSuperposedMenu(lastItemSelected, width, units.fingerUnit * 8, 'qrc:///modules/annotations/NewAnnotation.qml', {labels: annotationView.labels});
            }

            onExited: {
                closeSuperposedMenu();
            }

            DSM.SignalTransition {
                targetState: singleAnnotationState
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
                openSuperposedMenu(annotationView, width, height, 'qrc:///components/AddRubricAssessmentComponent.qml', {annotation: annotationSM.identifier});
            }

            onExited: {
                closeSuperposedMenu();
            }

            DSM.SignalTransition {
                signal: annotationSM.superposedMenuClosed
                targetState: historyState
            }
        }

        DSM.State {
            id: titleEditorState

            onEntered: {
                openSuperposedMenu(lastItemSelected, annotationView.width, units.fingerUnit * 4, 'qrc:///modules/annotations/TitleEditorComponent.qml', {identifier: annotationSM.identifier, content: annotationSM.identifier});
            }

            onExited: {
                closeSuperposedMenu();
            }

            DSM.SignalTransition {
                signal: annotationView.editorContentsSaved
                targetState: singleAnnotationState
            }
            DSM.SignalTransition {
                signal: annotationView.editorContentsDeclined
                targetState: historyState
            }
        }

        DSM.State {
            id: descEditorState

            onEntered: {
                openSuperposedMenu(lastItemSelected, annotationView.width, height / 2, 'qrc:///modules/annotations/DescriptionEditorComponent.qml', {identifier: annotationSM.identifier, content: annotationView.editContent});
            }

            onExited: {
                closeSuperposedMenu();
            }

            DSM.SignalTransition {
                signal: annotationView.editorContentsSaved
                targetState: historyState
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
                targetState: singleAnnotationState
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
                targetState: singleAnnotationState
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
                targetState: singleAnnotationState
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
                setSource('qrc:///components/AnnotationAttachedItems.qml', {annotation: annotationSM.identifier});
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
                targetState: singleAnnotationState
            }
        }

        DSM.FinalState {
            id: openRubricAssessmentState

            onEntered: {
                annotationView.rubricSelected(annotationSM.assessment);
            }
        }
    }

    Component.onCompleted: {
        annotationSM.start();
    }
}

