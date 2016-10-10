import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import QtQuick.Controls 2.0
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
    signal newRubricSelected()
    signal documentSelected(string document)
    signal documentSourceSelected(string source)


    property int requiredHeight: documentsListView.contentItem.height

    property string selectedIdentifier

    Models.DocumentsModel {
        id: documentsModel

        property bool filteredByTypes: (filters.length > 0)

        searchFields: ['title','desc','type','source','hash']

        limit: 30

        sort: 'created DESC'

        Component.onCompleted: {
            select();
        }
    }

    Models.DocumentsModel {
        id: documentsTypesModel

        searchFields: documentsModel.searchFields

        limit: documentsModel.limit

        sort: documentsModel.sort
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: units.nailUnit

        ListView {
            id: documentsListView
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            model: documentsModel
            spacing: units.nailUnit

            bottomMargin: addDocumentButton.size + addDocumentButton.margins * 2

            header: Rectangle {
                id: documentsHeader

                width: documentsListView.width
                height: flowLayout.height + units.nailUnit * 2
                z: 2

                Flow {
                    id: flowLayout
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: units.nailUnit
                    }
                    height: childrenRect.height

                    spacing: units.fingerUnit

                    Common.SearchBox {
                        width: (flowLayout.width > units.fingerUnit * 10)?units.fingerUnit * 8:flowLayout.width
                        Layout.preferredHeight: units.fingerUnit

                        onPerformSearch: {
                            documentsModel.searchString = text;
                            documentsModel.select();
                        }
                    }

                    Button {
                        text: qsTr('Tipus') + ((documentsModel.filteredByTypes)?' *':'')
                        height: units.fingerUnit

                        onClicked: documentTypesMenu.openTypesFilter()
                    }

                    RowLayout {
                        width: flowLayout.width
                        height: units.fingerUnit

                        Item {
                            Layout.fillHeight: true
                            Layout.preferredWidth: units.fingerUnit * 4
                        }

                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: documentsHeader.width / 4
                            font.pixelSize: units.readUnit
                            font.bold: true
                            text: qsTr('Títol i descripció')
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

            }

            headerPositioning: ListView.OverlayHeader

            footerPositioning: ListView.OverlayFooter
            footer: Rectangle {
                z: 2
                width: documentsListView.width
                height: units.fingerUnit
                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: units.readUnit
                    text: qsTr('Hi ha ') + documentsModel.count + qsTr(' documents.')
                }
            }

            delegate: Rectangle {
                id: documentItem
                width: documentsListView.width
                height: units.fingerUnit * 4
                z: 1

                Behavior on x {
                    NumberAnimation {
                        duration: 200
                    }
                }

//                border.color: 'grey'

                color: ((model.title == selectedIdentifier) && (selectedIdentifier !== ''))?'yellow':'white'

                MouseArea {
                    anchors.fill: parent
                    drag.target: documentItem
                    drag.axis: Drag.XAxis
                    drag.minimumX: -documentItem.width
                    drag.maximumX: 0

                    property bool dragActive: drag.active

                    onClicked: {
                        selectedIdentifier = model.title;
                        documentsListItem.documentSelected(model.title);
                    }

                    onDragActiveChanged: {
                        if (dragActive) {

                        } else {
                            if (documentItem.x < -documentItem.height * 2) {
                                documentItem.x = -documentItem.width
                            } else {
                                documentItem.x = 0;
                            }
                        }
                    }
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
                        font.pixelSize: units.readUnit
                        text: "<b>" + model.title + "</b><br>" + model.desc
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
                                selectedIdentifier = model.title;
                                console.log('new identifier', selectedIdentifier);
                                documentSourceSelected(model.source);
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
                    text: qsTr('Rúbrica')
                    onClicked: {
                        superposedAddMenu.close();
                        documentsListItem.newRubricSelected();
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

        }
    }

    Common.SuperposedWidget {
        id: newDocumentDialog

        function openNewDocument() {
            newDocumentDialog.load(qsTr('Nou document'), 'documents/NewDocument', {});
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


        function openTypesFilter() {
            var typesArray = [];
            for (var i=0; i<documentsModel.count; i++) {
                var object = documentsModel.getObjectInRow(i);
                var documentType = object['type'];
                if (typesArray.indexOf(documentType) < 0) {
                    typesArray.push(documentType);
                }
            }
            typesArray.sort();
            documentTypesMenu.model = typesArray;
            open();
        }
    }
}

