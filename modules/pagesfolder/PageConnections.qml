import QtQuick 2.7

Connections {
    property Item destination
    property Item primarySource

    ignoreUnknownSignals: true

    onAnnotationsListSelected2: destination.addPage('annotations2/AnnotationsList', {interactive: true})
    onAnnotationSelected: destination.addPage('annotations2/ShowAnnotation', {identifier: annotation});
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
    /*
    onGotoPrevious: {
        //primarySource.gotoPrevious();
    }
    onGotoNext: {
        //primarySource.gotoNext();
    }
    */
}
