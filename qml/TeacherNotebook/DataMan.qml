import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import "Storage.js" as Storage

ColumnLayout {
    property string title: qsTr('Gestor de dades')
    property int esquirolGraphicalUnit: 100

    Text {
        id: exportLabel
        Layout.fillWidth: true
        text: qsTr('Exporta')
        anchors.margins: 10
    }
    TextArea {
        id: exportContents
        Layout.fillWidth: true
        Layout.fillHeight: true
        focus: true
        wrapMode: TextEdit.WrapAnywhere
        readOnly: true
        font.pointSize: 12
        inputMethodHints: Qt.ImhNoPredictiveText
    }
    RowLayout {
        id: exportButtonsRow
        Layout.fillWidth: true
        height: childrenRect.height

        Button {
            text: 'Exporta'
            onClicked: exportContents.text = Storage.exportDatabaseToText()
        }

        Button {
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
        text: qsTr('Importa')
    }
    TextArea {
        id: importContents
        Layout.fillWidth: true
        Layout.fillHeight: true
        focus: true
        wrapMode: TextEdit.WrapAnywhere
        readOnly: false
        font.pointSize: 12
        inputMethodHints: Qt.ImhNoPredictiveText
    }
    Row {
        id: importButtonsRow
        Layout.fillWidth: true
        height: childrenRect.height

        Button {
            text: 'Enganxa del clipboard'
            onClicked: importContents.paste()
        }

        Button {
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
