import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQml.StateMachine 1.0 as DSM
import PersonalTypes 1.0
import ClipboardAdapter 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///models' as Models
import 'qrc:///modules/annotations2' as Annotations
import 'qrc:///modules/basic' as Basic
import "qrc:///common/FormatDates.js" as FormatDates


Basic.BasicPage {
    id: annotationView

    pageTitle: qsTr('Anotació')

    signal annotationSelected(int annotation)

    property var editContent
    property string labels: ''

    property var lastItemSelected: null

    Common.UseUnits {
        id: units
    }

    Models.DocumentAnnotations {
        id: annotationsModel

        Component.onCompleted: select()
    }

    mainPage: Annotations.AnnotationsList {
        interactive: true
        stateValue: '0'

        onAnnotationSelected: annotationView.annotationSelected(annotation)
    }
}

