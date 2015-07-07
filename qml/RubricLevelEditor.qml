import QtQuick 2.0
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import QtQml.Models 2.1
import 'qrc:///common' as Common

CollectionInspector {
    id: rubricLevelEditor
    pageTitle: qsTr('Edita nivell de rúbrica')

    property int idLevel: -1
    property int rubric
    property string title: ''
    property string desc: ''
    property int score: -1

    signal savedLevel

    SqlTableModel {
        id: rubricsModel
        tableName: 'rubrics'
        fieldNames: ['id', 'title', 'desc']
    }

    property SqlTableModel levelsModel

    model: ObjectModel {
        EditFakeItemInspector {
            id: rubricComponent
            width: rubricLevelEditor.width
            caption: qsTr('Rúbrica')
        }
        EditTextItemInspector {
            id: titleComponent
            width: rubricLevelEditor.width
            caption: qsTr('Títol')
        }
        EditTextAreaInspector {
            id: descComponent
            width: rubricLevelEditor.width
            caption: qsTr('Descripció')
        }
        EditTextItemInspector {
            id: scoreComponent
            width: rubricLevelEditor.width
            caption: qsTr('Puntuació')
        }
    }

    Component.onCompleted: {
        rubricsModel.select();
        var obj = rubricsModel.getObject(rubricLevelEditor.rubric);
        rubricComponent.originalContent = obj['title'] + ((obj['desc'] !== '')?'\n' + obj['desc']:'');

        titleComponent.originalContent = rubricLevelEditor.title;
        descComponent.originalContent = rubricLevelEditor.desc;
        scoreComponent.originalContent = rubricLevelEditor.score;
    }

    onSaveDataRequested: {
        var object = {
            rubric: rubricLevelEditor.rubric,
            title: titleComponent.editedContent,
            desc: descComponent.editedContent,
            score: scoreComponent.editedContent
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
        setChanges(false);
        savedLevel();
    }

    onCopyDataRequested: {}
    onDiscardDataRequested: {}
    onClosePageRequested: {}
}
