import QtQuick 2.0
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common

ItemInspector {
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

    property int idxTitle
    property int idxDesc
    property int idxRubric
    property int idxGroup
    property int idxEvent

    Component.onCompleted: {
        if (idAssessment > -1) {
            var obj = rubricsAssessmentModel.getObject(idAssessment);
            if ('title' in obj)
                title = obj['title'];
            if ('desc' in obj)
                desc = obj['desc'];
            if ('group' in obj)
                group = obj['group'];
            if ('rubric' in obj)
                rubric = obj['rubric'];
            if ('event' in obj)
                event = obj['event'];
        }

        idxTitle = addSection(qsTr('Títol'), rubricAssessmentEditor.title,'yellow',editorType['TextLine']);
        idxDesc = addSection(qsTr('Descripció'), rubricAssessmentEditor.desc,'yellow',editorType['TextArea']);
        idxRubric = addSection(qsTr('Rúbrica'), {reference: rubricAssessmentEditor.rubric, model: rubricsModel, nameAttribute: 'title'}, 'white', editorType['List']);
        idxGroup = addSection(qsTr('Grup'), {reference: rubricAssessmentEditor.group, valued: true, model: groupsModel, nameAttribute: 'group'}, 'white', editorType['List']);
        idxEvent = addSection(qsTr('Esdeveniment'), {reference: rubricAssessmentEditor.event, model: eventsModel, nameAttribute: 'event'}, 'white', editorType['List']);

        groupsModel.select();
        rubricsModel.select();
        eventsModel.select();
    }

    onSaveDataRequested: {
        rubricAssessmentEditor.title = getContent(idxTitle);
        rubricAssessmentEditor.desc = getContent(idxDesc);

        rubricAssessmentEditor.rubric = getContent(idxRubric).reference;
        rubricAssessmentEditor.group = getContent(idxGroup).reference;
        rubricAssessmentEditor.event = getContent(idxEvent).reference;

        var object = {
            title: rubricAssessmentEditor.title,
            desc: rubricAssessmentEditor.desc,
            rubric: rubricAssessmentEditor.rubric,
            group: rubricAssessmentEditor.group,
            event: rubricAssessmentEditor.event
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
        tableName: 'individuals_list'
        fieldNames: ['id', 'group', 'name', 'surname']
    }

    SqlTableModel {
        id: rubricsModel
        tableName: 'rubrics'
        fieldNames: ['id','title','desc']
    }

    SqlTableModel {
        id: eventsModel
        tableName: 'schedule'
        fieldNames: ['id', 'created', 'event', 'desc', 'startDate', 'startTime', 'endDate', 'endTime', 'state', 'ref']
    }
}
