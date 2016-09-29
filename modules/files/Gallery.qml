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
    property string selectedFile: ''

    property int numberOfColumns: 3

    signal imageViewerSelected(string file)

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

    StackView {
        id: stackView

        anchors.fill: parent

        initialItem: galleryColumnLayout

        Item {
            z: 2
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: units.fingerUnit * 1.5

            visible: stackView.depth>1

            RowLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                spacing: units.nailUnit

                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    image: 'road-sign-147409'
                    onClicked: {
                        stackView.pop()
                    }
                }

                Text {
                    id: titleText

                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        function getFileViewerItem() {
            return find(function(item,index) {
                return item.objectName == 'FileViewer';
            });
        }

        function loadImageViewer() {
            if (!getFileViewerItem()) {
                console.log(Qt.resolvedUrl('FileViewer.qml'));
                push(Qt.resolvedUrl('FileViewer.qml'), {objectName: 'FileViewer', fileURL: selectedFile});
            }
        }

        function loadWhiteboardEditor(file) {
            var args = {selectedFile: file};
            push(Qt.resolvedUrl('../whiteboard/WhiteboardWithZoom.qml'), args);
        }

        Connections {
            target: stackView.currentItem
            ignoreUnknownSignals: true

            // Connections for FileViewer

            onClosed: {
                folderView.currentIndex = -1;
            }

            onGotoPrevious: {
                folderView.currentIndex = (folderView.currentIndex>0)?folderView.currentIndex-1:-1;
            }

            onGotoNext: {
                folderView.currentIndex = (folderView.currentIndex<folderView.count-1)?folderView.currentIndex+1:-1;
            }

            onEditorRequested: stackView.loadWhiteboardEditor(file)

            // Connections with the whiteboard

            onSavedImage: {
                var obj = stackView.getFileViewerItem();
                if (obj) {
                    obj.reload();
                }
            }

            onClose: stackView.pop();
        }
    }

    ColumnLayout {
        id: galleryColumnLayout

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

            property int spacing: units.nailUnit / 2

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
                        imageViewerSelected(model.fileURL)
                    }
                }

                Image {
                    id: fileImage

                    z: 1
                    anchors.fill: singleFileRect
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
}
