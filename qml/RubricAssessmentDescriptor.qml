import QtQuick 2.0
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import "qrc:///javascript/Storage.js" as Storage

ItemInspector {
    id: assessmentDescriptorItem
    pageTitle: qsTr('Edita descriptor avaluat')

    property int assessment: -1
    property string individual: ''
    property int descriptor: -1
    property int criterium: -1
    property string comment: ''

    property SqlTableModel scoresSaveModel
    property SqlTableModel scoresModel
    property SqlTableModel levelDescriptorsModel

    signal savedAssessmentDescriptor

    property int idxDescriptor
    property int idxComment

    Component.onCompleted: {
        addSection(qsTr('Avaluació'), assessment,'yellow',editorType['None']);
        addSection(qsTr('Individu'), individual,'yellow', editorType['None']);

        for (var i=0; i<scoresModel.count; i++) {

        }

        var obj = levelDescriptorsModel.getObject('criterium',criterium);
        var desc = obj['criteriumTitle'] + ' ' + obj['criteriumDesc'];
        addSection(qsTr('Criteri'), desc, 'white', editorType['None']);

        idxDescriptor = addSection(qsTr('Puntuació'), {reference: descriptor, model: levelDescriptorsModel, nameAttribute: 'definition'},'white',editorType['List']);
        idxComment = addSection(qsTr('Comentari'), comment,'yellow',editorType['TextArea']);
    }

    onSaveDataRequested: {
        descriptor = getContent(idxDescriptor).reference;
        comment = getContent(idxComment);

        console.log('DESANT')
        var object = {
            descriptor: descriptor,
            comment: comment,
            assessment: assessment,
            individual: individual,
            moment: Storage.currentTime()
        }

        scoresSaveModel.insertObject(object);
        setChanges(false);
        savedAssessmentDescriptor();
    }

    onCopyDataRequested: {}
    onDiscardDataRequested: {}
    onClosePageRequested: {}
}
