import QtQuick 2.5
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///modules/basic' as Basic
import 'qrc:///editors' as Editors

Basic.BasicPage {
    id: basicOmniPage

    pageTitle: qsTr('Cerca')

    Common.UseUnits { id: units }

    mainPage: ColumnLayout {
        Common.SearchBox {
            id: searchBox
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            focus: true

            onIntroPressed: {
                resultsModel.clear();

                // Look for annotations
                annotationsModel.searchString = text;
                annotationsModel.select();
                resultsModel.append({title: qsTr('Anotacions'), desc: annotationsModel.count + qsTr(' resultats'), page: 'ContinuousAnnotationsList', options: {searchString: text}});

                // Look for resources
                resourcesModel.searchString = text;
                resourcesModel.select();
                resultsModel.append({title: qsTr('Recursos'), desc: "No s'han cercat", page: 'ResourceManager', options: {searchString: text}});

                // Look for rubrics assessments
                rubricsAssessmentModel.searchString = text;
                rubricsAssessmentModel.select();
                resultsModel.append({title: qsTr('Rúbriques'), desc: rubricsAssessmentModel.count + qsTr(' resultats'), page: 'RubricsAssessmentList', options: {searchString: text, searchFields: rubricsAssessmentModel.searchFields}});

                // Look for groups and individuals
                individualsModel.searchString = text;
                individualsModel.select();
                resultsModel.append({title: qsTr('Grups i individus'), desc: individualsModel.count + qsTr(' resultats'), page: 'RubricsGroupsList', options: {searchString: text, searchFields: individualsModel.searchFields}});
            }
        }

        ListModel {
            id: resultsModel
        }

        ListView {
            id: resultsList

            Layout.fillHeight: true
            Layout.fillWidth: true

            model: resultsModel

            spacing: units.nailUnit

            delegate: Rectangle {
                id: singleResult

                width: resultsList.width
                height: units.fingerUnit * 2
                MouseArea {
                    anchors.fill: parent
                    onClicked: basicOmniPage.openPageArgs(model.page, model.options)
                }
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: singleResult.width / 3
                        font.bold: true
                        font.pixelSize: units.readUnit
                        verticalAlignment: Text.AlignVCenter
                        text: model.title
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        font.pixelSize: units.readUnit
                        verticalAlignment: Text.AlignVCenter
                        text: model.desc
                    }
                }
            }
        }
        Component.onCompleted: {
            searchBox.forceActiveFocus();
        }
    }

    Models.ExtendedAnnotations {
        id: annotationsModel

        searchFields: ['title', 'desc', 'labels']
    }

   Models.ResourcesModel {
       id: resourcesModel
   }

   Models.RubricsAssessmentModel {
       id: rubricsAssessmentModel

       searchFields: ['title', 'desc', '"group"', 'annotation']
   }

   Models.IndividualsModel {
       id: individualsModel

       searchFields: ['name', 'surname', '"group"']
   }
}
