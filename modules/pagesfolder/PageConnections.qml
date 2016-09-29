import QtQuick 2.0

Connections {
    property Item destination

    ignoreUnknownSignals: true

    onAnnotationsListSelected2: destination.loadPage('annotations2/AnnotationsList', {interactive: true})
    onAnnotationSelected: destination.loadPage('annotations2/ShowAnnotation', {identifier: annotation});
    onDateSelected: {
        var dateString = fullyear + "" + (month<9?'0':'') + (month+1) + "" + (date<10?'0':date);
        console.log(dateString);
        destination.loadPage('annotations2/AnnotationsList', {interactive: true, periodStart: dateString, periodEnd: dateString, filterPeriod: true});
    }
    onDocumentSelected: destination.loadPage('documents/ShowDocument', {document: document});

    onEditorRequested: destination.loadPage('whiteboard/WhiteboardWithZoom', {selectedFile: file});
    onImageViewerSelected: destination.loadPage('files/FileViewer', {fileURL: file});
}
