import QtQuick 2.3
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

Rectangle {
    id: rubricsListArea
    width: 100
    height: 62
    property string pageTitle: qsTr("Rúbriques");
    property var buttons: buttonsModel

    signal openRubricEditor(int id, var rubricsModel)
    signal openRubricDetails(int rubric, var rubricsModel)
    signal openRubricGroupAssessment(int assessment, int rubric, var rubricsModel, var rubricsAssessmentModel)
    signal openRubricAssessmentDetails(int assessment, int rubric, string group, var rubricsModel, var rubricsAssessmentModel)
    signal editGroupIndividual(int individual, var groupsIndividualsModel)

    property bool newIndividual: false

    Common.UseUnits { id: units }

    ListModel {
        id: buttonsModel

        ListElement {
            method: 'newButton'
            image: 'plus-24844'
        }
    }

    Common.TabbedView {
        id: tabbedView

        anchors.fill: parent

        Component.onCompleted: {
            tabbedView.widgets.append({title: qsTr('Avaluacions'), component: rubricsAssessmentComponent});
            tabbedView.widgets.append({title: qsTr('Definicions'), component: rubricsListComponent});
            tabbedView.widgets.append({title: qsTr('Grups'), component: rubricsGroupsComponent});
        }
    }

    Component {
        id: rubricsAssessmentComponent

        Item {
            id: rubricsAssessmentItem

            RowLayout {
                id: layout
                property real titleWidth: width / 3
                property real descWidth: titleWidth

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: units.nailUnit
                }
                height: units.fingerUnit * 2

                Text {
                    Layout.preferredHeight: layout.titleWidth
                    Layout.fillHeight: true
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.bold: true
                    text: qsTr('Títol')
                }
                Text {
                    Layout.preferredWidth: layout.descWidth
                    Layout.fillHeight: true
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.bold: true
                    text: qsTr('Descripció')
                }
                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.bold: true
                    text: qsTr('Grup')
                }
            }
            ListView {
                id: rubricsAssessmentList
                anchors {
                    top: layout.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                clip: true
                model: rubricsAssessmentModel
                delegate: Rectangle {
                    width: rubricsAssessmentList.width
                    height: units.fingerUnit * 2
                    border.color: 'black'
                    MouseArea {
                        anchors.fill: parent
                        onClicked: openRubricGroupAssessment(model.id, model.rubric, rubricsModel, rubricsAssessmentModel)
                    }
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        Text {
                            Layout.preferredWidth: layout.titleWidth
                            Layout.fillHeight: true
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: model.title
                        }
                        Text {
                            Layout.preferredWidth: layout.descWidth
                            Layout.fillHeight: true
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: model.desc
                        }
                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: model.group
                        }
                        Button {
                            Layout.fillHeight: true
                            // Layout.preferredWidth: height
                            text: qsTr('Detalls')
                            onClicked: openRubricAssessmentDetails(model.id, model.rubric, model.group, rubricsModel, rubricsAssessmentModel)
                        }
                    }
                }
                Common.SuperposedButton {
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    size: units.fingerUnit * 2
                    fontSize: units.glanceUnit
                    label: qsTr('+')
                    margins: units.nailUnit
                    onClicked: openRubricAssessmentDetails(-1, -1, -1, rubricsModel, rubricsAssessmentModel)
                }
            }
        }

    }

    Component {
        id: rubricsListComponent

        ListView {
            id: rubricsList

            clip: true

            model: rubricsModel
            delegate: Rectangle {
                width: rubricsList.width
                height: units.fingerUnit * 2
                border.color: 'black'
                MouseArea {
                    anchors.fill: parent
                    onClicked: rubricsListArea.openRubricEditor(model.id,rubricsModel)
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
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                size: units.fingerUnit * 2
                fontSize: units.glanceUnit
                label: qsTr('+')
                margins: units.nailUnit
                onClicked: openRubricDetails(-1, rubricsModel)
            }
        }

    }

    Component {
        id: rubricsGroupsComponent

        GroupsIndividuals {
            id: groupsIndividuals
            onEditGroupIndividual: rubricsListArea.editGroupIndividual(individual, groupsIndividualsModel)

            Connections {
                target: rubricsListArea
                onNewIndividualChanged: {
                    if (newIndividual == true) {
                        newIndividual = false;
                        groupsIndividuals.addIndividual();
                    }
                }
            }
        }
    }

    SqlTableModel {
        id: rubricsModel
        tableName: 'rubrics'
        fieldNames: ['id', 'title', 'desc']
    }

    SqlTableModel {
        id: rubricsAssessmentModel
        tableName: 'rubrics_assessment'
        fieldNames: ['id', 'rubric', 'group', 'startValidity', 'endValidity']
    }

    function newButton() {
        switch(tabbedView.selectedIndex) {
        case 0:
            break;
        case 1:
            openRubricDetails(-1, rubricsModel);
            break;
        case 2:
            newIndividual = true;
            break;
        }
    }

    Component.onCompleted: {
        rubricsModel.select();
        rubricsAssessmentModel.select();
    }
}

