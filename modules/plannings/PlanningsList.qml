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

        sort: 'category ASC, title ASC'

        function update() {
            select();
            orphanSessionsModel.getOrphan();
        }
    }

    Models.PlanningSessionsModel {
        id: orphanSessionsModel

        function getOrphan() {
            var unequalFilter = [];
            var unequalBindValues = [];
            for (var i=0; i<planningsModel.count; i++) {
                var object = planningsModel.getObjectInRow(i);

                unequalFilter.push('planning <> ?');
                unequalBindValues.push(object['title']);
            }

            console.log('filters', unequalFilter, unequalFilter.length);
            console.log('bindvalues', unequalBindValues, unequalBindValues.length);

            filters = unequalFilter;
            bindValues = unequalBindValues;
            select();
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Basic.ButtonsRow {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit + 2 * units.nailUnit

            Common.ImageButton {
                size: units.fingerUnit
                image: 'plus-24844'
                onClicked: {
                    planningsModel.insertObject({title: qsTr('Nou planning ') + (planningsModel.count+1), category: qsTr('Noves planificacions')});
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

            spacing: units.nailUnit

            section.property: 'category'
            section.delegate: Rectangle {
                width: planningsList.width
                height: units.fingerUnit

                color: 'gray'
                Text {
                    anchors.fill: parent
                    font.pixelSize: units.readUnit
                    font.bold: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: 'white'
                    text: section
                }
            }

            delegate: Rectangle {
                width: planningsList.width
                height: units.fingerUnit * 2

                clip: true

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
                        Layout.preferredWidth: parent.width / 4
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.category
                        MouseArea {
                            anchors.fill: parent
                            onPressAndHold: categoryEditorDialog.openCategoryEditor(model.title, model.category)
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

            footer: (orphanSessionsModel.count>0)?footerComponent:null

            Component {
                id: footerComponent

                Item {
                    width: planningsList.width
                    height: units.fingerUnit * 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        spacing: units.nailUnit

                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: contentWidth

                            font.pixelSize: units.readUnit
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                            text: qsTr('Sessions orfes')
                        }

                        ListView {
                            id: orphanSessionsList

                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            clip: true
                            orientation: ListView.Horizontal
                            spacing: units.nailUnit

                            model: orphanSessionsModel

                            delegate: Rectangle {
                                width: units.fingerUnit * 4
                                height: orphanSessionsList.height

                                Text {
                                    anchors.fill: parent
                                    anchors.margins: units.nailUnit

                                    font.pixelSize: units.readUnit
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                    text: model.planning + " - " + model.number + " - " + model.title
                                }
                                MouseArea {
                                    anchors.fill: parent
                                }
                            }
                        }
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
