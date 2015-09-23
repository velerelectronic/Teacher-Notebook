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

    model: ObjectModel {
        EditTextItemInspector {
            id: titleComponent
            width: rubricAssessmentEditor.width
            caption: qsTr('Títol')
        }
        EditTextAreaInspector {
            id: descComponent
            width: rubricAssessmentEditor.width
            caption: qsTr('Descripció')
        }
        EditListItemInspector {
            id: rubricComponent
            width: rubricAssessmentEditor.width
            caption: qsTr('Rúbrica')
        }
        EditListItemInspector {
            id: groupComponent
            width: rubricAssessmentEditor.width
            caption: qsTr('Grup')
        }
        EditListItemInspector {
            id: eventComponent
            width: rubricAssessmentEditor.width
            caption: qsTr('Esdeveniment')
            onPerformSearch: eventsModel.searchString = searchString
            onAddRow: {
                var today = new Date();
                var day = today.toYYYYMMDDFormat();
                showEvent({event: qsTr('[AutoGenerat]') + ((titleComponent.editedContent !== '')?' ':'') + titleComponent.editedContent + ' ' + groupComponent.editedContent['reference'], startDate: day, endDate: day});
            }
        }
    }

    Component.onCompleted: {
        groupsModel.select();
        rubricsModel.select();
        eventsModel.select();

        var obj = rubricsAssessmentModel.getObject(idAssessment);
        var str = coalesce(obj['title'],'');
        console.log('STR' + str);
        titleComponent.originalContent = str;
        descComponent.originalContent = coalesce(obj['desc'],'');
        rubricAssessmentEditor.event = obj['event'];

        console.log('Rubric ' + rubricAssessmentEditor.rubric);
        console.log(coalesce(obj['rubric'],-1));

        rubricComponent.originalContent = {
            reference: (rubricAssessmentEditor.rubric !== -1)?rubricAssessmentEditor.rubric:coalesce(obj['rubric'],-1),
            valued: false,
            model: rubricsModel,
            nameAttribute: 'title'
        };
        groupComponent.originalContent = {
            reference: (rubricAssessmentEditor.group === '')?rubricAssessmentEditor.group:coalesce(obj['group'],''),
            value: coalesce(obj['group']),
            valued: true,
            model: groupsModel,
            nameAttribute: 'group'
        };
        eventComponent.originalContent = {
            reference: rubricAssessmentEditor.event, // (rubricAssessmentEditor.event !== -1)?rubricAssessmentEditor.event:coalesce(obj['event'],-1),
            valued: false,
            model: eventsModel,
            nameAttribute: 'event'
        };
    }

    onSaveDataRequested: {
        var object = {
            title: titleComponent.editedContent,
            desc: descComponent.editedContent,
            rubric: rubricComponent.editedContent.reference,
            group: groupComponent.editedContent.reference,
            event: eventComponent.editedContent.reference
        }

        if (idAssessment == -1) {
            rubricsAssessmentModel.insertObject(object);
        } else {
            object['id'] = idAssessment;
            rubricsAssessmentModel.updateObject(object);
        }
        rubricAssessmentEditor.setChanges(false);
        rubricAssessmentEditor.savedRubricAssessment();
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
