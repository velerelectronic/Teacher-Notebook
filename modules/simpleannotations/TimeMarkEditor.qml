import QtQuick 2.7
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

Item {
    signal saveTimeMark(string timeMark, string label, string markType)

    Common.UseUnits {
        id: units
    }

    GridLayout {
        anchors.fill: parent
        rows: 4
        columns: 2

        Text {
            Layout.preferredWidth: parent.width / 3
            Layout.preferredHeight: parent.height / 4

            font.pixelSize: units.readUnit

            text: qsTr('Marca de temps')
        }

        Editors.TextLineEditor {
            id: markEditor

            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 4
        }

        Text {
            Layout.preferredWidth: parent.width / 3
            Layout.preferredHeight: parent.height / 4

            font.pixelSize: units.readUnit

            text: qsTr('Etiqueta')
        }

        Editors.TextLineEditor {
            id: labelEditor

            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 4
        }

        Text {
            Layout.preferredWidth: parent.width / 3
            Layout.preferredHeight: parent.height / 3

            font.pixelSize: units.readUnit

            text: qsTr('Tipus')
        }

        Editors.TextLineEditor {
            id: typeEditor

            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 3
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Common.TextButton {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr('Desa')

            onClicked: {
                saveTimeMark(markEditor.content, labelEditor.content, typeEditor.content)
            }
        }
    }
}
