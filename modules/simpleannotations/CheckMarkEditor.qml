import QtQuick 2.7
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common

Item {
    Common.UseUnits {
        id: units
    }

    property bool actualMarkIsPending: true

    signal saveCheckMark(bool done, string comment)

    ColumnLayout {
        anchors.fill: parent

        Common.TextAreaEditor {
            id: commentEditor

            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Item {
            Layout.preferredHeight: units.fingerUnit * 2
            Layout.fillWidth: true

            RowLayout {
                anchors.fill: parent

                Common.TextButton {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: (actualMarkIsPending)?qsTr("Mantenir pendent"):qsTr("Mantenir fet")

                    onClicked: saveCheckMark(!actualMarkIsPending, commentEditor.text)
                }

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 4
                }

                Common.TextButton {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: (actualMarkIsPending)?qsTr("Marcar fet"):qsTr("Marcar pendent")

                    onClicked: saveCheckMark(actualMarkIsPending, commentEditor.text)
                }
            }
        }
    }

}
