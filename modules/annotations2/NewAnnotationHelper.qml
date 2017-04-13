import QtQuick 2.5
import 'qrc:///common' as Common
import 'qrc:///models' as Models

NewAnnotation {
    annotationsModel: Models.DocumentAnnotations {
        id: annotationsModel

        Component.onCompleted: select()
    }

    onAnnotationCreated: {
        annotationSelected(annotation);
    }
}
