import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import Qt.labs.folderlistmodel 2.1
import 'qrc:///common' as Common

Rectangle {
    id: galleryItem

    property alias showDirs: folderListModel.showDirs
    property string rootDir
    property alias folder: folderListModel.folder

    property int numberOfColumns: 3

    color: 'gray'

    Common.UseUnits {
        id: units
    }

    Common.SuperposedWidget {
        id: rootChangeDialog

        function openRootChange() {
            load(qsTr("Canvia el directori arrel"),'files/FileSelector', {selectDirectory: true, initialDirectory: folder});
            open();
        }

        Connections {
            target: rootChangeDialog.mainItem

            onFolderSelected: {
                folderListModel.folder = folder;
                console.log('root folder', folderListModel.folder);
                rootChangeDialog.close();
            }
        }
    }

    FileViewer {
        id: bigImageItem
        z: 2
        anchors.fill: parent

        visible: false
        color: 'white'

        onClosed: {
            folderView.currentIndex = -1;
        }

        onGotoPrevious: {
            folderView.currentIndex = (folderView.currentIndex>0)?folderView.currentIndex-1:-1;
        }

        onGotoNext: {
            folderView.currentIndex = (folderView.currentIndex<folderView.count-1)?folderView.currentIndex+1:-1;
        }

        onEditorRequested: editorWidget.openWhiteBoardEditor(fileURL)
    }

    ColumnLayout {
        anchors.fill: parent
        z: 1

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 1.5

            RowLayout {
                anchors.fill: parent
                spacing: units.nailUnit
                Button {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 3
                    text: qsTr('Arrel ') + folder
                    onClicked: rootChangeDialog.openRootChange()
                }
                Button {
                    Layout.fillHeight: true
                    text: qsTr('MÉS GROS')
                    onClicked: {
                        numberOfColumns = Math.max(numberOfColumns - 1,1)
                    }
                }
                Common.BoxedText {
                    Layout.fillHeight: true
                    Layout.preferredWidth: contentWidth
                    fontSize: units.glanceUnit
                    margins: units.fingerUnit
                    horizontalAlignment: Text.AlignHCenter
                    textColor: 'white'
                    text: numberOfColumns
                }

                Button {
                    Layout.fillHeight: true
                    text: qsTr('més petit')
                    onClicked: {
                        numberOfColumns = numberOfColumns + 1;
                    }
                }
            }
        }

        GridView {
            id: folderView

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            model: folderListModel

            cellWidth: Math.floor(folderView.width / numberOfColumns)
            cellHeight: Math.min(folderView.cellWidth,folderView.height / 2)

            currentIndex: -1

            property int spacing: units.nailUnit / 2

            onCurrentIndexChanged: {
                if (currentIndex<0)
                    bigImageItem.close();
                else
                    bigImageItem.load();
            }

            delegate: Item {
                id: singleFileItem
                width: folderView.cellWidth
                height: folderView.cellHeight

                property bool isCurrentItem: folderView.currentIndex == model.index

                Rectangle {
                    id: singleFileRect
                    z: 1
                    anchors.fill: parent
                    anchors.margins: folderView.spacing
                }

                Rectangle {
                    z: 2
                    anchors {
                        top: parent.top
                        left: parent.left
                        margins: folderView.spacing
                    }
                    width: Math.min(fileNameText.contentWidth + 2 * fileNameText.anchors.margins, singleFileRect.width)
                    height: fileNameText.contentHeight + fileNameText.anchors.margins * 2
                    color: 'gray'

                    Text {
                        id: fileNameText
                        anchors {
                            top: parent.top
                            left: parent.left
                        }
                        width: singleFileRect.width

                        anchors.margins: units.nailUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: units.readUnit
                        color: 'white'
                        text: model.fileName
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        folderView.currentIndex = model.index;
                    }
                }

                onIsCurrentItemChanged: {
                    if (singleFileItem.isCurrentItem) {
                        bigImageItem.fileURL = model.fileURL;
                    }
                }

                Image {
                    id: fileImage

                    z: 1
                    anchors.fill: parent
                    asynchronous: true

                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignLeft
                    verticalAlignment: Image.AlignHCenter

                    property string ext: ''

                    Component.onCompleted: {
                        fileImage.ext = folderListModel.getFileExtension(model.fileURL).toLowerCase();
                        switch(fileImage.ext) {
                        case 'bmp':
                        case 'jpg':
                        case 'jpeg':
                        case 'gif':
                        case 'png':
                        case 'svg':
                            fileImage.source = model.fileURL;
                            break;
                        default:
                            notRecognisedText.visible = true;
                            break;
                        }
                    }
                }

                Text {
                    id: notRecognisedText

                    z: 3
                    anchors.fill: singleFileRect
                    anchors.margins: units.nailUnit
                    visible: false
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTr('No reconegut');
                }
            }
        }

    }

    FolderListModel {
        id: folderListModel

        // folder: 'file:///'
        showDirs: false
        showDotAndDotDot: false
        showFiles: true
        showHidden: false
        showOnlyReadable: true
        sortField: FolderListModel.Name

        rootFolder: rootDir

        function getFileExtension(name) {
            var match = /(?:\.)([^.]+)$/.exec(name);
            return match[1];
        }
    }

    Common.SuperposedWidget {
        id: editorWidget

        parentWidth: parent.width * 0.8
        parentHeight: parent.height * 0.8

        function openWhiteBoardEditor(file) {
            load(qsTr('Edita imatge'), 'whiteboard/WhiteboardWithZoom', {selectedFile: file});
        }

        Connections {
            target: editorWidget.mainItem

            onSavedImage: bigImageItem.reload()
        }
    }
}
