import QtQuick 2.7
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import 'qrc:///modules/basic' as Basic

Rectangle {
    id: planningsListItem

    signal planningSelected(string title)
    signal planningItemsSelected(string title)

    color: 'gray'

    Common.UseUnits {
        id: units
    }

    Models.PlanningsModel {
        id: planningsModel

        sort: 'category ASC, title ASC'

        searchFields: ['title', 'desc', 'category', 'fields']

        function update() {
            select();
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Basic.ButtonsRow {
            id: buttonsRow

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit + 2 * units.nailUnit

            Common.SearchBox {
                width: buttonsRow.width - buttonsRow.margins * 2
                height: buttonsRow.height - buttonsRow.margins * 2

                onPerformSearch: {
                    planningsModel.searchString = text;
                    planningsModel.update();
                }
            }
        }

        ListView {
            id: planningsList

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            model: planningsModel

            bottomMargin: units.fingerUnit * 2
            spacing: units.nailUnit

            section.property: 'category'
            section.delegate: Item {
                width: planningsList.width
                height: units.fingerUnit * 2

                Text {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    verticalAlignment: Text.AlignBottom
                    font.pixelSize: units.readUnit
                    font.bold: true
                    elide: Text.ElideRight
                    color: 'white'
                    text: section
                }
            }

            delegate: Rectangle {
                id: singlePlanningRect

                width: planningsList.width
                height: units.fingerUnit * 2

                clip: true

                property string planning: model.title

                MouseArea {
                    anchors.fill: parent
                    onClicked: planningSelected(model.title)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit

                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.title
                        MouseArea {
                            anchors.fill: parent
                            onClicked: planningSelected(model.title)
                            onPressAndHold: titleEditorDialog.openTitleEditor(model.title)
                        }
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.desc
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 6
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.category
                        MouseArea {
                            anchors.fill: parent
                            onPressAndHold: categoryEditorDialog.openCategoryEditor(model.title, model.category)
                        }
                    }

                    Loader {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 6

                        asynchronous: true

                        sourceComponent: Text {
                            id: itemsText

                            Models.PlanningItems {
                                id: itemsModel

                                filters: ['planning=?']

                                function update() {
                                    bindValues = [singlePlanningRect.planning];
                                    select();
                                    if (count>0)
                                        itemsText.text = count + " " + qsTr("elements");
                                    else
                                        itemsText.text = '-';
                                }
                            }

                            Component.onCompleted: itemsModel.update();
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: planningItemsSelected(singlePlanningRect.planning)
                        }
                    }

                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 6
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.fields
                        MouseArea {
                            anchors.fill: parent
                            onPressAndHold: fieldsEditorDialog.openFieldsEditor(model.title, model.fields)
                        }
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        MouseArea {
                            anchors.fill: parent
                            onPressAndHold: fieldsSettingsEditorDialog.openFieldsSettingsEditor(model.title, model.fieldsSettings)
                        }
                        text: model.fieldsSettings
                    }
                }
            }


            Common.SuperposedButton {
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                }
                margins: units.nailUnit
                imageSource: 'plus-24844'
                size: units.fingerUnit + margins * 2

                onClicked: {
                    planningsModel.insertObject({title: qsTr('Nou planning ') + (planningsModel.count+1), category: qsTr('Noves planificacions')});
                    planningsModel.update();
                }
            }
        }

    }

    Common.SuperposedMenu {
        id: titleEditorDialog

        title: qsTr('Edita títol')
        property string planningTitle: ''

        Editors.TextAreaEditor3 {
            id: titleEditorItem

            width: titleEditorDialog.parentWidth
            height: units.fingerUnit * 5
        }
        Common.TextButton {
            text: qsTr('Desa')
            onClicked: {
                planningsModel.updateObject(titleEditorDialog.planningTitle, {title: titleEditorItem.content.trim()});
                planningsModel.update();
                titleEditorDialog.close();
            }
        }

        function openTitleEditor(title) {
            titleEditorItem.content = title;
            titleEditorDialog.planningTitle = title;
            open();
        }
    }

    Common.SuperposedMenu {
        id: categoryEditorDialog

        title: qsTr('Edita categoria')
        property string planningTitle: ''

        Editors.TextAreaEditor3 {
            id: categoryEditorItem

            width: categoryEditorDialog.parentWidth
            height: units.fingerUnit * 5
        }
        Common.TextButton {
            text: qsTr('Desa')
            onClicked: {
                planningsModel.updateObject(categoryEditorDialog.planningTitle, {category: categoryEditorItem.content.trim()});
                planningsModel.update();
                categoryEditorDialog.close();
            }
        }

        function openCategoryEditor(planning, category) {
            categoryEditorItem.content = category;
            categoryEditorDialog.planningTitle = planning;
            open();
        }
    }

    Common.SuperposedMenu {
        id: fieldsEditorDialog

        title: qsTr("Edita els camps")

        property string planningTitle: ''
        property string fields: ''

        Editors.TextAreaEditor3 {
            id: fieldsEditorItem

            width: titleEditorDialog.parentWidth
            height: units.fingerUnit * 5
        }
        Common.TextButton {
            text: qsTr('Desa')
            onClicked: {
                planningsModel.updateObject(fieldsEditorDialog.planningTitle, {fields: fieldsEditorItem.content.trim()});
                planningsModel.update();
                fieldsEditorDialog.close();
            }
        }

        function openFieldsEditor(planning, fields) {
            fieldsEditorDialog.planningTitle = planning;
            fieldsEditorItem.content = fields;
            open();
        }
    }

    Common.SuperposedMenu {
        id: fieldsSettingsEditorDialog

        title: qsTr('Edita la configuració dels camps')
        property string planningTitle: ''
        property string fieldsSettings: ''

        Editors.TextAreaEditor3 {
            id: fieldsSettingsEditorItem

            width: titleEditorDialog.parentWidth
            height: units.fingerUnit * 5
        }
        Common.TextButton {
            text: qsTr('Desa')
            onClicked: {
                planningsModel.updateObject(fieldsSettingsEditorDialog.planningTitle, {fieldsSettings: fieldsSettingsEditorItem.content});
                planningsModel.update();
                fieldsSettingsEditorDialog.close();
            }
        }

        function openFieldsSettingsEditor(planning, fieldsSettings) {
            fieldsSettingsEditorDialog.planningTitle = planning;
            fieldsSettingsEditorItem.content = fieldsSettings;
            open();
        }
    }

    function receiveUpdated(object) {
        planningsModel.update();
    }

    Component.onCompleted: planningsModel.update()
}
