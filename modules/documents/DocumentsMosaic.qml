import QtQuick 2.7
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///modules/files' as Files
import 'qrc:///modules/pagesfolder' as Pages

Item {
    id: documentsMosaicItem

    property int columnsNumber: 3
    property int rowsNumber: 3
    property int spacing: units.fingerUnit
    property string documentsList: ''

    signal editorRequested(string file)

    Common.UseUnits {
        id: units
    }

    ListModel {
        id: documentsListModel
    }

    Models.DocumentsModel {
        id: documentsModel
    }

    GridLayout {
        id: mainGrid

        anchors.fill: parent

        rows: rowsNumber
        columns: columnsNumber

        Repeater {
            model: documentsListModel

            Rectangle {
                id: singleLayoutRectangle

                Layout.fillWidth: true
                Layout.fillHeight: true

                border.color: 'black'
                color: 'white'

                Files.FileViewer {
                    id: singleFileViewer

                    anchors.fill: parent
                    fileURL: model.source
                    clip: true

                    MouseArea {
                        anchors.fill: parent
                        enabled: false
                        propagateComposedEvents: true

                        onDoubleClicked: {
                            if (singleFileViewer.parent == documentsMosaicItem) {
                                singleFileViewer.parent = singleLayoutRectangle;
                            } else {
                                singleFileViewer.parent = documentsMosaicItem;
                            }
                        }
                    }

                    onEditorRequested: documentsMosaicItem.editorRequested(file)
                }
            }
        }
    }


    function assignDocuments() {
        var linesArray = documentsList.match(/[^\r\n]+/g);
        var max = Math.min(linesArray.length, columnsNumber * rowsNumber);
        for (var i=0; i<max; i++) {
            var object = documentsModel.getObject(linesArray[i]);
            documentsListModel.append({document: linesArray[i], source: object['source']});
        }
    }

    Component.onCompleted: assignDocuments()
}
