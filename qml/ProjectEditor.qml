import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models

CollectionInspector {
    id: projectEditor
    pageTitle: qsTr('Edita detalls de projecte')

    property int idProject: -1
    property string name: ''
    property string desc: ''

    signal savedProjectDetails
    signal showCharacteristics(int project)
    signal showEvents(int project)

    function saveOrUpdate(field, contents) {
        var res = false;
        var obj = {};
        obj[field] = contents;

        if (idProject == -1) {
            res = globalProjectsModel.insertObject(obj);
            if (res !== '') {
                idProject = res;
            }
        } else {
            obj['id'] = idProject;
            res = globalProjectsModel.updateObject(obj);
        }
        return res;
    }

    model: ObjectModel {
        EditTextItemInspector {
            id: nameComponent
            width: projectEditor.width
            caption: qsTr('Títol')
            originalContent: projectEditor.name
            onSaveContents: {
                if (saveOrUpdate('name',editedContent))
                    notifySavedContents();
            }
        }
        EditTextAreaInspector {
            id: descComponent
            width: projectEditor.width
            caption: qsTr('Descripció')
            originalContent: projectEditor.desc
            onSaveContents: {
                if (saveOrUpdate('desc',editedContent))
                    notifySavedContents();
            }
        }
        EditFakeItemInspector {
            id: characteristicsComponent
            width: projectEditor.width
            caption: qsTr('Característiques')
            originalContent: qsTr('Hi ha ' + characteristicsModel.count + ' característiques')
            enableSendClick: true
            onSendClick: showCharacteristics(idProject)
        }
        EditFakeItemInspector {
            id: eventsComponent
            width: projectEditor.width
            caption: qsTr('Esdeveniments')
            originalContent: qsTr('Hi ha ' + scheduleModel.count + ' esdeveniments')
            enableSendClick: true
            onSendClick: showEvents(idProject)
        }
    }

    Models.ScheduleModel {
        id: scheduleModel
        filters: ["ref='" + idProject + "'"]
    }

    Models.CharacteristicsModel {
        id: characteristicsModel
        filters: ["ref='" + idProject + "'"]
    }

    Component.onCompleted: {
        var obj = globalProjectsModel.getObject(idProject);

        if (idProject !== -1) {
            projectEditor.name = coalesce(obj['name'],'');
            projectEditor.desc = coalesce(obj['desc'],'');
        }

        characteristicsModel.select();
        scheduleModel.select();
    }

    onCopyDataRequested: {}
    onClosePageRequested: {}
}
