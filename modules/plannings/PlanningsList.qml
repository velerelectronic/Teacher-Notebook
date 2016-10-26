import QtQuick 2.7
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import 'qrc:///modules/basic' as Basic

Item {
    id: planningsListItem

    signal planningSelected(string title)

    Common.UseUnits {
        id: units
    }

    Models.PlanningsModel {
        id: planningsModel
    }

    ColumnLayout {
        anchors.fill: parent

        Basic.ButtonsRow {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            Common.ImageButton {
                size: units.fingerUnit
                image: 'plus-24844'
                onClicked: {
                    planningsModel.insertObject({title: qsTr('Nou planning ') + (planningsModel.count+1)});
                }
            }
        }

        ListView {
            id: planningsList

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            model: planningsModel

            delegate: Rectangle {
                width: planningsList.width
                height: units.fingerUnit * 2

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
                        Layout.preferredWidth: parent.width / 3
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.title
                        MouseArea {
                            anchors.fill: parent
                            onPressAndHold: titleEditorDialog.openTitleEditor(model.title)
                        }
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 3
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.desc
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
                planningsModel.select();
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
                planningsModel.select();
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
                planningsModel.select();
                fieldsSettingsEditorDialog.close();
            }
        }

        function openFieldsSettingsEditor(planning, fieldsSettings) {
            fieldsSettingsEditorDialog.planningTitle = planning;
            fieldsSettingsEditorItem.content = fieldsSettings;
            open();
        }
    }

    Component.onCompleted: planningsModel.select()
}
