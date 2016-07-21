import QtQuick 2.5
import QtQml.StateMachine 1.0 as DSM
import PersonalTypes 1.0
import 'qrc:///models' as Models

BasicPage {
    id: rubricModule

    pageTitle: qsTr('Rúbrica')

    property string rubricFile: ''

    Component.onCompleted: {
        setSource('qrc:///modules/rubrics/RubricGroupAssessment.qml', {rubricFile: rubricFile});
    }
}
