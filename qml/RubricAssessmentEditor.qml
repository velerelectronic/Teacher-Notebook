import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models

CollectionInspector {
    id: rubricAssessmentEditor
    pageTitle: qsTr('Edita avaluació de rúbrica')

    property int idAssessment: -1
    property string title: ''
    property string desc: ''
    property int rubric: -1
    property string group: ''
    property int event: -1

    property SqlTableModel rubricsAssessmentModel

    signal savedRubricAssessment
    signal showEvent(var parameters)

    function saveOrUpdate(field, contents) {
        var res = false;
        var obj = {};
        obj[field] = contents;

        if (idAssessment == -1) {
            res = rubricsAssessmentModel.insertObject(obj);
            if (res !== '') {
                idAssessment = res;
            }
        } else {
            obj['id'] = idAssessment;
            res = rubricsAssessmentModel.updateObject(obj);
        }
        return res;
    }


    model: ObjectModel {
        EditTextItemInspector {
            id: titleComponent
            width: rubricAssessmentEditor.width
            caption: qsTr('Títol')
            originalContent: rubricAssessmentEditor.title
            onSaveContents: {
                if (saveOrUpdate('title',editedContent))
                    notifySavedContents();
            }
        }
        EditTextAreaInspector {
            id: descComponent
            width: rubricAssessmentEditor.width
            caption: qsTr('Descripció')
            originalContent: rubricAssessmentEditor.desc
            onSaveContents: {
                if (saveOrUpdate('desc',editedContent))
                    notifySavedContents();
            }
        }
        EditListItemInspector {
            id: rubricComponent
            width: rubricAssessmentEditor.width
            caption: qsTr('Rúbrica')
            originalContent: {
                'reference': rubricAssessmentEditor.rubric,
                'valued': false,
                'model': rubricsModel,
                'nameAttribute': 'title'
            }

            onOriginalContentChanged: {
                console.log('New ORIGIAN content', originalContent.reference);
            }

            onSaveContents: {
                if (saveOrUpdate('rubric',editedContent.reference))
                    notifySavedContents();
            }
        }
        EditListItemInspector {
            id: groupComponent
            width: rubricAssessmentEditor.width
            caption: qsTr('Grup')
            originalContent: {
                'reference': rubricAssessmentEditor.group,
                'value': rubricAssessmentEditor.group,
                'valued': true,
                'model': groupsModel,
                'nameAttribute': 'group'
            }

            onSaveContents: {
                if (saveOrUpdate('group',editedContent.reference))
                    notifySavedContents();
            }
        }
        EditListItemInspector {
            id: eventComponent
            width: rubricAssessmentEditor.width
            caption: qsTr('Esdeveniment')
            originalContent: {
                'reference': rubricAssessmentEditor.event,
                'valued': false,
                'model': eventsModel,
                'nameAttribute': 'event'
            }

            onPerformSearch: eventsModel.searchString = searchString
            onAddRow: {
                var today = new Date();
                var day = today.toYYYYMMDDFormat();
                showEvent({event: qsTr('[AutoGenerat]') + ((titleComponent.editedContent !== '')?' ':'') + titleComponent.editedContent + ' ' + groupComponent.editedContent['reference'], startDate: day, endDate: day});
            }
            onSaveContents: {
                if (saveOrUpdate('event',editedContent.reference))
                    notifySavedContents();
            }
        }
    }

    Component.onCompleted: {
        groupsModel.select();
        rubricsModel.select();
        eventsModel.select();

        if (idAssessment !== -1) {
            var obj = rubricsAssessmentModel.getObject(idAssessment);
            rubricAssessmentEditor.title = obj['title'];
            rubricAssessmentEditor.desc = obj['desc'];
            rubricAssessmentEditor.event = obj['event'];
            rubricAssessmentEditor.rubric = obj['rubric'];
            rubricAssessmentEditor.group = obj['group'];
            rubricAssessmentEditor.event = obj['event'];
        }
    }

    onCopyDataRequested: {}
    onDiscardDataRequested: {}
    onClosePageRequested: {}

    SqlTableModel {
        id: groupsModel
        tableName: 'individuals_groups'
        fieldNames: ['group']
        // fieldNames: ['id', 'group', 'name', 'surname']
        //groupBy: '"group"'
    }

    SqlTableModel {
        id: rubricsModel
        tableName: 'rubrics'
        fieldNames: ['id','title','desc']
    }

    Models.ScheduleModel {
        id: eventsModel

        filters: ["ifnull(state,'') != 'done'"]
        searchFields: ['event','desc']
        limit: 20
    }
}
