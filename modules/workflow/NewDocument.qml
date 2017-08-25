import QtQuick 2.5
import QtQuick.Layouts 1.1

import FileIO 1.0
import PersonalTypes 1.0
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
    signal documentAdded()
    signal discarded()

    property string file: ''
    property int annotationId
    property string documentName: file

    Common.UseUnits {
        id: units
    }

    Models.WorkFlowAnnotationDocuments {
        id: documentsModel
    }

    FileIO {
        id: selectedFile
    }

    StandardPaths {
        id: paths
    }

    CryptographicHash {
        id: hash
    }

    function acquireDocument() {
        if (documentName !== '') {
            selectedFile.source = file;

            console.log('Document source', source);
            var re = new RegExp("[^\\.]+$", "g");
            var extension = re.exec(file);
            if (extension == null)
                extension = "";
            else
                extension = extension.toString();
            console.log('extension', extension);

            var obj = {
                annotation: annotationId,
                title: documentName,
                contents: selectedFile.readBinary(),
                source: file,
                hash: (file !== '')?hash.md5(selectedFile.read()):'',
                docType: (file !== '')?extension.toUpperCase():''
            }

            documentsModel.insertObject(obj);
            documentAdded();
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

        Files.Gallery {
            id: galleryItem

            height: steppedPage.height
            width: steppedPage.width

            onFileSelected: {
                addNewDocumentItem.file = file;
                steppedPage.moveForward();
            }

            Component.onCompleted: setPicturesFolder()
        }

        /*
        Files.FileSelector {
            height: steppedPage.height
            width: steppedPage.width

            selectFiles: true
            selectDirectory: false

            onFileSelected: {
                addNewDocumentItem.file = file;
                steppedPage.moveForward();
            }
        }
        */

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

                Common.TextButton {
                    Layout.preferredHeight: units.fingerUnit * 2
                    Layout.fillWidth: true
                    text: qsTr('Desa')
                    onClicked: {
                        var documentName = searchTitleBox.text;
                        var fileName;
                        if (acquireDocument()) {
                            discarded();
                        }
                    }
                }
            }
        }
    }
}
