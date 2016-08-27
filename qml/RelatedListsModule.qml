import QtQuick 2.5
import QtQml.Models 2.2
import 'qrc:///models' as Models
import 'qrc:///common' as Common
import 'qrc:///modules/basic' as Basic
import 'qrc:///modules/buttons' as Buttons
import 'qrc:///modules/documents' as Documents
import 'qrc:///modules/relatedlists' as RelatedLists

Basic.BasicPage {
    pageTitle: qsTr('Llistes relacionades')

    mainPage: RelatedLists.CategorizedElements {

    }
}
