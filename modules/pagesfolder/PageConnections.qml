import QtQuick 2.7
import QtQuick.Controls 2.0

Connections {
    property Item destination
    property Item primarySource
    property StackView stack

    ignoreUnknownSignals: true

    onAnnotationsListSelected2: destination.addPage('annotations2/AnnotationsList', {interactive: true}, qsTr("Anotacions"))
    onAnnotationSelected: {
        destination.addPage('annotations2/ShowAnnotation', {identifier: annotation}, qsTr('Anotació'));
    }

    onAnnotationsOnDateSelected: {
        destination.addPage('annotations2/AnnotationsList', {periodStart: start, periodEnd: end, filterPeriod: true}, qsTr('Anotacions a una data'));
    }

    onPlanningItemsSelected: {
        if (typeof list !== 'undefined') {
            destination.addPage('plannings/PlanningItems', {planning: title, list: list}, qsTr("Planificacions de llista"));
        } else {
            destination.addPage('plannings/PlanningItems', {planning: title}, qsTr("Planificacions"));
        }
    }

    onPlanningsOnDateSelected: {
        destination.addPage('plannings/SessionsListByDates', {periodStart: start, periodEnd: end}, qsTr("Planificacions a una data"));
    }

    onChecklistsSelected: {
        destination.addPage('checklists/AssessmentSystem', {}, qsTr("Valoracions"));
    }

    onDateSelected: {
        var dateObject = new Date(fullyear, month, date, 0, 0, 0, 0);
        var startDateString = dateObject.toYYYYMMDDFormat();
        dateObject.setDate(dateObject.getDate()+1);
        var endDateString = dateObject.toYYYYMMDDFormat();
        console.log('date selected', startDateString, endDateString);
        destination.addPage('annotations2/AnnotationsList', {interactive: true, periodStart: startDateString, periodEnd: endDateString, filterPeriod: true}, qsTr("Anotacions dins rang de dates"));
    }
    onDocumentSelected: destination.addPage('documents/ShowDocument', {document: document}, qsTr('Document'));
    onDocumentSourceSelected: destination.addPage('files/FileViewer', {fileURL: source}, qsTr('Visor de fitxer'));

    onEditorRequested: {
        destination.addPage('whiteboard/ImageBoard', {selectedFile: file}, qsTr("Editor d'imatge"));
    }
    onImageViewerSelected: destination.addPage('files/FileViewer', {fileURL: file}, qsTr("Visor de fitxer"));

    onPlanningAllSessionsSelected: {
        destination.addPage('plannings/ShowPlanning', {planning: title}, qsTr("Sessions de planificació"));
    }

    onPlanningSelected: {
        destination.addPage('plannings/ActionsByDateAndContext', {planning: title}, qsTr("Planificació"));
    }
    onSessionSelected: destination.addPage('plannings/ShowSession', {session: session}, qsTr("Sessió de planificació"));

    onUpdated: {
        console.log('object name', primarySource.objectName);
        if (stack.depth>1) {
//            console.log('invocating receive updated');
//            var sourceObj = stack.get(stack.depth-1);
//            sourceObj.receiveUpdated(object);
        }
    }

    onGallerySelected: {
        console.log('sourceRoot', sourceRoot);
        destination.addPage('files/Gallery', {folder: sourceRoot});
    }

    // Work flows

    onWorkFlowsListSelected: {
        destination.addPage('workflow/WorkFlowsList', {});
    }

    onWorkFlowSelected: {
        destination.addPage('workflow/ShowWorkFlow', {identifier: title});
    }

    onWorkFlowAnnotationSelected: {
        destination.addPage('workflow/ShowAnnotation', {identifier: annotation});
    }

    /*
    onGotoPrevious: {
        //primarySource.gotoPrevious();
    }
    onGotoNext: {
        //primarySource.gotoNext();
    }
    */
}
