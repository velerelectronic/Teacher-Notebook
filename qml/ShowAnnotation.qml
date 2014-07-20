import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import "qrc:///javascript/Storage.js" as Storage
import PersonalTypes 1.0

ItemInspector {
    id: annotationEditor
    pageTitle: qsTr("Editor d'anotacions")

    signal savedAnnotation(string id,string annotation, string desc)
    signal canceledAnnotation(bool changes)

    property int idAnnotation: -1
    property string annotation: ''
    property string desc: ''
    property string image: ''

    property int idxAnnotation
    property int idxDesc
    property int idxImage

    Common.UseUnits { id: units }

    onSaveDataRequested: {
        prepareDataAndSave(idAnnotation);
        annotationEditor.setChanges(false);
        annotationEditor.savedAnnotation(idAnnotation,annotation,desc);
    }

    onCopyDataRequested: {
        prepareDataAndSave(-1);
        annotationEditor.setChanges(false);
        annotationEditor.savedAnnotation(-1,annotation,desc);
    }

    onDiscardDataRequested: {
        annotationEditor.canceledAnnotation(changes);
    }

    function prepareDataAndSave(idCode) {
        annotation = getContent(idxAnnotation);
        desc = getContent(idxDesc);
        image = getContent(idxImage);
        if (idCode == -1) {
            annotationsModel.insertObject({created: Storage.currentTime(), title: annotation, desc: desc, image: image});
        } else {
            annotationsModel.updateObject({id: idCode, title: annotation, desc: desc, image: image});
        }
    }

    Component.onCompleted: {
        if (annotationEditor.idAnnotation != -1) {
            var details = annotationsModel.getObject(annotationEditor.idAnnotation);
            annotationEditor.annotation = details.title;
            annotationEditor.desc = (details.desc == null)?'':details.desc;
            annotationEditor.image = (details.image == null)?'':details.image;
            annotationEditor.setChanges(false);
        }
        idxAnnotation = addSection(qsTr('Anotació'),annotation,'yellow',editorType['TextLine']);
        idxDesc = addSection(qsTr('Descripció'),desc,'yellow',editorType['TextArea']);
        idxImage = addSection(qsTr('Imatge'),image,'yellow',editorType['Image']);
    }
}
