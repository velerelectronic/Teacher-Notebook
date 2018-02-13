import QtQuick 2.7
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

Item {
    signal closeEditor()
    signal saveTimeMark(string timeMark, string label, string markType)

    property alias timeMark: markEditor.content
    property alias label: labelEditor.content
    property alias markType: typeEditor.content

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
            Layout.preferredHeight: parent.height / 4

            font.pixelSize: units.readUnit

            text: qsTr('Tipus')
        }

        Editors.TextLineEditor {
            id: typeEditor

            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 4
        }

        Common.TextButton {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 4

            text: qsTr('Desa')

            onClicked: {
                saveTimeMark(markEditor.content, labelEditor.content, typeEditor.content)
            }
        }

        Common.TextButton {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 4
            text: qsTr('Tanca')

            onClicked: {
                closeEditor()
            }
        }
    }
}
