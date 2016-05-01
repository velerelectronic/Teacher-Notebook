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

Item {
    id: documentsListPage

    property bool selectDirectory: false
    property bool selectFiles: false
    property string goBack: ''

    property url initialDirectory: ''

    signal documentSelected(string document)
    signal openTBook(string document)
    signal openingDocumentExternally(string document)
    signal createdFile(string file)
    signal notCreatedFile(string file)

    signal closePageRequested()
    signal openDirectoryWithPage(string directory, string page)

    property bool showDetails: false
    property bool showCreationItem: false

    property bool selectDocument: true
    property var documentReceiver: null

    Common.UseUnits { id: units }


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
            Layout.preferredHeight: units.fingerUnit * 1.5
            Layout.fillWidth: true

            RowLayout {
                anchors.fill: parent
                spacing: 0

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
                    Layout.preferredWidth: units.fingerUnit * 5
                    Layout.fillHeight: true
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
            id: filesList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: folderList
            clip: true

            delegate: Rectangle {
                border.color: 'black'
                width: filesList.width
                height: units.fingerUnit * 2

                MouseArea {
                    anchors.fill: parent
                    function hasExtension(name,ext) {
                        return (name.length - name.lastIndexOf(ext) === ext.length);
                    }

                    onClicked: {
                        // Different actions whether it is a file or a folder
                        if (fileIsDir) {
                            if (hasExtension(model.fileURL.toString(),'.tbook')) {
                                console.log('tbook');
                                openTBook(fileURL);
                            } else {
                                folderList.folder = model.fileURL;
                            }
                        } else {
                            processDocument(fileURL);
                        }
                    }
                }

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
                    Button {
                        Layout.fillHeight: true
                        Layout.preferredWidth: (selectDocument)?units.fingerUnit * 3:0
                        clip: true
                        text: qsTr('Selecciona')
                        onClicked: {
                            documentSelected(fileURL);
                        }
                    }
                }

            }
            Common.SuperposedButton {
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }
                size: units.fingerUnit * 2
                imageSource: 'plus-24844'
                onClicked: createItem()
            }
        }
    }

    StandardPaths {
        id: paths
    }

    onInitialDirectoryChanged: folderList.setInitialDirectory()
    onSelectDocumentChanged: folderList.setInitialDirectory()

    FolderListModel {
        id: folderList
        folder: ("file://" + paths.documents)
        showDirs: true
        showFiles: true
        showDirsFirst: true

        Component.onCompleted: {
//            folderList.folder = 'file:///' + (initialDirectory != '')?initialDirectory:paths.documents;
        }

        function setInitialDirectory() {
            console.log('INITIAL DIRECTORY ' + initialDirectory)
            if (initialDirectory == '') {
                folderList.folder = 'file:///' + paths.documents;
            } else {
                if (initialDirectory.toString().indexOf('file://')==0) {
                    console.log(selectDocument);
                    if (selectDocument) {
                        var path = initialDirectory.toString();
                        console.log(path.substring(0,path.lastIndexOf('/')));
                        folderList.folder = path.substring(0,path.lastIndexOf('/'));
                    } else
                        folderList.folder = initialDirectory;
                } else {
                    folderList.folder = 'file:///' + initialDirectory;
                }
            }
        }
    }

    MessageDialog {
        id: messageOpen
        property string document: ''
        title: qsTr('Obrir document');
        text: qsTr("S'obrirà el document «" + messageOpen.document + "» amb un programa extern. Vols continuar?")
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
            documentSelected('ProgramacioAula',document);
            break;

        case 'jpg':
        case 'jpeg':
        case 'png':
        case 'svg':
            documentSelected('ImageMapper',document);
            break;

        case 'json':
            documentSelected('JsonViewer',document);
            break;

        case 'backup':
            documentSelected('DataMan',document);
            break;

        case 'txt':
            documentSelected('TextViewer', document);
            break;

        case 'gxml':
            documentSelected('MultipleGrid', document);
            break;

        case 'md':
            documentSelected('MarkDownViewer', document);
            break;

        default:
            messageOpen.document = document;
            messageOpen.open();
        }
    }
}

