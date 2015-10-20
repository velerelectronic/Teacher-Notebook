import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models

CollectionInspector {
    id: rubricDescriptorItem
    pageTitle: qsTr('Edita descriptor de rúbrica')

    property int idDescriptor: -1
    property int criterium
    property int level
    property string definition: ''

    property SqlTableModel descriptorsModel


    signal savedDescriptor

    model: ObjectModel {
        EditFakeItemInspector {
            id: criteriumComponent
            width: rubricDescriptorItem.width
            caption: qsTr('Criteri')
        }
        EditFakeItemInspector {
            id: levelComponent
            width: rubricDescriptorItem.width
            caption: qsTr('Nivell')
        }
        EditTextAreaInspector {
            id: definitionComponent
            width: rubricDescriptorItem.width
            caption: qsTr('Definició')
            onSaveContents: {
                var res = false;

                var obj = {
                    criterium: rubricDescriptorItem.criterium,
                    level: rubricDescriptorItem.level,
                    definition: definitionComponent.editedContent
                };

                if (rubricDescriptorItem.idDescriptor == -1) {
                    res = descriptorsModel.insertObject(obj);
                    if (res !== '') {
                        rubricDescriptorItem.idDescriptor = res;
                    }
                } else {
                    obj['id'] = rubricDescriptorItem.idDescriptor;
                    res = descriptorsModel.updateObject(obj);
                }
                descriptorsModel.select();
                if (res)
                    notifySavedContents();
            }
        }
    }

    Component.onCompleted: {
        criteriaModel.select();
        var criteriumObj = criteriaModel.getObject(rubricDescriptorItem.criterium);
        criteriumComponent.originalContent = criteriumObj['ord'] + " - " + criteriumObj['title'] + ' (' + criteriumObj['weight'] + ')' + ((criteriumObj['desc']!=='')?'\n'+criteriumObj['desc']:'')

        levelsModel.select();
        var levelObj = levelsModel.getObject(rubricDescriptorItem.level);
        levelComponent.originalContent =  levelObj['score'] + " - " + levelObj['title'] + ((levelObj['desc']!=='')?'\n'+levelObj['desc']:'');

        if (idDescriptor !== -1) {
            var obj = descriptorsModel.getObject(idDescriptor);
            definitionComponent.originalContent = obj['definition'];
        }
    }

    SqlTableModel {
        id: levelsModel
        tableName: 'rubrics_levels'
        fieldNames: ['id', 'title', 'desc', 'rubric', 'score']
        primaryKey: 'id'
    }
    SqlTableModel {
        id: criteriaModel
        tableName: 'rubrics_criteria'
        fieldNames: ['id', 'title', 'desc', 'rubric', 'ord', 'weight']
        primaryKey: 'id'
    }
}
