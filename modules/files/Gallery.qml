import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import Qt.labs.folderlistmodel 2.1
import 'qrc:///common' as Common
import 'qrc:///modules/basic' as Basic

import PersonalTypes 1.0

Rectangle {
    id: galleryItem

    signal openCard(string page, var pageProperties, var cardProperties)
    signal connectToNextCard(var connections)

    Common.UseUnits {
        id: units
    }


    property alias showDirs: folderListModel.showDirs
    property string rootDir
    property alias folder: folderListModel.folder
    property string selectedFile: ''

    property int numberOfColumns: 3

    signal imageViewerSelected(string file)
    signal annotationSelected(int annotation)
    signal fileSelected(string file)
    signal folderSelected(string folder)

    color: 'transparent'


    Common.SuperposedWidget {
        id: rootChangeDialog

        Connections {
            target: rootChangeDialog.mainItem

            onFolderSelected: {
            }
        }
    }

    function gotoPrevious() {
        var index = folderListModel.indexOf(selectedFile);
        if (index > 0) {
            selectedFile = folderListModel.get(index-1, "fileURL");
            imageViewerSelected(selectedFile);
        }
    }

    function gotoNext() {
        var index = folderListModel.indexOf(selectedFile);
        if (index < folderListModel.count-1) {
            selectedFile = folderListModel.get(index+1, "fileURL");
            imageViewerSelected(selectedFile);
        }
    }

    ColumnLayout {
        id: galleryColumnLayout

        anchors.fill: parent

        Basic.ButtonsRow {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit + units.nailUnit * 2

            Button {
                height: units.fingerUnit
                text: qsTr('més petit')
                onClicked: {
                    numberOfColumns = numberOfColumns + 1;
                }
            }

            Rectangle {
                border.color: 'black'
                height: units.fingerUnit
                width: units.fingerUnit * 2

                Rectangle {
                    anchors {
                        top: parent.top
                        left: parent.left
                        bottom: parent.bottom
                        margins: parent.border.width
                    }
                    color: 'green'
                    width: (parent.width - 2 * parent.border.width) / numberOfColumns
                }
            }

            Button {
                height: units.fingerUnit
                text: qsTr('MÉS GROS')
                onClicked: {
                    numberOfColumns = Math.max(numberOfColumns - 1,1)
                }
            }

            Button {
                height: units.fingerUnit
                text: qsTr('Arrel ') + folder
                onClicked: openRootChange(galleryItem.folder)
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

            delegate: Rectangle {
                id: singleFileItem
                width: folderView.cellWidth
                height: folderView.cellHeight

                property bool isCurrentItem: model.fileURL == selectedFile

                color: (isCurrentItem)?'yellow':'transparent'
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
                        selectedFile = model.fileURL;
                        imageViewerSelected(selectedFile);
                        fileSelected(selectedFile);
                    }
                    onPressAndHold: {
                        importIntoAnnotationDialog.importImage(model.fileURL);
                    }
                }

                Image {
                    id: fileImage

                    z: 1
                    anchors.fill: singleFileRect
                    asynchronous: true

                    sourceSize: Qt.size(width, height)

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
        id: importIntoAnnotationDialog

        function importImage(fileURL) {
            load(qsTr('Importa imatge'), 'files/ImportImageIntoAnnotation', {fileURL: fileURL});
            open();
        }

        Connections {
            target: importIntoAnnotationDialog.mainItem

            onImportedFileIntoAnnotation: {
                var newAnnotation = annotation;
                importIntoAnnotationDialog.close();
                annotationSelected(newAnnotation);
            }
        }
    }

    StandardPaths {
        id: paths
    }

    function setPicturesFolder() {
        folderListModel.folder = 'file://' + paths.pictures
    }

    Connections {
        id: secondConnections

        ignoreUnknownSignals: true

        onFolderSelected: {
            folderListModel.folder = folder;
            folderSelected(folder);
        }
    }

    function openRootChange(folder) {
        openCard('files/FileSelector', {selectDirectory: true, initialDirectory: folder}, {headingText: qsTr('Directoris'), headingColor: 'black'});
        connectToNextCard(secondConnections);
    }

}

