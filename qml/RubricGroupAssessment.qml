import QtQuick 2.3
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///models' as Models
import 'qrc:///javascript/Debug.js' as Debug
import "qrc:///javascript/Storage.js" as Storage

BasicPage {
    id: rubricRectangleBasicPage

    property int assessment: -1
    pageTitle: qsTr("Avaluació de rúbrica per grups");
    property int sectionsHeight: units.fingerUnit * 2
    property int sectionsWidth: units.fingerUnit * 3
    property int contentsHeight: units.fingerUnit * 2
    property int contentsWidth: units.fingerUnit * 2

    pageClosable: true

    signal editRubricDetails(int idRubric, string title, string desc, var model)
    signal editRubricAssessmentDescriptor(
        int idAssessment,
        int criterium,
        int individual,
        int lastScoreId
        )

    signal editRubricAssessmentByCriterium(int assessment, int criterium, var lastScoresModel)
    signal editRubricAssessmentByIndividual(int assessment, int individual)
    signal showExtendedAnnotation(var parameters)


    onEditRubricAssessmentByCriterium: {
        openPageArgs('ShowRubricGroupAssessmentByCriterium', {assessment: assessment, criterium: criterium, lastScoresModel: lastScoresModel}, units.fingerUnit)
    }

    Common.UseUnits { id: units }


}

