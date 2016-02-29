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
    id: rubricsGroupsListBasicPage
    width: 100
    height: 62

    pageTitle: qsTr("Grups i individus");

    Common.UseUnits { id: units }

    property string searchString: ''
    property var searchFields: null

    mainPage: Item {
        id: rubricsListArea

        GroupsIndividuals {
            id: groupsIndividuals
            anchors.fill: parent

            searchString: rubricsGroupsListBasicPage.searchString
            searchFields: rubricsGroupsListBasicPage.searchFields

            onOpenGroupIndividualEditor: {
                console.log('individual', individual);
                rubricsListBasicPage.openPageArgs('GroupIndividualEditor', {identifier: individual});
            }
        }
    }

}

