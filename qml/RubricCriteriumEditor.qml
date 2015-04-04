import QtQuick 2.0
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common

ItemInspector {
    id: rubricCriteriumItem
    pageTitle: qsTr('Edita criteri de rúbrica')

    property int idCriterium: -1
    property int rubric
    property string title: ''
    property string desc: ''
    property int ord: -1
    property int weight: 1
    property SqlTableModel criteriaModel

    signal savedCriterium

    property int idxRubric
    property int idxTitle
    property int idxDesc
    property int idxOrd
    property int idxWeight

    Component.onCompleted: {
        addSection(qsTr('Criteri'), rubricCriteriumItem.idCriterium,'yellow',editorType['None']);
        idxRubric = addSection(qsTr('Rúbrica'), rubricCriteriumItem.rubric,'yellow',editorType['None']);
        idxTitle = addSection(qsTr('Títol'), rubricCriteriumItem.title,'yellow',editorType['TextLine']);
        idxDesc = addSection(qsTr('Descripció'), rubricCriteriumItem.desc,'yellow',editorType['TextArea']);
        idxOrd = addSection(qsTr('Ordre'), rubricCriteriumItem.ord, 'green',editorType['TextLine']);
        idxWeight = addSection(qsTr('Pes'), rubricCriteriumItem.weight, 'green',editorType['TextLine']);
    }

    onSaveDataRequested: {
        rubricCriteriumItem.title = getContent(idxTitle);
        rubricCriteriumItem.desc = getContent(idxDesc);
        rubricCriteriumItem.ord = getContent(idxOrd);
        rubricCriteriumItem.weight = getContent(idxWeight);

        console.log(idCriterium + '-' + rubric + '--' + ord);
        var object = {
            rubric: rubricCriteriumItem.rubric,
            title: rubricCriteriumItem.title,
            desc: rubricCriteriumItem.desc,
            ord: rubricCriteriumItem.ord,
            weight: rubricCriteriumItem.weight
        }

        if (idCriterium == -1) {
            criteriaModel.insertObject(object);
        } else {
            console.log('updating ');

            object['id'] = idCriterium;
            if (criteriaModel.updateObject(object))
                console.log('DONE');
            else
                console.log('NOT Done');
            for (var prop in object) {
                console.log(prop + '-' + object[prop]);
            }
        }
        rubricCriteriumItem.setChanges(false);
        rubricCriteriumItem.savedCriterium();
    }

    onCopyDataRequested: {}
    onDiscardDataRequested: {}
    onClosePageRequested: {}
}
