import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import QtQuick.Dialogs 1.2
import ClipboardAdapter 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import 'qrc:///modules/annotations2' as Annotations
import "qrc:///modules/files/mediaTypes.js" as MediaTypes

Item {
    id: showDocumentItem

    Common.UseUnits {
        id: units
    }

    property string document: ''
    property string title: ''
    property string desc: ''
    property string mediaType: ''
    property string source: ''
    property string contents: ''
    property string hashString: ''

    signal annotationEditSelected(string annotation, int document)
    signal annotationSelected(int annotation)
    signal annotationsListSelected2()
    signal documentRemoved()
    signal documentUpdated()
    signal documentSelected(string document)
    signal documentSourceSelected(string source, string mediaType)


    Models.DocumentsModel {
        id: documentsModel
    }

    Models.ConcurrentDocuments {
        id: concurrentDocumentsModel
    }

    onDocumentChanged: getDocumentDetails()

    ColumnLayout {
        anchors.fill: parent
        spacing: units.nailUnit
        Common.HorizontalStaticMenu {
            id: menuBar

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 1.5

            underlineColor: 'orange'
            underlineWidth: units.nailUnit

            sectionsModel: documentsSectionsModel
            connectedList: documentsListView
        }

        ListView {
            id: documentsListView
            Layout.fillHeight: true
            Layout.fillWidth: true

            clip: true
            spacing: units.fingerUnit

            model: ObjectModel {
                id: documentsSectionsModel

                Common.BasicSection {
//                    width: documentsListView.width
                    padding: units.fingerUnit
                    caption: qsTr('Document')

                    Image {
                        id: imageRepresentation

                        property var modes: [Image.PreserveAspectFit,Image.PreserveAspectCrop]
                        fillMode: Image.PreserveAspectFit
                        width: parent.width
                        height: Math.max(parent.width * 0.75, sourceSize.height * width / sourceSize.width)
                        horizontalAlignment: Image.AlignHCenter
                        verticalAlignment: Image.AlignVCenter
                        source: MediaTypes.imageForMediaType(showDocumentItem.source, showDocumentItem.mediaType)

                        function rotateFillMode() {
                            console.log('rotating', imageRepresentation.fillMode);
                            console.log(imageRepresentation.modes[(imageRepresentation.modes.indexOf(imageRepresentation.fillMode)+1) % imageRepresentation.modes.length]);
                            imageRepresentation.fillMode = imageRepresentation.modes[(imageRepresentation.modes.indexOf(imageRepresentation.fillMode)+1) % imageRepresentation.modes.length];
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: imageRepresentation.rotateFillMode()
                        }

                        Rectangle {
                            id: background
                            color: 'gray'
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                            }
                            height: Math.max(imageSubText.height, units.fingerUnit * 2) + 2 * units.nailUnit
                            opacity: 0.5
                        }
                        RowLayout {
                            anchors.fill: background
                            anchors.margins: units.nailUnit
                            spacing: units.fingerUnit
                            Text {
                                id: imageSubText
                                Layout.fillWidth: true
                                Layout.preferredHeight: contentHeight
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: units.readUnit
                                color: 'white'
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.bold: true
                                text: showDocumentItem.title
                            }
                            Common.ImageButton {
                                Layout.fillHeight: true
                                enabled: annotationsList.count == 0
                                image: 'garbage-1295900'
                                size: units.fingerUnit * 1.5
                                onClicked: confirmDeletionDialog.open()
                            }
                            Common.ImageButton {
                                Layout.fillHeight: true
                                enabled: annotationsList.count == 0
                                image: 'box-24557'
                                size: units.fingerUnit * 1.5
                                onClicked: documentSourceSelected(source, mediaType)
                            }
                        }
                    }
                }

                Common.BasicSection {
                    z: 1
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('General')

                    Item {
                        width: parent.width
                        height: childrenRect.height

                        GridLayout {
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }
                            height: childrenRect.height
                            columns: 3
                            rows: 2
                            columnSpacing: units.nailUnit
                            rowSpacing: units.nailUnit

                            Text {
                                Layout.preferredWidth: contentWidth
                                Layout.preferredHeight: contentHeight
                                font.pixelSize: units.readUnit
                                font.bold: true
                                text: qsTr('Títol')
                            }
                            Text {
                                id: titleText
                                Layout.fillWidth: true
                                Layout.preferredHeight: Math.max(units.fingerUnit * 1.5, contentHeight)
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: title
                            }
                            Common.ImageButton {
                                id: titleEditButton
                                Layout.preferredHeight: size
                                Layout.preferredWidth: size
                                image: 'edit-153612'
                                size: units.fingerUnit * 1.5
                                onClicked: {
                                    titleEditor.text = title;
                                    titleEditDialog.open();
                                }
                            }
                            Text {
                                Layout.preferredWidth: contentWidth
                                Layout.preferredHeight: contentHeight
                                font.pixelSize: units.readUnit
                                font.bold: true
                                text: qsTr('Descripció')
                            }
                            Text {
                                id: descText
                                Layout.fillWidth: true
                                Layout.preferredHeight: Math.max(units.fingerUnit * 1.5, contentHeight)
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: desc
                            }
                            Common.ImageButton {
                                id: descEditButton
                                Layout.preferredHeight: size
                                Layout.preferredWidth: size
                                image: 'edit-153612'
                                size: units.fingerUnit * 1.5
                                onClicked: {
                                    descEditor.text = desc;
                                    descEditDialog.open();
                                }
                            }

                        }
                    }
                }

                Common.BasicSection {
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Origen')

                    GridLayout {
                        width: parent.width
                        height: childrenRect.height

                        columns: 2
                        rows: 3

                        Text {
                            Layout.preferredWidth: contentWidth
                            font.pixelSize: units.readUnit
                            text: qsTr('URI:')
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.preferredHeight: units.fingerUnit
                            height: Math.max(contentHeight, units.fingerUnit)
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.pixelSize: units.readUnit
                            text: source
                            MouseArea {
                                anchors.fill: parent
                                onClicked: documentSourceSelected(source, mediaType)
                            }
                        }

                        Text {
                            Layout.preferredWidth: contentWidth
                            font.pixelSize: units.readUnit
                            text: qsTr('Hash:')
                        }
                        Text {
                            id: hash
                            Layout.fillWidth: true
                            height: Math.max(contentHeight, units.fingerUnit)
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: hashString
                        }
                        Text {
                            Layout.preferredWidth: contentWidth
                            font.pixelSize: units.readUnit
                            text: qsTr('Tipus:')
                        }
                        Text {
                            id: mediaTypeText
                            Layout.fillWidth: true
                            height: Math.max(contentHeight, units.fingerUnit)
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: mediaType
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    mediaTypeEditor.text = mediaType;
                                    mediaTypeEditDialog.open();
                                }
                            }
                        }

                    }

                }

                Common.BasicSection {
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Anotacions')

                    Annotations.AnnotationsList {
                        id: annotationsList

                        width: parent.width
                        height: requiredHeight

                        inline: true

                        frameItem: showDocumentItem

                        document: showDocumentItem.document

                        onAnnotationSelected: showDocumentItem.annotationSelected(annotation)
                        onAnnotationsListSelected2: showDocumentItem.annotationsListSelected2()
                    }
                }

            }

            // Editors


            Common.SuperposedMenu {
                id: titleEditDialog
                title: qsTr('Edita el títol')
                standardButtons: StandardButton.Save | StandardButton.Cancel

                Editors.TextAreaEditor3 {
                    id: titleEditor
                    height: units.fingerUnit * 6
                    width: parent.width
                    color: 'white'
                }

                onAccepted: {
                    titleText.text = titleEditor.text;
                    saveEditorContents();
                    titleEditDialog.close();
                    showDocumentItem.document = titleEditor.text;
                    getDocumentDetails();
                    //documentSelected(document);
                }
            }


            Common.SuperposedMenu {
                id: descEditDialog
                title: qsTr('Edita la descripció')
                standardButtons: StandardButton.Save | StandardButton.Cancel

                Editors.TextAreaEditor3 {
                    id: descEditor

                    height: units.fingerUnit * 6
                    width: parent.width
                    color: 'white'
                }

                onAccepted: {
                    descText.text = descEditor.text;
                    saveEditorContents();
                    descEditDialog.close();
                    getDocumentDetails();
                }
            }

            Common.SuperposedMenu {
                id: mediaTypeEditDialog

                title: qsTr('Edita el tipus de mitjà')
                standardButtons: StandardButton.Save | StandardButton.Cancel

                Editors.TextAreaEditor3 {
                    id: mediaTypeEditor
                    height: units.fingerUnit * 6
                    width: parent.width
                    color: 'white'
                }

                onAccepted: {
                    mediaTypeText.text = mediaTypeEditor.text;
                    saveEditorContents();
                    mediaTypeEditDialog.close();
                    getDocumentDetails();
                }
            }

        }
    }

    function getDocumentDetails() {
        documentsModel.select();
        console.log('Document', document);

        var obj = null;
        if (document !== '') {
            obj = documentsModel.getObject(document);

            console.log('object for show document', obj, typeof obj);
            for (var prop in obj) {
                console.log(prop, "-->", obj[prop]);
            }

            if ('title' in obj) {
                title = obj['title'];
                desc = obj['desc'];
                mediaType = obj['type'];
                source = obj['source'];
                hashString = obj['hash'];

                concurrentDocumentsModel.insertObject({document: title});
                var now = new Date();
                concurrentDocumentsModel.updateObject(title, {lastAccessTime: now.toISOString()});
            }
        }
    }

    function saveEditorContents() {
        var obj = {
            title: titleText.text,
            desc: descText.text,
            type: mediaTypeText.text
        }

        documentsModel.updateObject(document,obj);
        console.log('saved');
    }

    Common.SuperposedMenu {
        id: confirmDeletionDialog

        standardButtons: StandardButton.Yes | StandardButton.No

        title: qsTr('Confirmes eliminar aquest document?')

        Text {
            font.pixelSize: units.readUnit
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: '<p><b>' + document + '</b></p><p>' + desc + '</p>'
        }

        onYes: {
            if (annotationsList.count == 0) {
                documentsModel.removeObject(showDocumentItem.title);
                documentRemoved();
            }
        }
    }


    Component.onCompleted: getDocumentDetails();

}
