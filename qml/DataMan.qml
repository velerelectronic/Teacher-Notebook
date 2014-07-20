import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import FileIO 1.0

import 'qrc:///common' as Common
import "qrc:///javascript/Storage.js" as Storage

Rectangle {
    property string pageTitle: qsTr('Gestor de dades')
    property string document: ''
    property string directory: ''

    signal backupSavedToFile(string filename)
    signal backupReadFromFile(string filename)
    signal chooseDirectory()

    FileIO {
        id: inFile
        source: document
    }

    FileIO {
        id: outFile
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit

        Common.UseUnits { id: units }
        spacing: units.nailUnit

        Text {
            id: exportLabel
            Layout.fillWidth: true
            Layout.fillHeight: true
            font.pixelSize: units.readUnit
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
            font.pixelSize: units.readUnit
        }
        RowLayout {
            id: exportButtonsRow
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height

            Button {
                Layout.preferredHeight: units.fingerUnit
                text: qsTr('Selecciona directori')
                onClicked: chooseDirectory()
            }

            Button {
                Layout.preferredHeight: units.fingerUnit
                enabled: directory != ''
                text: qsTr('Desa a fitxer')
                onClicked: {
                    if (directory != '') {
                        outFile.source = directory + '/' + Storage.currentTimeForFileName() + '.backup';
                        if (outFile.write(Storage.exportDatabaseToText())) {
                            backupSavedToFile(outFile.source);
                            console.log('written');
                        } else
                            console.log('failure');
                        console.log(outFile.source);
                    }
                }
            }

            Button {
                Layout.preferredHeight: units.fingerUnit
                text: qsTr('Exporta')
                onClicked: exportContents.text = Storage.exportDatabaseToText()
            }

            Button {
                Layout.preferredHeight: units.fingerUnit
                text: qsTr('Copia al clipboard')
                onClicked: {
                    exportContents.selectAll()
                    exportContents.copy()
                }
            }

            Button {
                Layout.preferredHeight: units.fingerUnit
                text: qsTr('Envia per correu')
                onClicked: Qt.openUrlExternally('mailto:?subject=' + encodeURIComponent('[TeacherNotebook] Backup ' + Storage.currentTime()) + '&body=' + encodeURIComponent(exportContents.text))
            }
        }

        Text {
            id: importLabel
            Layout.fillWidth: true
            font.pixelSize: units.readUnit
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
            font.pixelSize: units.readUnit
        }
        RowLayout {
            id: importButtonsRow
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height

            Button {
                enabled: inFile.source != ''
                text: qsTr('Llegeix fitxer')
                onClicked: {
                    importContents.readOnly = false;
                    importContents.text = inFile.read();
                    importContents.readOnly = true;
                    backupReadFromFile(inFile.source);
                }
            }

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
                    console.log('Import contents');
                    console.log(importContents.text);
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
