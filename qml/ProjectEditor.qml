import QtQuick 2.0
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common

ItemInspector {
    id: projectEditor
    pageTitle: qsTr('Edita detalls de projecte')

    property int idProject: -1
    property string name: ''
    property string desc: ''
    property SqlTableModel projectsModel

    signal savedProjectDetails

    property int idxName
    property int idxDesc

    Component.onCompleted: {
        console.log(idProject);
        var obj = projectsModel.getObject(idProject);
        for (var prop in obj) {
            console.log(prop + '--' + obj[prop]);
        }

        if ('name' in obj)
            name = obj['name'];
        if ('desc' in obj)
            desc = obj['desc'];

        addSection(qsTr('Projecte'), projectEditor.idProject,'yellow',editorType['None']);

        idxName = addSection(qsTr('Nom'), projectEditor.name,'yellow',editorType['TextLine']);
        idxDesc = addSection(qsTr('Descripció'), projectEditor.desc,'yellow',editorType['TextArea']);
    }

    onSaveDataRequested: {
        projectEditor.name = getContent(idxName);
        projectEditor.desc = getContent(idxDesc);

        var object = {
            name: projectEditor.name,
            desc: projectEditor.desc
        }

        if (idProject == -1) {
            projectsModel.insertObject(object);
        } else {
            object['id'] = idProject;
            projectsModel.updateObject(object);
        }
        projectEditor.setChanges(false);
        projectEditor.savedProjectDetails();
    }

    onCopyDataRequested: {}
    onDiscardDataRequested: {}
    onClosePageRequested: {}
}
