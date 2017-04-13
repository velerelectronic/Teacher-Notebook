import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
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
    signal openAnnotation(string title)

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
                text: model.info
                visible: (model.buttonType == 'text')
            }
            Image {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                source: model.info
                visible: (model.buttonType == 'image')

                fillMode: Image.PreserveAspectFit
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    newAnnotationItem[model.action]();
                }
            }
        }

        function fillOptions() {
            optionsModel.append({buttonType: 'image', info: 'qrc:///icons/paste-35946.svg', action: 'saveClipboardContents'});
            optionsModel.append({buttonType: 'text', info: 'Text', action: 'newWrittenAnnotation'});
            optionsModel.append({buttonType: 'image', info: 'qrc:///icons/palette-23406.svg', action: 'newDrawing'});
            optionsModel.append({buttonType: 'image', info: '///Downloads/', action: ''});
            optionsModel.append({buttonType: 'text', info: 'Importa...', action: 'importAnnotations'});
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

    function newWrittenAnnotation() {
        var now = new Date();
        var nowString = now.toYYYYMMDDFormat();
        var newObj = {
            title: qsTr('Nova anotació'),
            start: nowString,
            end: nowString
        };

        if (annotationsModel.insertObject(newObj)) {
            annotationsModel.select();
            close();
        }
    }

    function saveClipboardContents() {
        // We should analyze the mimetype of the clipboard contents to decide how to save them into a new annotation

        var clipcontents = clipboard.text();
        var newObj = {
            title: qsTr('Portapapers') + ' ' + clipcontents.trim(),
            desc: clipcontents
        }

        if (annotationsModel.insertObject(newObj)) {
            annotationsModel.select();
            close();
        }
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
