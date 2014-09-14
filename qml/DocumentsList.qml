/*
  Llicències CC0
  - Amunt: http://pixabay.com/es/equipo-icono-azul-s%C3%ADmbolo-flecha-31223/
  - Documents: http://pixabay.com/es/plana-icono-documento-tema-28213/
  - Carpeta: http://pixabay.com/es/documento-abierta-carpeta-97576/
  */


import QtQuick 2.3
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.1
import Qt.labs.folderlistmodel 2.1
import FileIO 1.0
import PersonalTypes 1.0
import 'qrc:///common' as Common

Rectangle {
    width: 300
    height: 200
    property string pageTitle: 'Documents'
    property bool selectDirectory: false
    property string goBack: ''
    property var buttons: buttonsModel

    signal openDocument(string page,string directory)
    signal openingDocumentExternally(string document)
    signal createdFile(string file)
    signal notCreatedFile(string file)

    signal closePageRequested()
    signal openDirectoryWithPage(string directory, string page)

    property bool showDetails: false
    property bool showCreationItem: false

    Common.UseUnits { id: units }

    ListModel {
        id: buttonsModel
        ListElement {
            method: 'gotoParentFolder'
            image: 'computer-31223'
        }
        ListElement {
            method: 'toggleDetails'
            image: 'info-147927'
            checkable: true
            checked: false
        }
        ListElement {
            method: 'createItem'
            image: 'plus-24844'
        }
    }

    function gotoParentFolder() {
        if (folderList.parentFolder != '')
            folderList.folder = folderList.parentFolder;
    }

    function toggleDetails() {
        showDetails = !showDetails;
    }

    function createItem() {
        showCreationItem = true;
    }

    ColumnLayout {
        anchors.fill: parent

        Item {
            Layout.preferredHeight: units.fingerUnit
            Layout.fillWidth: true

            RowLayout {
                anchors.fill: parent
                Text {
                    text: folderList.folder
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
                Button {
                    id: selectButton
                    visible: selectDirectory
                    text: qsTr('Selecciona')
                    onClicked: {
                        closePageRequested();
                        openDirectoryWithPage(folderList.folder,goBack);
                    }
                }
            }
        }

        Item {
            Layout.preferredHeight: (showCreationItem)?units.fingerUnit:0
            Layout.fillWidth: true

            clip: true
            RowLayout {
                anchors.fill: parent
                spacing: units.nailUnit
                Text {
                    text: qsTr('Crea un nou element:')
                }
                TextField {
                    id: newItem
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    inputMethodHints: Qt.ImhNoPredictiveText
                }
                Button {
                    Layout.fillHeight: true
                    text: qsTr('Fitxer')
                    onClicked: {
                        var newFile = folderList.folder + '/' + newItem.text;
                        fileio.source = newFile;
                        if (fileio.create()) {
                            createdFile(newFile);
                        } else {
                            notCreatedFile(newFile);
                        }
                        showCreationItem = false;
                    }
                }
                Button {
                    Layout.fillHeight: true
                    text: qsTr('Directori')
                }
                Button {
                    Layout.fillHeight: true
                    text: qsTr('Tanca')
                    onClicked: showCreationItem = false
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: folderList
            clip: true

            delegate: Rectangle {
                border.color: 'black'
                width: parent.width
                height: units.fingerUnit * 2

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit

                    Image {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.height
                        fillMode: Image.PreserveAspectFit
                        source: 'qrc:///icons/' + (model.fileIsDir?'document-97576':'flat-28213') + '.svg'
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        text: fileName
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: (showDetails)?contentWidth:0
                        verticalAlignment: Text.AlignVCenter
                        text: fileSize.toString() + " bytes"
                        clip: true
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: (showDetails)?contentWidth:0
                        verticalAlignment: Text.AlignVCenter
                        text: fileModified
                        clip: true
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // Different actions whether it is a file or a folder
                        if (fileIsDir)
                            folderList.folder = model.fileURL;
                        else {
                            console.log("open document " + fileURL);
                            processDocument(fileURL);
                        }
                    }
                }
            }
        }
    }

    StandardPaths {
        id: paths
    }

    FolderListModel {
        id: folderList
        folder: "file://" + paths.documents
        showDirs: true
        showFiles: true
        showDirsFirst: true
    }

    MessageDialog {
        id: messageOpen
        property string document: ''
        title: qsTr('Obrir document');
        text: qsTr("S'obrira el document «" + messageOpen.document + "» amb un programa extern. Vols continuar?")
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: {
            openingDocumentExternally(document);
            Qt.openUrlExternally(document);
        }
    }

    FileIO {
        id: fileio
    }

    function processDocument(document) {
        var ext = /^.+\.([^\.]*)$/.exec(document);
        var extensio = ((ext == null)?'':ext[1]).toLowerCase();

        var page = '';
        switch(extensio) {
        case 'xml':
            openDocument('ProgramacioAula',document);
            break;
        case 'jpg':
        case 'jpeg':
        case 'png':
        case 'svg':
            openDocument('ImageMapper',document);
            break;
        case 'backup':
            openDocument('DataMan',document);
            break;
        case 'txt':
            openDocument('TextViewer', document);
            break;
        case 'gxml':
            openDocument('MultipleGrid', document);
            break;
        default:
            messageOpen.document = document;
            messageOpen.open();
        }
    }
}
