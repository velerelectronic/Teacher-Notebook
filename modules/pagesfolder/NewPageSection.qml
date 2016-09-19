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
    signal sectionSelected(string title, string page, string parameters)

    property string selectedPage
    property string selectedTitle
    property string selectedParameters

    color: 'gray'

    ListModel {
        id: parametersModel
    }

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
                        parametersModel.clear();
                        var parameters = JSON.parse(model.parameters);
                        for (var i=0; i<parameters.length; i++) {
                            parametersModel.append({parameter: parameters[i]});
                        }
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

                ListView {
                    id: parametersList

                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    model: parametersModel

                    spacing: units.nailUnit
                    header: Common.BoxedText {
                        width: parametersList.width
                        height: units.fingerUnit
                        text: qsTr('Paràmetres')
                    }

                    delegate: Rectangle {
                        id: singleParamterItem

                        width: parametersList.width
                        height: units.fingerUnit * 5
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            spacing: units.nailUnit

                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: singleParamterItem.width / 2
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.parameter
                            }
                            Editors.TextAreaEditor3 {
                                id: parameterValueEditor

                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                objectName: 'parameterValue_' + model.parameter

                                onContentChanged: parametersModel.setProperty(model.index, 'value', content)
                            }
                        }
                    }
                }

                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 2

                    text: qsTr('Crea la nova secció')

                    onClicked: {
                        var parameters = {};
                        for (var i=0; i<parametersModel.count; i++) {
                            var paramObj = parametersModel.get(i);
                            parameters[paramObj['parameter']] = paramObj['value'];
                        }

                        selectedParameters = JSON.stringify(parameters);
                        sectionSelected(selectedTitle, selectedPage, selectedParameters);
                    }
                }
            }
        }
    }

    ListModel {
        id: pagesModel
    }

    Component.onCompleted: {
        pagesModel.append({page: 'documents/ShowDocument', title: 'Document', parameters: JSON.stringify(['document'])});
        pagesModel.append({page: 'annotations2/AnnotationsList', title: 'Anotacions', parameters: []});
        pagesModel.append({page: 'calendar/YearView', title: 'Calendari anual', parameters: JSON.stringify(['fullyear'])});
        pagesModel.append({page: 'files/Gallery', title: "Galeria d'imatges", parameters: JSON.stringify(['folder', 'numberOfColumns'])});
    }
}
