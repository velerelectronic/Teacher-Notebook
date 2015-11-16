import QtQuick 2.3
import QtQml.Models 2.1
import PersonalTypes 1.0

CollectionInspector {
    id: groupIndividualEditor

    property string pageTitle: qsTr("Editor d'individus i grups")

    property SqlTableModel groupsIndividualsModel

    property int identifier: -1
    property string group: ''

    signal savedGroupIndividual

    function saveOrUpdate() {
        var object = {
            name: nameComponent.originalContent,
            surname: surnameComponent.originalContent,
            group: groupComponent.originalContent
        }

        var res;
        if (identifier == -1) {
            res = groupsIndividualsModel.insertObject(object);
            identifier = res;
        } else {
            object['id'] = identifier;
            res = groupsIndividualsModel.updateObject(identifier, object);
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
            totalCollectionHeight: groupIndividualEditor.height
            caption: qsTr('Nom')
            onSaveContents: {
                if (saveOrUpdate())
                    notifySavedContents();
            }
        }
        EditTextItemInspector {
            id: surnameComponent
            width: groupIndividualEditor.width
            totalCollectionHeight: groupIndividualEditor.height
            caption: qsTr('Llinatges')
            onSaveContents: {
                if (saveOrUpdate())
                    notifySavedContents();
            }
        }
        EditTextItemInspector {
            id: groupComponent
            width: groupIndividualEditor.width
            totalCollectionHeight: groupIndividualEditor.height
            caption: qsTr('Grup')
            onSaveContents: {
                if (saveOrUpdate())
                    notifySavedContents();
            }
        }
    }

    onIdentifierChanged: {
        if (identifier >= 0) {
            var obj = groupsIndividualsModel.getObject(identifier);
            nameComponent.originalContent = obj['name'];
            surnameComponent.originalContent = obj['surname'];
            groupComponent.originalContent = obj['group'];
        }
    }
}
