import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import ClipboardAdapter 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///components' as Components
import 'qrc:///editors' as Editors
import "qrc:///components/mediaTypes.js" as MediaTypes

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

    signal documentUpdated()
    signal annotationEditSelected(string annotation, int document)
    signal documentSourceSelected(string source)

    Models.DocumentsModel {
        id: documentsModel
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

                        fillMode: Image.PreserveAspectFit
                        width: parent.width
                        height: parent.width * 0.75
                        horizontalAlignment: Image.AlignHCenter
                        verticalAlignment: Image.AlignVCenter
                        source: MediaTypes.imageForMediaType(showDocumentItem.source, showDocumentItem.mediaType)

                        Rectangle {
                            id: background
                            color: 'gray'
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                            }
                            height: Math.max(imageSubText.height, units.fingerUnit) + 2 * units.nailUnit
                            opacity: 0.5
                        }
                        Text {
                            id: imageSubText
                            anchors.fill: background
                            anchors.margins: units.nailUnit
                            height: contentHeight
                            horizontalAlignment: Text.AlignLeft
                            font.pixelSize: units.readUnit
                            color: 'white'
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: showDocumentItem.title
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: documentSourceSelected(source)
                        }
                    }
                }

                Common.BasicSection {
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Títol')

                    Editors.TextAreaEditor3 {
                        id: titleEditor
                        width: parent.width
                        height: units.fingerUnit * 8
                        color: 'white'
                        border.color: 'black'
                        text: title
                    }
                }

                Common.BasicSection {
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Descripció')

                    Editors.TextAreaEditor3 {
                        id: descEditor
                        width: parent.width
                        height: units.fingerUnit * 8
                        color: 'white'
                        border.color: 'black'
                        text: desc
                    }
                }

                Common.BasicSection {
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Tipus')

                    Editors.TextAreaEditor3 {
                        id: mediaTypeEditor
                        width: parent.width
                        height: units.fingerUnit * 8
                        color: 'white'
                        border.color: 'black'
                        text: mediaType
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
                        rows: 2

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
                                onClicked: documentSourceSelected(source)
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
                    }

                }

                Common.BasicSection {
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Anotacions')

                    ListView {
                        width: parent.width
                        height: units.fingerUnit * 10
                        delegate: Text {
                            height: units.fingerUnit * 3
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.pixelSize: units.readUnit
                            text: model.annotation

                            MouseArea {
                                anchors.fill: parent
                                onClicked: annotationEditSelected(annotation, document)
                            }
                        }
                    }

                }

                Common.BasicSection {
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Eliminar')

                    Common.Button {
                        width: parent.width
                        height: units.fingerUnit * 2
                        text: qsTr('Elimina document (immediatament)')
                        onClicked: {
                            documentsModel.removeObject(showDocumentItem.title);
                            documentUpdated();
                        }
                    }
                }
            }
        }
    }

    function getDocumentDetails() {
        documentsModel.select();
        console.log('Document', document);

        var obj = null;
        if (document !== '')
            obj = documentsModel.getObject(document);

        if (obj !== null) {
            title = obj['title'];
            desc = obj['desc'];
            mediaType = obj['type'];
            source = obj['source'];
            hashString = obj['hash'];
        }
    }

    function saveEditorContents() {
        var obj = {
            title: titleEditor.text,
            desc: descEditor.text,
            type: mediaTypeEditor.text
        }

        documentsModel.updateObject(document,obj);
        console.log('saved');
        documentUpdated();
    }


    Component.onCompleted: getDocumentDetails();
}
