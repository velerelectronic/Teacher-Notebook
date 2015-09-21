import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQml.Models 2.1

import 'qrc:///common' as Common
import "qrc:///javascript/Storage.js" as Storage
import PersonalTypes 1.0

CollectionInspector {
    id: resourceEditor
    pageTitle: qsTr("Editor de recurs")

    signal closePage(string message)
    signal savedResource(int id,string title,string desc)
    signal duplicatedResource(string title,string desc)
    signal selectDocument(string source, var documentReceiver)

    property SqlTableModel resourcesModel

    property int idResource: -1
    property string title: 'Nou recurs'
    property string desc
    property string type
    property string source
    property var contents

    Common.UseUnits { id: units }

    onSaveDataRequested: {
        prepareDataAndSave(idResource);
        savedResource(idResource,title,desc);
        closePage(qsTr('Recurs desat'));
    }

    onCopyDataRequested: {
        prepareDataAndSave(-1);
        resourceEditor.setChanges(false);
        duplicatedResource(title,desc);
    }

    onDiscardDataRequested: {
        if (changes) {
            closePage(qsTr("S'han descartat els canvis en el recurs"));
        } else {
            closePage('');
        }
    }

    onClosePageRequested: closePage('')

    model: ObjectModel {
        EditTextItemInspector {
            id: resourceTitle
            width: resourceEditor.width
            caption: qsTr('Títol')
            originalContent: resourceEditor.title
        }
        EditTextItemInspector {
            id: resourceDesc
            width: resourceEditor.width
            caption: qsTr('Descripció')
            originalContent: resourceEditor.desc
        }
        EditTextItemInspector {
            id: resourceType
            width: resourceEditor.width
            caption: qsTr('Tipus')
            originalContent: resourceEditor.type
        }
        EditFakeItemInspector {
            id: resourceSource
            width: resourceEditor.width
            caption: qsTr('Origen')
            enableSendClick: true

            property string sourceName: ''

            Item {
                id: docReceiver
                anchors.fill: parent

                function sendFile(file) {
                    resourceEditor.source = file;
                    var l = resourceEditor.source.lastIndexOf('/');
                    resourceSource.sourceName = resourceEditor.source.substring(l+1);
                    copySourceToTitle.open();
                }
            }

            MessageDialog {
                id: copySourceToTitle
                title: qsTr('Canviar nom')
                informativeText: qsTr("Vols canviar el nom del recurs per «" + resourceSource.sourceName + "»?")
                standardButtons: StandardButton.Ok | StandardButton.Cancel
                onAccepted: {
                    resourceTitle.originalContent = resourceSource.sourceName;
                }
            }

            originalContent: resourceEditor.source
            editedContent: originalContent
            onSendClick: resourceEditor.selectDocument(resourceSource.editedContent, docReceiver)
        }

        EditTextItemInspector {
            id: resourceContents
            width: resourceEditor.width
            caption: qsTr('Continguts')
            originalContent: resourceEditor.contents
        }
    }

    function prepareDataAndSave(idCode) {
        var obj = {
            title: resourceTitle.editedContent,
            desc: resourceDesc.editedContent,
            type: resourceType.editedContent,
            source: resourceSource.editedContent,
            contents: resourceContents.editedContent
        }
        if (idCode === -1) {
            console.log('Inserint ' + obj);
            obj['created'] = Storage.currentTime();
            globalResourcesModel.insertObject(obj);
        } else {
            obj['id'] = idCode;
            globalResourcesModel.updateObject(obj);
        }
    }

    Component.onCompleted: {
        if (resourceEditor.idResource !== -1) {
            var details = resourcesModel.getObject(resourceEditor.idResource);
            resourceEditor.title = details.title;
            resourceEditor.desc = (details.desc == null)?'':details.desc;
            resourceEditor.type = (details.type == null)?'':details.type;
            resourceEditor.source = (details.source == null)?'':details.source;
            resourceEditor.contents = (details.contents == null)?'':details.contents;
            resourceEditor.setChanges(false);
        }
    }

    function requestClose() {
        closeItem();
    }
}
