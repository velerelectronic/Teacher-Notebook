import QtQuick 2.3
import QtQml.Models 2.1
import PersonalTypes 1.0

CollectionInspector {
    id: groupIndividualEditor

    property string pageTitle: qsTr("Editor d'individus i grups")

    property SqlTableModel groupsIndividualsModel

    property int individual
    property string group: ''

    signal savedGroupIndividual

    model: ObjectModel {
        EditTextItemInspector {
            id: nameComponent
            width: groupIndividualEditor.width
            caption: qsTr('Nom')
        }
        EditTextItemInspector {
            id: surnameComponent
            width: groupIndividualEditor.width
            caption: qsTr('Llinatges')
        }
        EditTextItemInspector {
            id: groupComponent
            width: groupIndividualEditor.width
            caption: qsTr('Grup')
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

    onSaveDataRequested: {
        var object = {
            name: nameComponent.editedContent,
            surname: surnameComponent.editedContent,
            group: groupComponent.editedContent
        }

        if (individual == -1) {
            groupsIndividualsModel.insertObject(object);
        } else {
            object['id'] = individual;
            if (groupsIndividualsModel.updateObject(object))
                console.log('DONE');
            else
                console.log('NOT Done');
        }
        setChanges(false);
        savedGroupIndividual();
    }

    onCopyDataRequested: {}
    onDiscardDataRequested: {}
    onClosePageRequested: {}

}
