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

    Common.UseUnits { id: units }

    ListModel {
        id: buttonsModel

        ListElement {
            method: 'newRubric'
            image: 'plus-24844'
        }
    }

    Common.TabbedView {
        id: tabbedView

        anchors.fill: parent

        Component.onCompleted: {
            tabbedView.widgets.append({title: 'Avaluacions', component: rubricsAssessmentComponent});
            tabbedView.widgets.append({title: 'Definicions', component: rubricsListComponent});
        }
    }

    Component {
        id: rubricsAssessmentComponent

        Item {
            ColumnLayout {
                anchors.fill: parent
                Button {
                    Layout.preferredHeight: units.fingerUnit
                    Layout.fillWidth: true
                    text: qsTr('Nova avaluació')
                    onClicked: openRubricGroupAssessment(-1,-1,rubricsModel,rubricsAssessmentModel)
                }
                ListView {
                    id: rubricsAssessmentList
                    Layout.fillHeight: true
                    Layout.fillWidth: true

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
                                Layout.preferredWidth: parent.width / 3
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.title
                            }
                            Text {
                                Layout.preferredWidth: parent.width / 3
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

    function newRubric() {
        openRubricDetails(-1, rubricsModel);
    }

    Component.onCompleted: {
        rubricsModel.select();
        rubricsAssessmentModel.select();
    }
}

