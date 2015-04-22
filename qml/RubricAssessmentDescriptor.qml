import QtQuick 2.0
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import "qrc:///javascript/Storage.js" as Storage

ItemInspector {
    id: assessmentDescriptorItem
    pageTitle: qsTr('Edita descriptor avaluat')

    property int assessment: -1
    property int individual: -1
    property int descriptor: -1
    property int criterium: -1
    property string comment: ''

    property SqlTableModel scoresSaveModel
    property SqlTableModel scoresModel
    property SqlTableModel levelDescriptorsModel

    signal savedAssessmentDescriptor

    property int idxDescriptor
    property int idxPreviousValues
    property int idxComment

    Common.UseUnits { id: units }

    Component.onCompleted: {
        addSection(qsTr('Avaluació'), assessment,'yellow',editorType['None']);
        addSection(qsTr('Individu'), individual,'yellow', editorType['None']);

        for (var i=0; i<scoresModel.count; i++) {

        }

        var obj = levelDescriptorsModel.getObject('criterium',criterium);
        var desc = obj['criteriumTitle'] + ' ' + obj['criteriumDesc'];
        addSection(qsTr('Criteri'), desc, 'white', editorType['None']);

        idxDescriptor = addSection(qsTr('Puntuació'), {reference: descriptor, model: levelDescriptorsModel, nameAttribute: 'definition'},'white',editorType['List']);
        idxPreviousValues = addSection(qsTr('Anteriors'), previousValues, 'white', editorType['Object']);
        idxComment = addSection(qsTr('Comentari'), comment,'yellow',editorType['TextArea']);
    }

    Component {
        id: previousValues
        ListView {
            id: list
            property int requiredHeight: contentItem.height
            model: scoresModel
            delegate: Rectangle {
                border.color: 'black'
                height: units.fingerUnit * 2
                width: list.width
                RowLayout {
                    anchors.fill: parent
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4
                        clip: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: units.readUnit
                        text: model.moment
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4
                        clip: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: units.readUnit
                        text: model.definition
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        clip: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: units.readUnit
                        text: model.comment
                    }
                }
            }
        }
    }

    onSaveDataRequested: {
        descriptor = getContent(idxDescriptor).reference;
        comment = getContent(idxComment);

        console.log('DESANT')
        var object = {
            descriptor: descriptor,
            comment: comment,
            assessment: assessment,
            individual: parseInt(individual),
            moment: Storage.currentTime()
        }

        scoresSaveModel.insertObject(object);
        scoresModel.select();
        setChanges(false);
        savedAssessmentDescriptor();
    }

    onCopyDataRequested: {}
    onDiscardDataRequested: {}
    onClosePageRequested: {}
}
