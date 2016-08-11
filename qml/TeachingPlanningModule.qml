import QtQuick 2.5
import QtQml.Models 2.2
import PersonalTypes 1.0
import 'qrc:///models' as Models
import 'qrc:///modules/buttons' as Buttons
import 'qrc:///modules/teachingplanning' as Planning
import 'qrc:///modules/basic' as Basic

Basic.BasicPage {
    id: teachingPlanningModule

    pageTitle: qsTr("Programació del professor")

    property string planningFile: ''

    buttonsModel: ObjectModel {
        Buttons.MainButton {
            icon: 'window-27140'
            onClicked: {
                mainItem.openOtherActionsMenu();
            }
        }

        Buttons.MainButton {
            icon: 'floppy-35952'
            onClicked: {
                saveChanges();
            }
        }

    }

    sourceComponent: Planning.TeachingPlanning {
        document: teachingPlanningModule.planningFile
    }
}
