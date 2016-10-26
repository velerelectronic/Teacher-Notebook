import QtQuick 2.5
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import 'qrc:///modules/documents' as Documents
import 'qrc:///modules/basic' as Basic
import 'qrc:///modules/pagesfolder' as PagesFolder

Rectangle {
    signal sectionSelected(string title, string page)

    property string selectedPage
    property string selectedTitle

    color: 'gray'

    Common.UseUnits {
        id: units
    }

    Common.SteppedPage {
        id: steppedPage
        anchors.fill: parent

        ListView {
            id: pagesList

            model: pagesModel

            spacing: units.nailUnit
            delegate: Rectangle {
                width: pagesList.width
                height: units.fingerUnit * 2
                Text {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: model.title
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        selectedPage = model.page;
                        selectedTitle = model.title;
                        steppedPage.moveForward();
                    }
                }
            }
        }

        Item {
            ColumnLayout {
                anchors.fill: parent

                Common.BoxedText {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    text: qsTr('Títol')
                }

                Editors.TextLineEditor {
                    Layout.preferredHeight: units.fingerUnit * 2
                    Layout.fillWidth: true
                    content: selectedTitle

                    onContentChanged: selectedTitle = content
                }

                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 2

                    text: qsTr('Crea la nova secció')

                    onClicked: {
                        sectionSelected(selectedTitle, selectedPage);
                    }
                }
            }
        }
    }

    ListModel {
        id: pagesModel
    }

    Component.onCompleted: {
        pagesModel.append({page: 'documents/ShowDocument', title: qsTr('Document')});
        pagesModel.append({page: 'annotations2/AnnotationsList', title: qsTr('Anotacions')});
        pagesModel.append({page: 'calendar/YearView', title: qsTr('Calendari anual')});
        pagesModel.append({page: 'files/Gallery', title: qsTr("Galeria d'imatges")});
        pagesModel.append({page: 'whiteboard/WhiteBoard', title: qsTr('Pissarra')});
        pagesModel.append({page: 'documents/DocumentsMosaic', title: qsTr('Mosaic de documents')});
        pagesModel.append({page: 'documents/DocumentsList', title: qsTr('Llista de documents')});
        pagesModel.append({page: 'pagesfolder/SuperposedPapers', title: qsTr('Papers superposats')});
        pagesModel.append({page: 'calendar/WeeksAnnotationsView', title: qsTr('Anotacions per setmanes')});
        pagesModel.append({page: 'checklists/AssessmentSystem', title: qsTr('Llistes de comprovació')});
        pagesModel.append({page: 'plannings/PlanningsList', title: qsTr('Llista de planificacions')});
        pagesModel.append({page: 'plannings/ShowPlanning', title: qsTr('Planificació')});
    }
}
