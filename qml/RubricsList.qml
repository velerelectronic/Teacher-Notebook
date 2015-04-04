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
    signal openRubricDetails(int id, var rubricsModel)
    signal openRubricGroupAssessment(int assessment, int rubric, var rubricsModel, var rubricsAssessmentModel)
    signal openRubricAssessmentDetails(int assessment, var rubricsAssessmentModel)

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
                    onClicked: openRubricAssessmentEditor(-1,-1,rubricsAssessmentModel)
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
                                onClicked: openRubricAssessmentDetails(model.id,rubricsAssessmentModel)
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
                        text: model.title
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        text: model.desc
                    }
                    Button {
                        Layout.fillHeight: true
                        // Layout.preferredWidth: width
                        text: qsTr('Avalua')
                        onClicked: openRubricGroupAssessment(-1, model.id, rubricsModel, rubricsAssessmentModel)
                    }
                }
            }
            header: Rectangle {
                width: rubricsList.width
                height: units.fingerUnit * 2

                RowLayout {
                    anchors.fill: parent
                    Editors.TextLineEditor {
                        id: rubricTitle
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 3
                    }
                    Editors.TextLineEditor {
                        id: rubricDesc
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }
                    Button {
                        Layout.fillHeight: true
                        Layout.preferredWidth: units.fingerUnit * 3
                        text: qsTr('Desa')
                        onClicked: {
                            var object = {
                                title: rubricTitle.content,
                                desc: rubricDesc.content
                            }
                            if (rubricsModel.insertObject(object)) {
                                rubricTitle.content = '';
                                rubricDesc.content = '';
                            }
                        }
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

    Component.onCompleted: {
        rubricsModel.select();
        rubricsAssessmentModel.select();
    }
}

