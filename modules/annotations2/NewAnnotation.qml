import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import Qt.labs.folderlistmodel 2.1
import ClipboardAdapter 1.0
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors

Rectangle {
    id: newAnnotationItem

    Common.UseUnits {
        id: units
    }

    signal showMessage(string message)
    signal newDrawingAnnotationSelected(string labels)
    signal close()
    signal discarded()
    signal annotationSelected(int annotation)
    signal annotationCreated(int annotation)

    property string labels: ''
    property string document: ''
    property string periodStart: ''
    property string periodEnd: ''

    property SqlTableModel annotationsModel

    clip: true

    GridView {
        id: optionsGrid

        anchors.fill: parent

        cellWidth: width / 6
        cellHeight: height / 4

        model: ListModel {
            id: optionsModel
        }

        delegate: Rectangle {
            width: optionsGrid.cellWidth
            height: optionsGrid.cellHeight

            border.color: 'black'

            Text {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: units.glanceUnit
                text: (model.buttonType == 'text')?model.info:''
                visible: (model.buttonType == 'text')
            }
            Image {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                source: (model.buttonType == 'image')?model.info:''
                visible: (model.buttonType == 'image')

                fillMode: Image.PreserveAspectFit
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    newAnnotationItem[model.action](model.info);
                }
            }
        }

        function fillOptions() {
            optionsModel.append({buttonType: 'image', info: 'qrc:///icons/paste-35946.svg', action: 'saveClipboardContents'});
            optionsModel.append({buttonType: 'text', info: 'Text', action: 'newWrittenAnnotation'});
            optionsModel.append({buttonType: 'image', info: 'qrc:///icons/palette-23406.svg', action: 'newDrawing'});
            optionsModel.append({buttonType: 'image', info: '///Downloads/', action: ''});
            optionsModel.append({buttonType: 'text', info: 'Importa...', action: 'importAnnotations'});
            updateRecentPictures();
        }
    }

    Component.onCompleted: optionsGrid.fillOptions()

    function saveNewAnnotation() {
        console.log('save new annotation');
        var re = new RegExp("^(.+)\n+((?:.|\n|\r)*)$","g");
        console.log(newAnnotationEditor.content);
        var res = re.exec(newAnnotationEditor.content);
        var date = (new Date()).toYYYYMMDDHHMMFormat();
        var newObj = {
            labels: flowRepeater.model.join(' ').trim(),
            start: (periodStart == '')?date:periodStart,
            end: (periodEnd == '')?date:periodEnd,
            document: newAnnotationItem.document
        }

        if (res != null) {
            newObj['title'] = res[1].trim();
            newObj['desc'] = res[2];
        } else {
            newObj['title'] = newAnnotationEditor.content;
            newObj['desc'] = '';
        }
        if (annotationsModel.insertObject(newObj)) {
            annotationsModel.select();
            close();
        }
    }


    Common.SuperposedWidget {
        id: importDialog

        parentWidth: newAnnotationItem.width / 0.8
        parentHeight: newAnnotationItem.height / 0.8

        function openImportAnnotationsDialog() {
            load(qsTr('Importa anotacions antigues'), 'annotations/RelatedAnnotations', {autoImport: true, document: newAnnotationItem.document});
        }


        Connections {
            target: importDialog.mainItem

            onAnnotationImported: {
                annotationsModel.select();
            }
        }
    }

    Common.SuperposedWidget {
        id: imageImporterDialog

        Connections {
            target: imageImporterDialog.mainItem

            onImportedFileIntoAnnotation: {
                annotationsModel.select();
                imageImporterDialog.close();
                annotationCreated(annotation);
            }
        }

        function openImageImporter(imageUrl) {
            load(qsTr('Importa imatge'), 'files/ImportImageIntoAnnotation', {fileURL: imageUrl});
        }
    }

    FolderListModel {
        id: picturesModel

        property bool hasBeenSetup: false

        showDirs: false
        sortField: FolderListModel.Time
        sortReversed: false

        property int selectedIndex: -1

        folder: "file://" + paths.pictures
        onCountChanged: getPictures()
    }

    function updateRecentPictures() {
        //picturesModel.folder = "file://" + paths.pictures;
        picturesModel.hasBeenSetup = true;
        getPictures();
    }

    function getPictures() {
        for (var i=0; i<picturesModel.count; i++) {
            var url = picturesModel.get(i, 'fileURL');
            optionsModel.append({buttonType: 'image', info: url.toString(), action: 'newImageAnnotation'});
            console.log('new url', url);
            console.log(paths.pictures, picturesModel.folder, url);
        }
    }

    StandardPaths {
        id: paths
    }

    function newWrittenAnnotation() {
        var now = new Date();
        var nowString = now.toYYYYMMDDFormat();
        var newObj = {
            title: qsTr('Nova anotació'),
            start: nowString,
            end: nowString
        };

        insertNewAnnotation(newObj);
    }

    function saveClipboardContents() {
        // We should analyze the mimetype of the clipboard contents to decide how to save them into a new annotation

        var clipcontents = clipboard.text();
        var newObj = {
            title: qsTr('Portapapers') + ' ' + clipcontents.trim(),
            desc: clipcontents
        }

        insertNewAnnotation(newObj);
    }

    function newImageAnnotation(imageUrl) {
        imageImporterDialog.openImageImporter(imageUrl);
    }

    function insertNewAnnotation(newObj) {
        var identifier = annotationsModel.insertObject(newObj);
        console.log('ident', "___", identifier);
        if (identifier) {
            annotationsModel.select();
            annotationCreated(identifier);
            close();
        }
        return identifier;
    }

    function newDrawing() {

    }

    function importAnnotations() {
        importDialog.openImportAnnotationsDialog();
    }

    QClipboard {
        id: clipboard
    }
}
