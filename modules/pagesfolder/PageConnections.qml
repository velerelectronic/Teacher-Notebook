import QtQuick 2.7

Connections {
    property Item destination
    property Item primarySource

    ignoreUnknownSignals: true

    onAnnotationsListSelected2: destination.loadPage('annotations2/AnnotationsList', {interactive: true})
    onAnnotationSelected: destination.loadPage('annotations2/ShowAnnotation', {identifier: annotation});
    onDateSelected: {
        var dateObject = new Date(fullyear, month, date, 0, 0, 0, 0);
        var startDateString = dateObject.toYYYYMMDDFormat();
        dateObject.setDate(dateObject.getDate()+1);
        var endDateString = dateObject.toYYYYMMDDFormat();
        console.log('date selected', startDateString, endDateString);
        destination.loadPage('annotations2/AnnotationsList', {interactive: true, periodStart: startDateString, periodEnd: endDateString, filterPeriod: true});
    }
    onDocumentSelected: destination.loadPage('documents/ShowDocument', {document: document});

    onEditorRequested: {
        destination.loadPage('whiteboard/ImageBoard', {selectedFile: file});
        //destination.loadPage('whiteboard/WhiteboardWithZoom', {selectedFile: file});
    }
    onImageViewerSelected: destination.loadPage('files/FileViewer', {fileURL: file});

    onPublishMessage: {
        console.log('publicat dins pageconnections')
        primarySource.publishMessage(message);
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
