import QtQuick 2.0
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common

ItemInspector {
    id: rubricDetailsItem
    pageTitle: qsTr('Edita detalls de rúbrica')

    property int idRubric: -1
    property string title: ''
    property string desc: ''
    property SqlTableModel rubricsModel

    signal savedRubricDetails

    property int idxTitle
    property int idxDesc

    Component.onCompleted: {
        console.log(idRubric);
        var obj = rubricsModel.getObject(idRubric);
        for (var prop in obj) {
            console.log(prop + '--' + obj[prop]);
        }

        if ('title' in obj)
            title = obj['title'];
        if ('desc' in obj)
            desc = obj['desc'];

        addSection(qsTr('Rúbrica'), rubricDetailsItem.idRubric,'yellow',editorType['None']);

        idxTitle = addSection(qsTr('Títol'), rubricDetailsItem.title,'yellow',editorType['TextLine']);
        idxDesc = addSection(qsTr('Descripció'), rubricDetailsItem.desc,'yellow',editorType['TextArea']);
    }

    onSaveDataRequested: {
        rubricDetailsItem.title = getContent(idxTitle);
        rubricDetailsItem.desc = getContent(idxDesc);

        console.log('DESANT')
        var object = {
            title: rubricDetailsItem.title,
            desc: rubricDetailsItem.desc
        }

        if (idRubric == -1) {
            rubricsModel.insertObject(object);
        } else {
            object['id'] = idRubric;
            rubricsModel.updateObject(object);
        }
        rubricDetailsItem.setChanges(false);
        rubricDetailsItem.savedRubricDetails();
    }

    onCopyDataRequested: {}
    onDiscardDataRequested: {}
    onClosePageRequested: {}
}
