import QtQuick 2.0
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common

ItemInspector {
    id: rubricCriteriumItem
    pageTitle: qsTr('Edita nivell de rúbrica')

    property int idLevel: -1
    property int rubric
    property string title: ''
    property string desc: ''
    property int score: -1

    signal savedLevel

    property int idxTitle
    property int idxDesc
    property int idxScore

    property SqlTableModel levelsModel

    Component.onCompleted: {
        addSection(qsTr('Nivell'), rubricCriteriumItem.idLevel,'yellow',editorType['None']);
        addSection(qsTr('Rúbrica'), rubricCriteriumItem.rubric,'yellow',editorType['None']);

        idxTitle = addSection(qsTr('Títol'), rubricCriteriumItem.title,'yellow',editorType['TextLine']);
        idxDesc = addSection(qsTr('Descripció'), rubricCriteriumItem.desc,'yellow',editorType['TextArea']);
        idxScore = addSection(qsTr('Puntuació'), rubricCriteriumItem.score, 'yellow',editorType['TextLine']);
    }

    onSaveDataRequested: {
        rubricCriteriumItem.title = getContent(idxTitle);
        rubricCriteriumItem.desc = getContent(idxDesc);
        rubricCriteriumItem.score = getContent(idxScore);

        var object = {
            rubric: rubricCriteriumItem.rubric,
            title: rubricCriteriumItem.title,
            desc: rubricCriteriumItem.desc,
            score: rubricCriteriumItem.score
        }

        if (idLevel == -1) {
            levelsModel.insertObject(object);
        } else {
            object['id'] = idLevel;
            if (levelsModel.updateObject(object))
                console.log('DONE');
            else
                console.log('NOT Done');
            for (var prop in object) {
                console.log(prop + '-' + object[prop]);
            }
        }
        rubricCriteriumItem.setChanges(false);
        rubricCriteriumItem.savedLevel();
    }

    onCopyDataRequested: {}
    onDiscardDataRequested: {}
    onClosePageRequested: {}
}
