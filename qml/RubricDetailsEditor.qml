import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import PersonalTypes 1.0
import 'qrc:///common' as Common

CollectionInspector {
    id: rubricDetailsItem
    pageTitle: qsTr('Edita detalls de rúbrica')

    property int idRubric: -1
    property string title: ''
    property string desc: ''
    property SqlTableModel rubricsModel

    signal savedRubricDetails

    model: ObjectModel {
        EditTextItemInspector {
            id: rubricTitle
            width: rubricDetailsItem.width
            caption: qsTr('Títol')
        }
        EditTextAreaInspector {
            id: rubricDesc
            width: rubricDetailsItem.width
            caption: qsTr('Descripció')
        }
    }

    Component.onCompleted: {
        if (idRubric !== -1) {
            var obj = rubricsModel.getObject(idRubric);

            rubricTitle.originalContent = ('title' in obj)?obj['title']:obj['desc'];
            rubricDesc.originalContent = ('desc' in obj)?obj['desc']:'';
        }
    }

    onSaveDataRequested: {
        var object = {
            title: rubricTitle.editedContent,
            desc: rubricDesc.editedContent
        }

        if (idRubric == -1) {
            rubricsModel.insertObject(object);
        } else {
            object['id'] = idRubric;
            rubricsModel.updateObject(object);
        }
        rubricDetailsItem.setChanges(false);
        rubricDetailsItem.savedRubricDetails();
    }

    onCopyDataRequested: {}
    onDiscardDataRequested: {}
    onClosePageRequested: {}
}
