import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
//import QtWebKit 3.0
import PersonalTypes 1.0
import ClipboardAdapter 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///models' as Models
import "qrc:///common/FormatDates.js" as FormatDates

BasicPage {
    id: rubricsListBasicPage
    width: 100
    height: 62

    pageTitle: qsTr("Rúbriques");

    Common.UseUnits { id: units }

    mainPage: Item {
        id: rubricsListArea

        GroupsIndividuals {
            id: groupsIndividuals
            anchors.fill: parent
        }
    }

}

