import QtQuick 2.0
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import QtQml.Models 2.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models

CollectionInspector {
    id: rubricLevelEditor
    pageTitle: qsTr('Edita nivell de rúbrica')

    property int idLevel: -1
    property int rubric
    property string title: ''
    property string desc: ''
    property int score: -1

    signal savedLevel


    Models.RubricsModel {
        id: rubricsModel
    }

    property SqlTableModel levelsModel

    function saveOrUpdate() {
        var object = {
            rubric: rubric,
            title: titleComponent.editedContent,
            desc: descComponent.editedContent,
            score: scoreComponent.editedContent
        }

        var res;
        if (idLevel == -1) {
            res = levelsModel.insertObject(object);
            idLevel = res;
        } else {
            object['id'] = idLevel;
            res = levelsModel.updateObject(object);
        }
        if (res)
            levelsModel.select();
        return res;
    }

    model: ObjectModel {
        EditFakeItemInspector {
            id: rubricComponent
            width: rubricLevelEditor.width
            totalCollectionHeight: rubricLevelEditor.totalCollectionHeight
            caption: qsTr('Rúbrica')
        }
        EditTextItemInspector {
            id: titleComponent
            width: rubricLevelEditor.width
            totalCollectionHeight: rubricLevelEditor.totalCollectionHeight
            caption: qsTr('Títol')
            originalContent: rubricLevelEditor.title
            onSaveContents: {
                if (saveOrUpdate())
                    notifySavedContents();
            }
        }
        EditTextAreaInspector {
            id: descComponent
            width: rubricLevelEditor.width
            totalCollectionHeight: rubricLevelEditor.totalCollectionHeight
            caption: qsTr('Descripció')
            originalContent: rubricLevelEditor.desc
            onSaveContents: {
                if (saveOrUpdate())
                    notifySavedContents();
            }
        }
        EditTextItemInspector {
            id: scoreComponent
            width: rubricLevelEditor.width
            totalCollectionHeight: rubricLevelEditor.totalCollectionHeight
            caption: qsTr('Puntuació')
            originalContent: rubricLevelEditor.score
            onSaveContents: {
                if (saveOrUpdate())
                    notifySavedContents();
            }
        }
    }

    Component.onCompleted: {
        rubricsModel.select();
        var obj = rubricsModel.getObject(rubricLevelEditor.rubric);
        rubricComponent.originalContent = obj['title'] + ((obj['desc'] !== '')?'\n' + obj['desc']:'');

        var obj2 = levelsModel.getObject(rubricLevelEditor.idLevel);

        rubricLevelEditor.title = obj2['title'];
        rubricLevelEditor.desc = obj2['desc'];
        rubricLevelEditor.score = obj2['score'];
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
