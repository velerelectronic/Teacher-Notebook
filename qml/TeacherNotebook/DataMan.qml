import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import "Storage.js" as Storage
import 'common' as Common

Rectangle {
    property string pageTitle: qsTr('Gestor de dades')

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit

        Common.UseUnits { id: units }
        spacing: units.nailUnit

        Text {
            id: exportLabel
            Layout.fillWidth: true
            font.pixelSize: units.nailUnit * 2
            font.bold: true
            text: qsTr('Exporta')
        }
        TextArea {
            id: exportContents
            Layout.fillWidth: true
            Layout.fillHeight: true
            focus: true
            wrapMode: TextEdit.WrapAnywhere
            readOnly: true
            font.pixelSize: units.nailUnit
        }
        RowLayout {
            id: exportButtonsRow
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height

            Button {
                Layout.preferredHeight: units.fingerUnit
                text: 'Exporta'
                onClicked: exportContents.text = Storage.exportDatabaseToText()
            }

            Button {
                Layout.preferredHeight: units.fingerUnit
                text: 'Copia al clipboard'
                onClicked: {
                    exportContents.selectAll()
                    exportContents.copy()
                }
            }
        }

        Text {
            id: importLabel
            Layout.fillWidth: true
            font.pixelSize: units.nailUnit * 2
            font.bold: true
            text: qsTr('Importa')
        }
        TextArea {
            id: importContents
            Layout.fillWidth: true
            Layout.fillHeight: true
            focus: true
            wrapMode: TextEdit.WrapAnywhere
            readOnly: true
            font.pixelSize: units.nailUnit
        }
        RowLayout {
            id: importButtonsRow
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height

            Button {
                Layout.preferredHeight: units.fingerUnit
                text: 'Enganxa del clipboard'
                onClicked: {
                    importContents.readOnly = false;
                    importContents.paste();
                    importContents.readOnly = true;
                }
            }

            Button {
                Layout.preferredHeight: units.fingerUnit
                text: 'Importa'
                onClicked: {
                    var error = Storage.importDatabaseFromText(importContents.text);
                    if (error != '')
                        importContents.text = error
                    else {
                        importContents.text = 'OK'
                        text = 'Inserides!'
                    }
                }
            }
        }

    }
}
