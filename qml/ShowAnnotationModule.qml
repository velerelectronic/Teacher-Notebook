import QtQuick 2.5
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import QtQuick.Dialogs 1.2
import 'qrc:///modules/basic' as Basic
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import "qrc:///javascript/Storage.js" as Storage
import "qrc:///common/FormatDates.js" as FormatDates
import 'qrc:///modules/annotations2' as Annotations
import PersonalTypes 1.0

Basic.BasicPage {
    id: showAnnotationModule
    pageTitle: qsTr("Visor d'anotació")

    signal annotationSelected(int annotation)
    signal documentSelected(string document)

    property bool embedded
    property int annotation

    pageClosable: true

    mainPage: Annotations.ShowAnnotation {
        identifier: showAnnotationModule.annotation

        onAnnotationSelected: {
            console.log('ara');
            showAnnotationModule.annotationSelected(annotation);
        }

        onDocumentSelected: {
            showAnnotationModule.documentSelected(document);
        }
    }
}
