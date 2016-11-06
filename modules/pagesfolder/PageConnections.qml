import QtQuick 2.7
import QtQuick.Controls 1.4

Connections {
    property Item destination
    property Item primarySource
    property StackView stack

    ignoreUnknownSignals: true

    onAnnotationsListSelected2: destination.addPage('annotations2/AnnotationsList', {interactive: true})
    onAnnotationSelected: destination.addPage('annotations2/ShowAnnotation', {identifier: annotation});

    onAnnotationsOnDateSelected: {
        destination.addPage('annotations2/AnnotationsList', {periodStart: start, periodEnd: end, filterPeriod: true});
    }

    onPlanningsOnDateSelected: {
        destination.addPage('plannings/SessionsListByDates', {periodStart: start, periodEnd: end});
    }

    onDateSelected: {
        var dateObject = new Date(fullyear, month, date, 0, 0, 0, 0);
        var startDateString = dateObject.toYYYYMMDDFormat();
        dateObject.setDate(dateObject.getDate()+1);
        var endDateString = dateObject.toYYYYMMDDFormat();
        console.log('date selected', startDateString, endDateString);
        destination.addPage('annotations2/AnnotationsList', {interactive: true, periodStart: startDateString, periodEnd: endDateString, filterPeriod: true});
    }
    onDocumentSelected: destination.addPage('documents/ShowDocument', {document: document});
    onDocumentSourceSelected: destination.addPage('files/FileViewer', {fileURL: source});

    onEditorRequested: {
        destination.addPage('whiteboard/ImageBoard', {selectedFile: file});
    }
    onImageViewerSelected: destination.addPage('files/FileViewer', {fileURL: file});

    onPlanningSelected: destination.addPage('plannings/ShowPlanning', {planning: title});
    onSessionSelected: destination.addPage('plannings/ShowSession', {session: session});

    onUpdated: {
        console.log('object name', primarySource.objectName);
        if (stack.depth>1) {
//            console.log('invocating receive updated');
//            var sourceObj = stack.get(stack.depth-1);
//            sourceObj.receiveUpdated(object);
        }
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
