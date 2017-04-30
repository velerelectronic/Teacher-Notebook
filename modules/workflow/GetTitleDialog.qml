import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.0

import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

Rectangle {
    Common.UseUnits { id: units }

    property string title

    signal acceptedTitle(string title)
    signal canceledTitle()

    ColumnLayout {
        anchors.fill: parent
        spacing: units.nailUnit

        Editors.TextAreaEditor3 {
            id: titleEditor

            Layout.fillHeight: true
            Layout.fillWidth: true

            content: title
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            RowLayout {
                anchors.fill: parent
                spacing: units.fingerUnit

                Button {
                    text: qsTr('Accepta')
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    onClicked: acceptedTitle(titleEditor.content)
                }

                Button {
                    text: qsTr('Cancela')
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    onClicked: canceledTitle()
                }
            }
        }
    }
}
