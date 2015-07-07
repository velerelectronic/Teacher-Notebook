import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import PersonalTypes 1.0
import 'qrc:///common' as Common

CollectionInspector {
    id: projectEditor
    pageTitle: qsTr('Edita detalls de projecte')

    property int idProject: -1
    property string name: ''
    property string desc: ''
    property SqlTableModel projectsModel

    signal savedProjectDetails

    model: ObjectModel {
        EditTextItemInspector {
            id: nameComponent
            width: projectEditor.width
            caption: qsTr('Títol')
        }
        EditTextAreaInspector {
            id: descComponent
            width: projectEditor.width
            caption: qsTr('Descripció')
        }
    }

    Component.onCompleted: {
        var obj = projectsModel.getObject(idProject);

        nameComponent.originalContent = coalesce(obj['name'],'');
        descComponent.originalContent = coalesce(obj['desc'],'');
    }

    onSaveDataRequested: {
        var object = {
            name: nameComponent.editedContent,
            desc: descComponent.editedContent
        }

        if (idProject == -1) {
            projectsModel.insertObject(object);
        } else {
            object['id'] = idProject;
            projectsModel.updateObject(object);
        }
        projectEditor.setChanges(false);
        projectEditor.savedProjectDetails();
    }

    onCopyDataRequested: {}
    onDiscardDataRequested: {}
    onClosePageRequested: {}
}
