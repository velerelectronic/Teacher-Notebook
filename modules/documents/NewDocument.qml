import QtQuick 2.5
import QtQuick.Layouts 1.1

import FileIO 1.0
import CryptographicHash 1.0

import 'qrc:///common' as Common
import 'qrc:///modules/files' as Files
import 'qrc:///modules/documents' as Documents
import 'qrc:///models' as Models
import "qrc:///javascript/Storage.js" as Storage


Item {
    id: addNewDocumentItem

    signal documentSelected(string document)
    signal documentsListSelected()
    signal newDocumentSelected()
    signal discarded()

    property string file: ''
    property string documentName: file

    Common.UseUnits {
        id: units
    }

    Models.DocumentsModel {
        id: documentsModel

        filters: ['title=?']
    }

    FileIO {
        id: selectedFile
    }

    CryptographicHash {
        id: hash
    }

    function acquireDocument() {
        if (documentName !== '') {
            selectedFile.source = file;

            console.log('Document source', source);
            var extension = /[^.]+$/.exec(source);
            if (extension == null)
                extension = "";
            else
                extension = extension.toString();

            var obj = {
                created: Storage.currentTime(),
                title: documentName,
                desc: qsTr('Edita la descripció...'),
                source: file,
                contents: '',
                type: (file !== '')?extension.toUpperCase():'',
                hash: (file !== '')?hash.md5(selectedFile.read()):''
            }
            console.log('new doc', JSON.stringify(obj));
            documentsModel.insertObject(obj);
            return true;
        } else
            return false;
    }

    Common.SteppedPage {
        id: steppedPage
        anchors.fill: parent

        moveForwardEnabled: false
        moveBackwardsEnabled: false

        Rectangle {
            height: steppedPage.height
            width: steppedPage.width

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                Common.Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    text: qsTr('Buit')

                    onClicked: {
                        steppedPage.moveForward();
                        steppedPage.moveForward();
                    }
                }

                Common.Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    text: qsTr('Fitxer')

                    onClicked: {
                        steppedPage.moveForward();
                    }
                }

                Common.Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    text: qsTr('Adreça web')

                    onClicked: discarded()
                }
            }
        }

        Files.FileSelector {
            height: steppedPage.height
            width: steppedPage.width

            selectFiles: true
            selectDirectory: false

            onFileSelected: {
                console.log('hola');
                addNewDocumentItem.file = file;
                steppedPage.moveForward();
            }
        }

        Rectangle {
            id: newDocumentTitleItem
            height: steppedPage.height
            width: steppedPage.width

            ColumnLayout {
                anchors.fill: parent

                Common.SearchBox {
                    id: searchTitleBox
                    Layout.fillWidth: true
                    text: documentName
                    onPerformSearch: {
                        documentName = text.trim();
                        documentsModel.bindValues = [documentName];
                        documentsModel.select();
                    }
                }

                ListView {
                    id: documentsList
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    model: documentsModel

                    delegate: Rectangle {
                        width: documentsList.width
                        height: units.fingerUnit * 2

                        border.color: 'black'

                        Text {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            clip: true
                            text: model.title
                        }
                    }
                }

                Text {
                    id: infoText

                    property bool correct: (documentsModel.count == 0) && (documentName !== '')
                    Layout.preferredHeight: units.fingerUnit
                    Layout.fillWidth: true
                    font.pixelSize: units.readUnit
                    horizontalAlignment: Text.AlignHCenter
                    color: (correct)?'black':'red'
                    text: (correct)?qsTr('Aquest nom està disponible'):qsTr('Tria un altre nom')
                }
                Common.TextButton {
                    Layout.preferredHeight: units.fingerUnit * 2
                    Layout.fillWidth: true
                    text: qsTr('Desa')
                    onClicked: {
                        var documentName = searchTitleBox.text;
                        var fileName;
                        if (acquireDocument()) {
                            steppedPage.moveForward();
                        }
                    }
                }
            }
        }

        Item {
            id: nextOptions

            height: steppedPage.height
            width: steppedPage.width

            ColumnLayout {
                anchors.fill: parent
                spacing: units.fingerUnit
                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 2
                    text: qsTr('Obre el document creat')
                    onClicked: documentSelected(documentName)
                }
                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 2
                    text: qsTr('Llista de documents')
                    onClicked: documentsListSelected()
                }
                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 2
                    text: qsTr('Afegeix un nou document')
                    onClicked: newDocumentSelected()
                }
            }
        }
    }
}
