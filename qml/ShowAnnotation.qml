import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import "qrc:///javascript/Storage.js" as Storage

ItemInspector {
    id: annotationEditor
    pageTitle: qsTr("Editor d'anotacions")

    signal savedAnnotation(string annotation, string desc)
    signal canceledAnnotation(bool changes)

    property int idAnnotation: -1
    property string annotation: ''
    property string desc: ''

    property int idxAnnotation
    property int idxDesc

    Common.UseUnits { id: units }

    onSaveDataRequested: {
        prepareDataAndSave(idAnnotation);
        annotationEditor.setChanges(false);
        annotationEditor.savedAnnotation(annotation,desc);
    }

    onCopyDataRequested: {
        prepareDataAndSave(-1);
        annotationEditor.setChanges(false);
        annotationEditor.savedAnnotation(annotation,desc);
    }

    onDiscardDataRequested: {
        annotationEditor.canceledAnnotation(changes);
    }

    function prepareDataAndSave(idCode) {
        annotation = getContent(idxAnnotation);
        desc = getContent(idxDesc);
        Storage.saveAnnotation(idCode,annotation,desc);
    }

    Component.onCompleted: {
        if (annotationEditor.idAnnotation != -1) {
            var details = Storage.getDetailsAnnotationId(annotationEditor.idAnnotation);
            annotationEditor.annotation = details.title;
            annotationEditor.desc = details.desc;
            annotationEditor.setChanges(false);
        }
        idxAnnotation = addSection(qsTr('Anotació'),annotation,'yellow',editorType['TextLine']);
        idxDesc = addSection(qsTr('Descripció'),desc,'yellow',editorType['TextArea']);
    }
}
