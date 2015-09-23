import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models

CollectionInspector {
    id: attachmentEditor

    pageTitle: qsTr('Adjuncions de recursos')

    property int attachmentId: -1
    property int annotation: -1
    property int resource: -1

    signal newResource()
    signal updatedResourceAttachment(string message)
    signal insertedResourceAttachment(string message)

    Models.DetailedResourcesModel {
        id: resourcesModel

        searchFields: ['resourceTitle','resourceDesc','resourceType','resourceSource']

        onCountChanged: console.log('NEW count ' + count)
        Component.objectName: select()
    }

    model: ObjectModel {
        EditFakeItemInspector {
            id: annotationComponent
            width: attachmentEditor.width
            caption: qsTr('Anotació')
        }

        EditListItemInspector {
            id: resourceComponent
            width: attachmentEditor.width
            caption: qsTr('Recurs')
            onPerformSearch: resourcesModel.searchString = searchString
            onAddRow: newResource()
        }

        EditDeleteItemInspector {
            id: deleteButton
            width: attachmentEditor.width

            enableButton: attachmentId != -1

            buttonCaption: qsTr('Desadjuntar recurs')
            dialogTitle: buttonCaption
            dialogText: qsTr("Desadjuntareu el recurs de l'anotació. Voleu continuar?")

            model: globalResourcesAnnotationsModel
            itemId: attachmentId
            onDeleted: updatedResourceAttachment(qsTr("S'ha desadjuntat el recurs de l'anotació"))
        }
    }

    Connections {
        target: globalResourcesModel
        onUpdated: resourcesModel.select()
    }

    Component.onCompleted: {
        if (attachmentId != -1) {
            var obj = resourcesModel.getObject('id',attachmentId);
            attachmentEditor.annotation = obj['annotationId'];
            attachmentEditor.resource = obj['resourceId'];
            annotationComponent.originalContent = annotation
        }

        resourceComponent.originalContent = {
            reference: attachmentEditor.resource,
            valued: false,
            nameAttribute: 'resourceTitle',
            model: resourcesModel
        }
    }

    onSaveDataRequested: {
        var obj = {
            annotation: attachmentEditor.annotation,
            resource: resourceComponent.editedContent['reference']
        }

        if (attachmentEditor.attachmentId != -1) {
            obj['id'] = attachmentEditor.attachmentId;
            globalResourcesAnnotationsModel.updateObject(obj);
            updatedResourceAttachment(qsTr("S'ha actualitzat l'adjunció de recurs."));
        } else {
            globalResourcesAnnotationsModel.insertObject(obj);
            insertedResourceAttachment(qsTr("S'ha adjuntat un nou recurs a l'anotació."));
        }
    }
}

