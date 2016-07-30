import QtQuick 2.5
import QtQml.Models 2.2
import PersonalTypes 1.0
import 'qrc:///models' as Models
import 'qrc:///modules/buttons' as Buttons

BasicPage {
    id: rubricModule

    pageTitle: qsTr('Rúbrica')

    property string rubricFile: ''

    buttonsModel: ObjectModel {
        Buttons.MainButton {
            icon: 'window-27140'
            onClicked: {
                mainItem.openOtherActionsMenu();
            }
        }
    }

    Component.onCompleted: {
        setSource('qrc:///modules/rubrics/RubricGroupAssessment.qml', {rubricFile: rubricFile});
    }
}
