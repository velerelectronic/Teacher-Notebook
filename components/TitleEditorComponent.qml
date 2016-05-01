import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors


Common.AbstractEditor {
    id: generalTitleEditor
    property alias content: titleEditor.content

    property var annotationContent

    onChangesChanged: {
        if (!generalTitleEditor.changes) {
            titleEditor.setChanges(false);
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: units.nailUnit

        Editors.TextLineEditor {
            id: titleEditor
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2

            onChangesChanged: {
                if (titleEditor.changes) {
                    generalTitleEditor.setChanges(true);
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit
            text: qsTr('Esborrar anotació')
            onClicked: {}
        }
    }

    onContentChanged: {
        annotationContent = {title: content};
    }
}
