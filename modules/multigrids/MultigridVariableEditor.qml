import QtQuick 2.7
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common

Item {
    signal titleChanged(string title)
    signal descChanged(string desc)
    signal variableCreated(string title, string desc)

    signal close()

    property int multigrid: -1
    property int variable: -1

    GridLayout {
        anchors.fill: parent

        columns: 2
        rows: 3

        Text {
            Layout.fillHeight: true
            Layout.fillWidth: true

            text: qsTr("Títol")
        }

        Common.TextAreaEditor {
            id: titleEditor

            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Text {
            Layout.fillHeight: true
            Layout.fillWidth: true

            text: qsTr("Descripció")
        }

        Common.TextAreaEditor {
            id: descEditor

            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Common.TextButton {
            Layout.fillHeight: true
            Layout.fillWidth: true

            text: qsTr("Accepta")

            onClicked: {
                if (variable == -1) {
                    variableCreated(titleEditor.text, descEditor.text);
                } else {
                    titleChanged(variable, titleEditor.text);
                    descChanged(variable, descEditor.text);
                }
            }
        }

        Common.TextButton {
            Layout.fillHeight: true
            Layout.fillWidth: true

            text: qsTr("Cancela")

            onClicked: close()
        }
    }
}
