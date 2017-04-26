import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4

import ClipboardAdapter 1.0
import PersonalTypes 1.0

import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import 'qrc:///modules/documents' as Documents
import 'qrc:///modules/calendar' as Calendar
import 'qrc:///modules/files' as Files

ListView {
    id: labelsList

    Common.UseUnits {
        id: units
    }

    property int annotationId
    property string workFlow: ''

    signal labelsChanged()

    Models.WorkFlowGeneralLabels {
        id: generalLabelsModel

        filters: ['workFlow=?']

        function update() {
            bindValues = [workFlow];
            select()
        }

        Component.onCompleted: update()
    }

    spacing: units.nailUnit

    model: generalLabelsModel

    clip: true

    delegate: Item {
        id: labelRect

        width: labelsList.width
        height: units.fingerUnit * 2

        property int labelId: model.id

        Models.WorkFlowAnnotationLabels {
            id: annotationLabelsModel

            function isLabelSelected() {
                filters = ['annotation=?', 'label=?']
                bindValues = [annotationId, labelRect.labelId];
                select();
                checkedLabelBox.checked = (count>0);
            }

            function setSelectedLabel() {
                insertObject({annotation: annotationId, label: labelRect.labelId});
                isLabelSelected();
                labelsChanged();
            }

            function deleteSelectedLabel() {
                filters = ['annotation=?', 'label=?']
                bindValues = [annotationId, labelRect.labelId];
                select();
                if (count>0) {
                    var obj = getObjectInRow(0);
                    removeObject(obj['id']);
                    labelsChanged();
                }
                isLabelSelected();
            }

            Component.onCompleted: isLabelSelected()
        }

        RowLayout {
            anchors.fill: parent
            spacing: units.fingerUnit

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: model.color

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit

                    CheckBox {
                        id: checkedLabelBox

                        Layout.fillHeight: true
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        padding: units.nailUnit
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.title
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (checkedLabelBox.checked) {
                            annotationLabelsModel.deleteSelectedLabel();
                        } else {
                            annotationLabelsModel.setSelectedLabel();
                        }
                    }
                }
            }

            Common.ImageButton {
                id: labelEditButton

                Layout.preferredHeight: size
                Layout.preferredWidth: size

                padding: units.nailUnit

                Layout.alignment: Qt.AlignVCenter
                size: units.fingerUnit
                image: 'edit-153612'
                onClicked: addLabelDialog.openLabelEditor(labelRect.labelId, model.title, model.color)
            }
        }
    }

    footer: Common.TextButton {
        width: labelsList.width
        height: units.fingerUnit * 2

        text: qsTr('Afegeix etiqueta...')

        onClicked: addLabelDialog.openNewLabel()
    }

    Common.SuperposedMenu {
        id: addLabelDialog

        property int labelId

        Rectangle {
            width: labelsList.width
            height: labelsList.height / 2

            GridLayout {
                anchors.fill: parent

                columns: 2
                rows: 3

                Text {
                    Layout.preferredWidth: contentWidth
                    Layout.preferredHeight: units.fingerUnit
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Text')
                }

                Editors.TextLineEditor {
                    id: titleEditor

                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 1.5
                }

                Text {
                    Layout.preferredHeight: units.fingerUnit
                    Layout.preferredWidth: contentWidth
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Color')
                }

                Editors.TextLineEditor {
                    id: colorEditor

                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 1.5
                }

                Item {

                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    text: qsTr('Desa')

                    onClicked: {
                        var newLabelObject = {title: titleEditor.content.trim(), color: colorEditor.content.trim(), workFlow: workFlow};
                        if (addLabelDialog.labelId == -1) {
                            generalLabelsModel.insertObject(newLabelObject);
                        } else {
                            generalLabelsModel.updateObject(addLabelDialog.labelId, newLabelObject);
                            labelsChanged();
                        }
                        generalLabelsModel.update();
                    }
                }
            }
        }

        function openNewLabel() {
            addLabelDialog.labelId = -1;
            open();
        }

        function openLabelEditor(labelId, title, color) {
            addLabelDialog.labelId = labelId;
            titleEditor.content = title;
            colorEditor.content = color;
            open();
        }
    }
}
