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

    pageTitle: qsTr("Definicions de rúbriques");

    Common.UseUnits { id: units }

    signal openRubricAssessmentDetails(int assessment, int rubric, string group, var rubricsModel, var rubricsAssessmentModel)
    signal openRubricDetails(int rubric, var rubricsModel)
    signal openRubricEditor(int rubric, var rubricsModel)

    onOpenRubricAssessmentDetails: {
        openSubPage('RubricAssessmentEditor', {idAssessment: assessment, rubric: rubric, group: group, rubricsModel: rubricsModel, rubricsAssessmentModel: rubricsAssessmentModel}, units.fingerUnit);
    }

    onOpenRubricDetails: openSubPage('RubricDetailsEditor', {rubric: rubric, rubricsModel: rubricsModel}, units.fingerUnit)
    onOpenRubricEditor: openSubPage('Rubric', {rubric: rubric, rubricsModel: rubricsModel}, units.fingerUnit)

    mainPage: Item {
        id: rubricsListArea

        ListView {
            id: rubricsList

            anchors.fill: parent
            clip: true

            model: rubricsModel
            delegate: Rectangle {
                width: rubricsList.width
                height: units.fingerUnit * 2
                border.color: 'black'
                MouseArea {
                    anchors.fill: parent
                    onClicked: rubricsListBasicPage.openRubricEditor(model.id,rubricsModel)
                }
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 3
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        text: model.title
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        text: model.desc
                    }
                    Button {
                        Layout.fillHeight: true
                        // Layout.preferredWidth: width
                        text: qsTr('Avalua')
                        onClicked: openRubricAssessmentDetails(-1, model.id, '', rubricsModel, rubricsAssessmentModel)
                    }
                }
            }

            Common.SuperposedButton {
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }
                size: units.fingerUnit * 2
                imageSource: 'plus-24844'
                onClicked: openRubricDetails(-1, rubricsModel)
            }
        }

        Models.RubricsModel {
            id: rubricsModel
            Component.onCompleted: select()
        }

        Models.RubricsAssessmentModel {
            id: rubricsAssessmentModel

            sort: 'id DESC'

            Component.onCompleted: select()
        }

        Component.onCompleted: {
            rubricsModel.select();
            rubricsAssessmentModel.select();
        }

    }
}

