import QtQuick 2.0
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common

ItemInspector {
    id: rubricDescriptorItem
    pageTitle: qsTr('Edita descriptor de rúbrica')

    property int idDescriptor: -1
    property int criterium
    property int level
    property string definition: ''

    onIdDescriptorChanged: console.log('CEITER: ' + idDescriptor)

    property SqlTableModel descriptorsModel

    signal savedDescriptor

    property int idxDefinition

    Component.onCompleted: {
        addSection(qsTr('Criteri'), rubricDescriptorItem.criterium,'yellow',editorType['None']);
        addSection(qsTr('Nivell'), rubricDescriptorItem.level,'yellow',editorType['None']);

        idxDefinition = addSection(qsTr('Definició'), rubricDescriptorItem.definition,'yellow',editorType['TextArea']);
    }

    onSaveDataRequested: {
        rubricDescriptorItem.definition = getContent(idxDefinition);

        var object = {
            criterium: rubricDescriptorItem.criterium,
            level: rubricDescriptorItem.level,
            definition: rubricDescriptorItem.definition
        }

        if (idDescriptor < 0) {
            descriptorsModel.insertObject(object);
        } else {
            object['id'] = idDescriptor;
            for (var pro in object) {
                console.log(pro + '---' + object[pro]);
            }

            if (descriptorsModel.updateObject(object)) {
                console.log('DONE');
            } else
                console.log('NOT Done');
        }
        rubricDescriptorItem.setChanges(false);
        rubricDescriptorItem.savedDescriptor();
    }

    onCopyDataRequested: {}
    onDiscardDataRequested: {}
    onClosePageRequested: {}
}
