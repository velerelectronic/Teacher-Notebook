import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import Qt.labs.folderlistmodel 2.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models

BasicPage {
    id: backup
    pageTitle: qsTr('Gestor de dades')
    property string document: ''
    property string directory: ''

    signal savedBackupToDirectory(string directory)
    signal unsavedBackup()
    signal backupReadFromFile(string file)
    signal backupNotReadFromFile(string file)

    Common.UseUnits {
        id: units
    }

    DatabaseBackup {
        id: fileDb
    }

    mainPage: ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit * 2

        Text {
            id: exportLabel
            text: qsTr('Exporta')
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            anchors.margins: units.nailUnit
        }
        RowLayout {
            id: exportButtonsRow
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            Button {
                text: qsTr('Exporta a fitxer en format JSON')
                onClicked: {
                    if (fileDb.saveContents(fileDb.homePath + "/database-")) {
                        savedBackupToDirectory(file);
                    } else {
                        unsavedBackup();
                    }
                }
            }
        }
        Text {
            id: importLabel
            text: qsTr('Importa')
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
        }

        ListView {
            Layout.fillHeight: true
            Layout.fillWidth: true
            model: folderList
            clip: true
            delegate: Rectangle {
                border.color: 'black'
                color: 'white'
                height: Math.max(units.fingerUnit * 2,file.height)
                width: parent.width

                RowLayout {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Math.max(file.height,details.height)
                    Text {
                        id: file
                        Layout.fillWidth: true
                        Layout.preferredHeight: contentHeight
                        Layout.alignment: Text.AlignVCenter
                        verticalAlignment: Text.AlignVCenter
                        text: model.fileName
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }
                    Text {
                        id: details
                        Layout.preferredWidth: contentWidth
                        Layout.fillHeight: true
                        verticalAlignment: Text.AlignVCenter
                        text: model.fileModified
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        importButton.file = model.fileName
                        importButton.enabled = true;
                    }
                }
            }
        }

        RowLayout {
            id: importButtonsRow
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            Button {
                id: importButton
                property string file: ''
                text: (file=='')?qsTr('Importa'):(qsTr('Importa ') + file)
                enabled: false
                onClicked: {
                    enabled = false;
                    if (fileDb.readContents(fileDb.homePath + '/' + file))
                        backupReadFromFile(file);
                    else
                        backupNotReadFromFile(file);
                    file = '';
                }
            }

        }
        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit
            text: qsTr('Destrueix taules resources, resourcesAnnotations i detailedResourcesAnnotations');
            onClicked: {
                fileDb.dropTable('resources');
                resultsArea.text = "1\n" + fileDb.lastError();
                fileDb.dropTable('resourceAnnotations');
                resultsArea.text = resultsArea.text + "2\n" + fileDb.lastError();
                fileDb.dropView('detailedResourcesAnnotations');
                resultsArea.text = resultsArea.text + "3\n" + fileDb.lastError();
                text = qsTr('Fet!');
                enabled = false;
            }
        }
        TextArea {
            id: resultsArea
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 4
        }
    }

    FolderListModel {
        id: folderList
        folder: 'file://' + fileDb.homePath
        sortField: FolderListModel.Name
        // nameFilters: ['*.backup']
        showDirs: false
        showFiles: true
    }
}
