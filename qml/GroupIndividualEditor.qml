import QtQuick 2.3
import PersonalTypes 1.0

ItemInspector {
    id: groupIndividualEditor

    property SqlTableModel groupsIndividualsModel

    property int individual
    property string group: ''
    property string name: ''
    property string surname: ''

    property int idxGroup
    property int idxName
    property int idxSurname

    signal savedGroupIndividual

    Component.onCompleted: {
        if (individual >= 0) {
            var obj = groupsIndividualsModel.getObject(individual);
            name = obj['name'];
            surname = obj['surname'];
            group = obj['group'];
        }

        idxGroup = addSection(qsTr('Grup'), group, 'yellow', editorType['TextLine']);
        idxName = addSection(qsTr('Nom'), name , 'yellow', editorType['TextLine']);
        idxSurname = addSection(qsTr('Llinatges'), surname, 'yellow', editorType['TextLine']);
    }

    onSaveDataRequested: {
        group = getContent(idxGroup);
        name = getContent(idxName);
        surname = getContent(idxSurname);

        var object = {
            name: groupIndividualEditor.name,
            surname: groupIndividualEditor.surname,
            group: groupIndividualEditor.group,
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
