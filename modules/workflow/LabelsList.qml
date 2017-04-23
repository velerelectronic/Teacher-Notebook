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

    Models.WorkFlowGeneralLabels {
        id: labelsModel
    }

    spacing: units.nailUnit

    model: labelsModel

    delegate: Rectangle {
        width: labelsList.width
        height: units.fingerUnit * 2

        color: model.color

        Text {
            anchors.fill: parent
            padding: units.nailUnit
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: units.readUnit
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: model.text
        }
    }

    footer: Common.TextButton {
        width: labelsList.width
        height: units.fingerUnit * 2

        text: qsTr('Afegeix etiqueta...')

        onClicked: addLabelDialog.open()
    }

    Common.SuperposedMenu {
        id: addLabelDialog

        Rectangle {
            width: labelsList.width
            height: labelsList.height / 2

            GridLayout {
                anchors.fill: parent

                columns: 2
                rows: 3

                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Text')
                }

                Editors.TextLineEditor {
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.preferredHeight: units.fingerUnit
                }

                Text {
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Color')
                }

                Editors.TextLineEditor {
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.preferredHeight: units.fingerUnit
                }

                Item {

                }

                Button {
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.preferredHeight: units.fingerUnit
                    text: qsTr('Desa')
                }
            }
        }

    }
}
