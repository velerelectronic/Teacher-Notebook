import QtQuick 2.5
import QtQuick.Layouts 1.1

import FileIO 1.0
import CryptographicHash 1.0

import 'qrc:///common' as Common
import 'qrc:///modules/basic' as Basic
import 'qrc:///modules/files' as Files
import 'qrc:///modules/documents' as Documents
import 'qrc:///models' as Models
import "qrc:///javascript/Storage.js" as Storage


Basic.BasicPage {
    id: addNewDocumentItem

    pageTitle: qsTr('Afegir un nou document')

    signal documentSelected(string document)
    signal documenstListSelected()
    signal newDocumentSelected()

    property string file: ''
    property string documentName: file

    Common.UseUnits {
        id: units
    }

    Models.DocumentsModel {
        id: documentsModel

        searchFields: ['title']
    }

    FileIO {
        id: selectedFile
    }

    CryptographicHash {
        id: hash
    }

    function acquireDocument() {
        if ((file !== '') && (documentName !== '')) {
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
                type: extension.toUpperCase(),
                hash: hash.md5(selectedFile.read())
            }
            console.log('new doc', JSON.stringify(obj));
            documentsModel.insertObject(obj);
            return true;
        } else
            return false;
    }

    mainPage: ColumnLayout {
        anchors.fill: parent
        spacing: units.nailUnit

        Common.SteppedPage {
            id: steppedPage
            Layout.fillHeight: true
            Layout.fillWidth: true

            Files.FileSelector {
                height: steppedPage.height
                width: steppedPage.width

                onFileSelected: {
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
                            documentName = text;
                            documentsModel.searchString = text;
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

                        property bool correct: (documentsModel.count == 0) && (documentName !== '') && (file !== '')
                        Layout.preferredHeight: units.fingerUnit
                        Layout.fillWidth: true
                        font.pixelSize: units.readUnit
                        horizontalAlignment: Text.AlignHCenter
                        color: (correct)?'black':'red'
                        text: (correct)?qsTr('Aquest nom està disponible'):qsTr('Tria un altre nom')
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
                        onClicked: documenstListSelected()
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
        Rectangle {
            id: basicButtons

            Layout.preferredHeight: units.fingerUnit * 2
            Layout.fillWidth: true

            visible: enabled

            RowLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                Common.TextButton {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: qsTr('Descarta')
                    onClicked: selectFileMenu.hideWidget()
                }
                Common.TextButton {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: qsTr('Desa')
                    onClicked: {
                        var documentName = searchTitleBox.text;
                        var fileName;
                        if (acquireDocument()) {
                            basicButtons.enabled = false;
                            steppedPage.moveForward();
                        }
                    }
                }
            }
        }
    }
}
