import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import 'qrc:///common' as Common
import "qrc:///javascript/Storage.js" as Storage
import PersonalTypes 1.0

CollectionInspector {
    id: annotationEditor
    pageTitle: qsTr("Editor d'anotacions")

    signal closePage(string message)
    signal savedAnnotation(int id,string annotation,string desc)
    signal duplicatedAnnotation(string annotation,string desc)
    signal openCamera(var receiver)

    property int idAnnotation: -1
    property string annotation: ''
    property string desc: ''
    property string image: ''

    Common.UseUnits { id: units }

    onSaveDataRequested: {
        prepareDataAndSave(idAnnotation);
        savedAnnotation(idAnnotation,annotation,desc);
        closePage('');
    }

    onCopyDataRequested: {
        prepareDataAndSave(-1);
        annotationEditor.setChanges(false);
        duplicatedAnnotation(annotation,desc);
    }

    onDiscardDataRequested: {
        if (changes) {
            annotationEditor.closePage(qsTr("S'han descartat els canvis en l'anotació"));
        } else {
            closePage('');
        }
    }

    onClosePageRequested: closePage('')

    function prepareDataAndSave(idCode) {
        var obj = {
            title: titleComponent.editedContent,
            desc: descComponent.editedContent,
            image: imageComponent.editedContent
        };

        if (idCode == -1) {
            annotationsModel['created'] = Storage.currentTime();
            annotationsModel.insertObject(obj);
        } else {
            obj['id'] = idCode;
            annotationsModel.updateObject(obj);
        }
    }

    model: ObjectModel {
        EditTextItemInspector {
            id: titleComponent
            width: annotationEditor.width
            caption: qsTr('Títol')
        }
        EditTextAreaInspector {
            id: descComponent
            width: annotationEditor.width
            caption: qsTr('Descripció')
        }
        EditImageItemInspector {
            id: imageComponent
            width: annotationEditor.width
            caption: qsTr('Imatge')

            onOpenCamera: annotationEditor.openCamera(receiver)
        }
    }

    Component.onCompleted: {
        if (annotationEditor.idAnnotation != -1) {
            var details = annotationsModel.getObject(annotationEditor.idAnnotation);
            titleComponent.originalContent = details.title;
            descComponent.originalContent = (details.desc == null)?'':details.desc;
            imageComponent.originalContent = (details.image == null)?'':details.image;
            annotationEditor.setChanges(false);
        }
    }

    function requestClose() {
        closeItem();
    }
}
