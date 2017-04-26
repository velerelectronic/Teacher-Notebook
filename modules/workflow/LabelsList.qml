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

    signal annotationLabelsSelected(int annotation)

    property int requiredWidth: contentItem.width

    property bool simple: false

    orientation: ListView.Horizontal

    Models.WorkFlowAnnotationLabels {
        id: annotationLabelsModel

        filters: ['annotation=?']
    }

    Models.WorkFlowGeneralLabels {
        id: generalLabelsModel
    }

    model: ListModel {
        id: labelsInfoModel
    }

    interactive: false
    spacing: units.nailUnit

    delegate: Rectangle {
        width: height * 2
        height: labelsList.height

        radius: height / 4

        color: model.color
    }
    footer: ((labelsInfoModel.count>0) || (simple))?null:addLabelComponent

    Component {
        id: addLabelComponent

        Text {
            width: contentWidth
            height: labelsList.height

            font.pixelSize: units.readUnit
            text: qsTr('Afegeix una etiqueta...')
            MouseArea {
                anchors.fill: parent
                onClicked: labelsEditorDialog.openLabelsEditor()
            }
        }
    }

    function getLabels() {
        annotationLabelsModel.bindValues = [annotationId];
        annotationLabelsModel.select();
        labelsInfoModel.clear();
        console.log('annotation id', annotationId);
        for (var i=0; i<annotationLabelsModel.count; i++) {
            var label = annotationLabelsModel.getObjectInRow(i)['label'];

            var obj = generalLabelsModel.getObject(label);
            labelsInfoModel.append({color: obj['color']});
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: labelsEditorDialog.openLabelsEditor()
    }

    Common.SuperposedWidget {
        id: labelsEditorDialog

        function openLabelsEditor() {
            load(qsTr('Edita etiquetes'), 'workflow/LabelsListEditor', {workFlow: labelsList.workFlow, annotationId: labelsList.annotationId});
        }

        Connections {
            target: labelsEditorDialog.mainItem

            onLabelsChanged: getLabels()
        }
    }

    onAnnotationIdChanged: {
        console.log('changed id to ', annotationId);
        getLabels();
    }
    Component.onCompleted: getLabels()
}
