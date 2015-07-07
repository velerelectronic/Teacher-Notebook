import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import PersonalTypes 1.0
import 'qrc:///common' as Common

CollectionInspector {
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

    model: ObjectModel {
        EditFakeItemInspector {
            id: rubricComponent
            width: rubricCriteriumItem.width
            caption: qsTr('Rúbrica')
        }
        EditTextItemInspector {
            id: titleComponent
            width: rubricCriteriumItem.width
            caption: qsTr('Títol')
        }
        EditTextAreaInspector {
            id: descComponent
            width: rubricCriteriumItem.width
            caption: qsTr('Descripció')
        }
        EditTextItemInspector {
            id: orderComponent
            width: rubricCriteriumItem.width
            caption: qsTr('Ordre')
        }
        EditTextItemInspector {
            id: weightComponent
            width: rubricCriteriumItem.width
            caption: qsTr('Pes')
        }
    }

    Component.onCompleted: {
        rubricsModel.select();
        var rubricObj = rubricsModel.getObject(rubricCriteriumItem.rubric);
        rubricComponent.originalContent = rubricObj['title'] + ((rubricObj['desc'] !== '')?'\n' + rubricObj['desc']:'');
        if (idCriterium !== -1) {
            var obj = criteriaModel.getObject(idCriterium);
            titleComponent.originalContent = obj['title'];
            descComponent.originalContent = obj['desc'];
            orderComponent.originalContent = obj['ord'];
            weightComponent.originalContent = obj['weight'];
        }
    }

    onSaveDataRequested: {
        var object = {
            rubric: rubricCriteriumItem.rubric,
            title: titleComponent.editedContent,
            desc: descComponent.editedContent,
            ord: orderComponent.editedContent,
            weight: weightComponent.editedContent
        }

        if (idCriterium == -1) {
            criteriaModel.insertObject(object);
        } else {
            object['id'] = idCriterium;
            if (criteriaModel.updateObject(object))
                console.log('DONE');
            else
                console.log('NOT Done');
        }
        rubricCriteriumItem.setChanges(false);
        rubricCriteriumItem.savedCriterium();
    }

    SqlTableModel {
        id: rubricsModel
        tableName: 'rubrics'
        fieldNames: ['id','title','desc']
    }

    onCopyDataRequested: {}
    onDiscardDataRequested: {}
    onClosePageRequested: {}
}
