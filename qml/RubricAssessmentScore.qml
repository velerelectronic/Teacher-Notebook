import QtQuick 2.0
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common

ItemInspector {
    id: assessmentScoreItem
    pageTitle: qsTr('Edita puntuació de criteri')

    property int assessment: -1
    property int criterium: -1
    property string individual: ''
    property int score: -1
    property string comment: ''
    property SqlTableModel scoresModel

    signal savedAssessmentScore

    property int idxScore
    property int idxComment

    Component.onCompleted: {
        addSection(qsTr('Avaluació'), assessment,'yellow',editorType['None']);
        addSection(qsTr('Criteri'), criterium,'yellow', editorType['None']);
        addSection(qsTr('Individu'), individual,'yellow', editorType['None']);

        idxScore = addSection(qsTr('Puntuació'), score,'yellow',editorType['TextLine']);
        idxComment = addSection(qsTr('Comentari'), comment,'yellow',editorType['TextArea']);
    }

    onSaveDataRequested: {
        score = getContent(idxScore);
        comment = getContent(idxComment);

        console.log('DESANT')
        var object = {
            level: score,
            comment: comment,
            criterium: criterium,
            assessment: assessment,
            individual: individual
        }

        scoresModel.insertObject(object);
        assessmentScoreItem.setChanges(false);
        assessmentScoreItem.savedAssessmentScore();
    }

    onCopyDataRequested: {}
    onDiscardDataRequested: {}
    onClosePageRequested: {}
}
