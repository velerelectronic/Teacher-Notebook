import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import Qt.labs.folderlistmodel 2.1
import ClipboardAdapter 1.0
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors

Rectangle {
    id: newAnnotationItem

    Common.UseUnits {
        id: units
    }

    signal showMessage(string message)
    signal close()
    signal discarded()
    signal workFlowSelected(string workflow)
    signal workFlowCreated(string workflow)

    property SqlTableModel workFlowsModel

    clip: true

    ColumnLayout {
        anchors.fill: parent

        Editors.TextLineEditor {
            id: titleEditor

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2
        }

        Editors.TextAreaEditor3 {
            id: descEditor

            Layout.fillWidth: true
            Layout.fillHeight: true
        }
        Common.TextButton {
            Layout.preferredHeight: units.fingerUnit
            Layout.fillWidth: true
            text: qsTr('Desa')
            onClicked: saveNewWorkFlow()
        }
    }

    function saveNewWorkFlow() {
        var title = titleEditor.content;
        var newObj = {
            title: title,
            desc: descEditor.content
        }

        if (workFlowsModel.insertObject(newObj)) {
            workFlowsModel.select();
            workFlowCreated(title);
            close();
        }
    }
}
