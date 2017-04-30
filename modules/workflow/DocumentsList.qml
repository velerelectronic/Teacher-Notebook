import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///modules/files' as Files
import 'qrc:///modules/documents' as Documents
import "qrc:///common/FormatDates.js" as FormatDates
import "qrc:///modules/files/mediaTypes.js" as MediaTypes

Item {
    id: documentsListItem

    Common.UseUnits { id: units }

    signal newDocumentSelected()
    signal documentSelected(string document)
    signal documentSourceSelected(string source)

    property int annotationId

    property int requiredHeight: documentsListView.requiredHeight

    Models.WorkFlowAnnotationDocuments {
        id: documentsModel

        filters: ['annotation=?']
        searchFields: ['title','desc','type','source','hash']

        sort: 'id DESC'

        function update() {
            bindValues = [annotationId];
            select();
        }

        Component.onCompleted: update()
    }

    Models.WorkFlowAnnotationDocuments {
        id: documentsTypesModel

        searchFields: documentsModel.searchFields

        limit: documentsModel.limit

        sort: documentsModel.sort
    }

    Common.GeneralListView {
        id: documentsListView

        anchors.fill: parent
        model: documentsModel

        toolBar: Common.SearchBox {
            onPerformSearch: {
                documentsModel.searchString = text;
                documentsModel.select();
            }
        }

        headingBar: Rectangle {
            id: documentsHeader

            RowLayout {
                anchors.fill: parent
                spacing: units.fingerUnit

                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: documentsHeader.width / 4
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Títol')
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Origen')
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: documentsHeader.width / 4
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Tipus')
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                }
            }
        }

        delegate: Rectangle {
            id: documentItem
            width: documentsListView.width
            height: units.fingerUnit * 4

//                border.color: 'grey'

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    documentsListItem.documentSelected(model.id);
                }
                onPressAndHold: eraseDocumentDialog.openEraseDialog(model.id, model.title)
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                spacing: units.nailUnit
                Image {
                    id: thumbnailItem
                    Layout.fillHeight: true
                    Layout.preferredWidth: height

                    asynchronous: true
                    fillMode: Image.PreserveAspectFit

                    property string mediaType: MediaTypes.imageForMediaType(model.source, model.type)
                    source: (mediaType == '')?model.source:mediaType
                }

                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: documentItem.width / 4

                    font.bold: true
                    font.pixelSize: units.readUnit
                    text: model.title
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    font.pixelSize: units.readUnit
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    text: model.source + "\n" + model.hash
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Qt.openUrlExternally(model.source);
                        }
                    }
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: documentItem.width / 4
                    font.pixelSize: units.readUnit
                    text: model.type
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                }
            }
        }

        footerBar: Rectangle {
            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: units.readUnit
                text: qsTr('Hi ha ') + documentsModel.count + qsTr(' documents.')
            }
        }

        Common.SuperposedButton {
            id: addDocumentButton
            anchors {
                bottom: parent.bottom
                right: parent.right
            }
            size: units.fingerUnit * 2
            imageSource: 'plus-24844'
            onClicked: {
                superposedAddMenu.open();
            }
        }
        Common.SuperposedMenu {
            id: superposedAddMenu

            title: qsTr('Nou document...')

            Common.SuperposedMenuEntry {
                height: units.fingerUnit * 1.5
                text: qsTr('Fitxer')
                onClicked: {
                    superposedAddMenu.close();
                    newDocumentDialog.openNewDocument();
//                        newDocumentSelected();
                }
            }

            Common.SuperposedMenuEntry {
                height: units.fingerUnit * 1.5
                text: qsTr('Adreça web')
                onClicked: {
                    superposedAddMenu.close();
                }
            }
        }

        MessageDialog {
            id: eraseDocumentDialog

            property string documentTitle: ''
            property int documentId

            title: qsTr('Esborra anotació')
            text: qsTr("S'esborrarà el document «" + documentTitle + "». Vols continuar?")

            standardButtons: StandardButton.Yes | StandardButton.No

            function openEraseDialog(documentId, documentTitle) {
                eraseDocumentDialog.documentId = documentId;
                eraseDocumentDialog.documentTitle = documentTitle;
                open();
            }

            onYes: {
                documentsModel.removeObject(documentId);
                documentsModel.update();
            }
        }
    }

    Common.SuperposedWidget {
        id: newDocumentDialog

        function openNewDocument() {
            newDocumentDialog.load(qsTr('Nou document'), 'workflow/NewDocument', {annotationId: documentsListItem.annotationId});
            newDocumentDialog.open();
        }

        Connections {
            target: newDocumentDialog.mainItem
            ignoreUnknownSignals: true

            onDocumentsListSelected: {
                newDocumentDialog.close();
                documentsModel.select();
            }

            onDocumentSelected: {
                newDocumentDialog.close();
                documentSelected(document);
            }

            onNewDocumentSelected: newDocumentDialog.openNewDocument()
        }
    }

    Common.SuperposedMenu {
        id: documentTypesMenu

        title: qsTr('Tipus de documents')

        property var model

        ListView {
            id: typesList
            width: parent.width
            height: documentsListItem.height / 2
            spacing: units.nailUnit

            model: documentTypesMenu.model

            delegate: Rectangle {
                id: typeRect
                objectName: 'documentTypeItem'
                width: typesList.width
                height: units.fingerUnit
                property bool selected: false
                property string type: modelData

                color: (selected)?'yellow': 'white'

                Text {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    text: modelData
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: typeRect.selected = !typeRect.selected
                }
            }
        }

        Common.SuperposedMenuEntry {
            text: qsTr('Filtra els tipus seleccionats')
            onClicked: {
                var filterTypesArray = [];
                for (var i=0; i<typesList.contentItem.children.length; i++) {
                    var object = typesList.contentItem.children[i];
                    if ((object['objectName'] == 'documentTypeItem') && (object['selected'])) {
                        filterTypesArray.push(object['type']);
                    }
                }

                if (filterTypesArray.length == 0) {
                    documentsModel.filters = [];
                    documentsModel.bindValues = [];
                } else {
                    var filterPrepare = [];
                    for (var i=0; i<filterTypesArray.length; i++)
                        filterPrepare.push('?');
                    console.log(filterTypesArray);
                    documentsModel.filters = ['type IN (' + filterPrepare.join(',') + ')'];
                    documentsModel.bindValues = filterTypesArray;
                }
                documentsModel.select();
                documentTypesMenu.close();
            }
        }
    }
}

