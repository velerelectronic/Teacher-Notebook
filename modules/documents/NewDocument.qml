import QtQuick 2.5
import QtQuick.Layouts 1.1
import FileIO 1.0
import CryptographicHash 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import "qrc:///javascript/Storage.js" as Storage

Item {
    id: newDocumentItem

    signal closeNewDocument(string document)

    property string title: ''
    property string source: ''

    Common.UseUnits {
        id: units
    }

    Models.DocumentsModel {
        id: documentsModel

        searchFields: ['title']
    }

    ColumnLayout {
        anchors.fill: parent

        Common.SearchBox {
            id: searchTitleBox
            Layout.fillWidth: true
            onPerformSearch: {
                newDocumentItem.title = text;
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

        Common.BigButton {
            id: createButton
            Layout.preferredHeight: units.fingerUnit
            Layout.fillWidth: true
            title: (createButton.enabled)?qsTr('Renomena document'):qsTr('Tria un altre nom')
            enabled: (documentsModel.count == 0) && (newDocumentItem.title !== '')
            onClicked: {
                newDocumentItem.title = searchTitleBox.text;
                acquireDocument();
                closeNewDocument(newDocumentItem.title);
            }
        }
    }

    FileIO {
        id: selectedFile
    }

    CryptographicHash {
        id: hash
    }

    function acquireDocument() {
        if (newDocumentItem.title !== '') {
            selectedFile.source = newDocumentItem.source;

            console.log('Document source', source);
            var extension = /[^.]+$/.exec(source);
            if (extension == null)
                extension = "";
            else
                extension = extension.toString();

            var obj = {
                created: Storage.currentTime(),
                title: newDocumentItem.title,
                desc: qsTr('Edita la descripció...'),
                source: newDocumentItem.source,
                contents: '',
                type: extension.toUpperCase(),
                hash: hash.md5(selectedFile.read())
            }
            console.log('new doc', JSON.stringify(obj));
            documentsModel.insertObject(obj);
        }
    }

    Component.onCompleted: searchTitleBox.text = newDocumentItem.title
}
