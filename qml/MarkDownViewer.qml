import QtQuick 2.3
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.1
import PersonalTypes 1.0
import FileIO 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

Rectangle {
    id: mdViewer
    property string pageTitle: qsTr('MarkDown')
    property var buttons: buttonsModel

    property string document: ''
    property string markDownText: ''

    signal openLink(string link)

    Common.UseUnits { id: units }

    states: [
        State {
            name: 'show'
            PropertyChanges {
                target: mdViewer
                editorHeight: 0
            }
            PropertyChanges {
                target: editorLoader
                sourceComponent: {}
            }
        },
        State {
            name: 'edit'
            PropertyChanges {
                target: mdViewer
                editorHeight: mdViewer.height / 2
            }
            PropertyChanges {
                target: editorLoader
                sourceComponent: editorComponent
            }
        },
        State {
            name: 'append'
            PropertyChanges {
                target: mdViewer
                editorHeight: mdViewer.height / 2
            }
            PropertyChanges {
                target: editorLoader
                sourceComponent: appendComponent
            }
        }

    ]
    property int editorHeight: 0

    ColumnLayout {
        anchors.fill: parent

        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(units.fingerUnit,contentHeight)
            font.pixelSize: units.readUnit
            font.bold: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTr('Document ') + document;
        }

        Flickable {
            id: mdFlickable
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true

            contentWidth: width
            contentHeight: mainText.height

            Text {
                id: mainText
                width: mdFlickable.width
                height: contentHeight
                textFormat: Text.RichText
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: units.readUnit
                baseUrl: {
                    var pos = document.lastIndexOf('/');
                    var linkURI = document.substring(0,pos);
                    return linkURI;
                }

                onLinkActivated: {
                    //var pos = document.lastIndexOf('/');
                    var posExt = link.lastIndexOf('.');
                    //var linkURI = document.substring(0,pos) + '/' + link;
                    var ext = link.substring(posExt+1);
                    var linkURI = Qt.resolvedUrl(baseUrl + '/' + link);
                    console.log(baseUrl);
                    console.log(linkURI);
                    if (ext == 'md') {
                        openLink(linkURI);
                    } else {
                        Qt.openUrlExternally(encodeURI(linkURI));
                    }
                }
                onBaseUrlChanged: console.log('New baseUrl: ' + baseUrl)
            }
        }

        Loader {
            id: editorLoader
            Layout.fillWidth: true
            Layout.preferredHeight: mdViewer.editorHeight

            sourceComponent: undefined

            onLoaded: {
                if (mdViewer.state == 'edit')
                    item.content = markDownText;
            }
        }
    }

    Component {
        id: editorComponent
        Editors.TextAreaEditor2 {
            id: editor
        }
    }

    Component {
        id: appendComponent
        Editors.TextAreaEditor2 {
            id: editor
        }
    }

    MarkDownParser {
        id: parser
    }

    FileIO {
        id: mdFile
    }

    onDocumentChanged: reloadMarkDown()

    ListModel {
        id: buttonsModel
        ListElement {
            method: 'editMarkDown'
            image: 'edit-153612'
        }

        ListElement {
            method: 'appendMarkDown'
            image: 'plus-24844'
        }

        ListElement {
            method: 'reloadMarkDown'
            image: 'document-97576'
        }

        ListElement {
            method: 'saveContents'
            image: 'floppy-35952'
        }
    }

    function editMarkDown() {
        mdViewer.state = 'edit';
    }

    function appendMarkDown() {
        mdViewer.state = 'append';
    }

    function reloadMarkDown() {
        mdViewer.state = 'show';
        mdFile.source = document;
        markDownText = mdFile.read();
        refreshHtml();
    }

    function refreshHtml() {
        var html = parser.toHtml(markDownText);
        mainText.text = html;
    }

    function saveContents() {
        switch(mdViewer.state) {
        case 'edit':
            saveDialog.open();
            break;
        case 'append':
            appendDialog.open();
            break;
        }
    }

    MessageDialog {
        id: saveDialog
        title: qsTr('Desa text')
        text: qsTr('Es desaran les dades dins «') + mdFile.source + qsTr('». Vols continuar?')
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: {
            Qt.inputMethod.hide();
            markDownText = editorLoader.item.content;
            mdFile.write(markDownText);
            refreshHtml();
            mdViewer.state = 'show';
        }
    }
    MessageDialog {
        id: appendDialog
        title: qsTr("Annexar text")
        text: qsTr("S'annexarà el text al final del document. Vols continuar?")
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: {
            Qt.inputMethod.hide();
            var newContent = editorLoader.item.content + "\n\n";
            mdFile.append(newContent);
            markDownText += newContent;
            refreshHtml();
            mdViewer.state = 'show';
        }
    }
}
