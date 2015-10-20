import QtQuick 2.3
import QtQml.Models 2.1
import PersonalTypes 1.0

CollectionInspector {
    id: groupIndividualEditor

    property string pageTitle: qsTr("Editor d'individus i grups")

    property SqlTableModel groupsIndividualsModel

    property int individual: -1
    property string group: ''

    signal savedGroupIndividual

    function saveOrUpdate() {
        console.log('INDIV', individual);
        console.log(groupsIndividualsModel.tableName);

        var object = {
            name: nameComponent.editedContent,
            surname: surnameComponent.editedContent,
            group: groupComponent.editedContent
        }

        var res;
        if (individual == -1) {
            res = groupsIndividualsModel.insertObject(object);
            individual = res;
        } else {
            object['id'] = individual;
            res = groupsIndividualsModel.updateObject(object);
        }
        if (res)
            groupsIndividualsModel.select();
        savedGroupIndividual();

        return res;
    }

    model: ObjectModel {
        EditTextItemInspector {
            id: nameComponent
            width: groupIndividualEditor.width
            caption: qsTr('Nom')
            onSaveContents: {
                if (saveOrUpdate())
                    notifySavedContents();
            }
        }
        EditTextItemInspector {
            id: surnameComponent
            width: groupIndividualEditor.width
            caption: qsTr('Llinatges')
            onSaveContents: {
                if (saveOrUpdate())
                    notifySavedContents();
            }
        }
        EditTextItemInspector {
            id: groupComponent
            width: groupIndividualEditor.width
            caption: qsTr('Grup')
            onSaveContents: {
                if (saveOrUpdate())
                    notifySavedContents();
            }
        }
    }

    Component.onCompleted: {
        if (individual >= 0) {
            var obj = groupsIndividualsModel.getObject(individual);
            nameComponent.originalContent = obj['name'];
            surnameComponent.originalContent = obj['surname'];
            groupComponent.originalContent = obj['group'];
        }
    }
}
