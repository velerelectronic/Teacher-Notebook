import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.1
import QtQml.Models 2.2

import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors

import PersonalTypes 1.0

Common.AbstractEditor {
    id: editItem
    color: 'white'

    Common.UseUnits {
        id: units
    }

    property string pageTitle: qsTr("Editor de la graella")

    property alias group: groupEditor.text
    property string individual: ''
    property string momentCategory: '' // momentCategoriesItem.momentCategory
    property string variable: ''

    property var individualModel: []

    signal closePage(string message)
    signal close()
    signal updated()

    onGroupChanged: {
        momentCategory = "";
        individual = "";
    }
    onVariableChanged: itemValueEditor.selectedValue = ""

    Models.AssessmentGridModel {
        id: gridModel
    }

    ListView {
        id: editorList

        anchors.fill: parent
        clip: true
        spacing: units.fingerUnit

        model: ObjectModel {
            GridLayout {
                id: dataGrid

                width: editorList.width
                height: dataGrid.childrenRect.height

                columns: 2
                columnSpacing: units.fingerUnit
                rowSpacing: units.nailUnit

                Text {
                    id: groupText
                    width: contentWidth
                    Layout.alignment: Qt.AlignTop
                    text: qsTr('Grup')
                }
                Common.BoxedText {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 2
                    fontSize: units.readUnit
                    margins: units.nailUnit
                    border.width: 0
                    color: '#D8F6CE'
                    text: group
                    MouseArea {
                        anchors.fill: parent
                        onClicked: groupEditorDialog.openGroupEditor()
                    }
                }

                Text {
                    width: contentWidth
                    Layout.alignment: Qt.AlignTop
                    text: qsTr('Categoria de moments')
                }

                Common.BoxedText {
                    Layout.fillWidth: true
                    height: units.fingerUnit * 2
                    fontSize: units.readUnit
                    margins: units.nailUnit
                    border.width: 0
                    color: '#D8F6CE'
                    text: momentCategory

                    MouseArea {
                        anchors.fill: parent
                        onClicked: momentCategoryEditorDialog.openMomentCategories()
                    }
                }

                Text {
                    id: individualLabel
                    width: contentWidth
                    Layout.alignment: Qt.AlignTop
                    text: qsTr('Individu')
                }

                Common.BoxedText {
                    Layout.fillWidth: true
                    height: units.fingerUnit * 2
                    fontSize: units.readUnit
                    margins: units.nailUnit
                    border.width: 0
                    color: '#D8F6CE'
                    text: individual

                    MouseArea {
                        anchors.fill: parent
                        onClicked: individualEditorDialog.openIndividuals()
                    }
                }

                Text {
                    id: variableText
                    width: contentWidth
                    Layout.alignment: Qt.AlignTop
                    text: qsTr('Variable')
                }

                Common.BoxedText {
                    Layout.fillWidth: true
                    height: units.fingerUnit * 2
                    fontSize: units.readUnit
                    margins: units.nailUnit
                    border.width: 0
                    color: '#D8F6CE'
                    text: variable

                    MouseArea {
                        anchors.fill: parent
                        onClicked: variableEditorDialog.openVariableEditor()
                    }
                }

                Text {
                    id: valueLabel
                    width: contentWidth
                    Layout.alignment: Qt.AlignTop
                    text: qsTr('Valor')
                }

                ValueSelector {
                    id: itemValueEditor

                    Layout.fillWidth: true
                    Layout.preferredHeight: itemValueEditor.requiredHeight

                    selectedVariable: editItem.variable
                }

                Text {
                    id: commentLabel
                    width: contentWidth
                    Layout.alignment: Qt.AlignTop
                    text: qsTr('Comentari')
                }

                Editors.TextAreaEditor3 {
                    id: itemCommentField
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 10

                    onTextChanged: editItem.setChanges(true)
                }
            }

        }
        footerPositioning: ListView.OverlayFooter
        footer: Button {
            z: 2
            width: editorList.width
            height: units.fingerUnit
            text: qsTr('Desa')
            onClicked: {
                // Get moment
                var momentCategory = editItem.momentCategory;

                if ((editItem.group !== '') && (momentCategory !== '') && (editItem.variable !== '') && (editItem.individual !== '')){
                    var date = new Date();
                    var newAssessmentObject = {
                        created: date.toISOString(),
                        moment: date.toISOString(),
                        group: editItem.group,
                        individual: editItem.individual,
                        variable: editItem.variable,
                        value: itemValueEditor.selectedValue,
                        comment: itemCommentField.text,
                        momentCategory: momentCategory,
                        variableCategory: ''
                    }
                    gridModel.insertObject(newAssessmentObject);
                    editItem.updated();
                    editItem.close();
                }
            }
        }
    }

    MessageDialog {
        id: saveDialog
        title: qsTr('Desar els valors')
        text: qsTr("Es desaran els valors a la graella d'avaluació.\nVols continuar?")
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: {
            closePage(qsTr("S'han desat " + individualsEditor.item.saveGridValues() + " valors a la graella d'avaluació"));
        }
    }

    MessageDialog {
        id: discardDialog
        title: qsTr('Descartar canvis')
        text: qsTr("Els canvis que heu realitzat es perdran.\nVols continuar?")
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            editItem.setChanges(true);
            closePage(qsTr('Els canvis han estat descartats'));
        }
    }

    function saveGridValues() {
        saveDialog.open();
    }

    function requestClose() {
        if (changes) {
            discardDialog.open();
        } else {
            closePage('');
        }
    }

    Common.SuperposedMenu {
        id: groupEditorDialog

        title: qsTr('Tria el grup')

        standardButtons: StandardButton.Close

        Editors.FieldEditor {
            id: groupEditor

            width: groupEditorDialog.parentWidth * 0.8

            Models.AssessmentGridModel {
                id: groupsModel
            }

            onTextChanged: {
                editItem.setChanges(true);
                editItem.group = groupEditor.text;
                groupEditorDialog.close();
            }
        }

        function openGroupEditor() {
            groupEditor.text = group;
            groupEditor.model = groupsModel.selectDistinct('\"group\"','id','',false);
            open();
        }
    }

    Common.SuperposedMenu {
        id: momentCategoryEditorDialog

        title: qsTr('Tria categoria de moments')

        MomentCategoriesList {
            id: momentCategoryEditor

            width: momentCategoryEditorDialog.parentWidth * 0.8
            height: units.fingerUnit * 2

            onMomentCategorySelected: {
                editItem.momentCategory = momentCategory;
                momentCategoryEditorDialog.close();
            }
        }

        function openMomentCategories() {
            momentCategoryEditor.groupName = editItem.group;
            open();
        }
    }

    Common.SuperposedMenu {
        id: individualEditorDialog

        title: qsTr('Tria individu del grup')

        IndividualSelector {
            id: individualEditor

            width: individualEditorDialog.parentWidth * 0.8
            height: individualEditor.requiredHeight

            onSelectedIndividualChanged: {
                individual = selectedIndividual;
                individualEditorDialog.close();
            }
        }


        function openIndividuals() {
            individualEditor.selectedGroup = group;
            individualEditor.selectedIndividual = individual;
            open();
        }
    }

    Common.SuperposedMenu {
        id: variableEditorDialog

        title: qsTr('Tria variable')

        Editors.FieldEditor {
            id: variableEditor

            width: individualEditorDialog.parentWidth * 0.8
            text: editItem.variable

            onTextChanged: {
                editItem.setChanges(true);
                editItem.variable = text;
                variableEditorDialog.close();
            }

            Models.AssessmentGridModel {
                id: variablesModel
            }

        }

        function openVariableEditor() {
            variableEditor.model = variablesModel.selectDistinct("variable", 'id', '', true);
            open();
        }
    }


}
