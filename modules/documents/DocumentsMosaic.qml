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
    property int documentsNumber
    property int spacing: units.fingerUnit
    property string documentsList: ''

    signal documentSourceSelected(string source)
    signal editorRequested(string file)

    property bool visibleInfo: false

    Common.UseUnits {
        id: units
    }

    ListModel {
        id: documentsListModel
    }

    Models.DocumentsModel {
        id: documentsModel
    }


    ColumnLayout {
        anchors.fill: parent
        spacing: units.nailUnit

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit + 2 * units.nailUnit

            RowLayout {
                id: buttonsLayout

                anchors.fill: parent
                anchors.margins: units.nailUnit
                spacing: units.fingerUnit

                function changeFactor(offset) {
                    // If offset is -1, factor is decreased
                    // If offset is +1, factor is increased
                    var total = columnsNumber * rowsNumber;
                    var factor1 = Math.min(Math.max(columnsNumber + offset,1), total);
                    var factor2 = Math.floor(total / factor1);
                    var found = false;
                    while (factor1 * factor2 !== total) {
                        factor1 = factor1 + offset;
                        factor2 = Math.floor(total / factor1);
                    }
                    columnsNumber = factor1;
                    rowsNumber = factor2;
                    console.log(columnsNumber, rowsNumber);
                }

                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: size
                    size: units.fingerUnit
                    image: 'row-27461'

                    onClicked: buttonsLayout.changeFactor(-1)
                }

                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: size
                    size: units.fingerUnit
                    image: 'column-27460'

                    onClicked: buttonsLayout.changeFactor(+1)
                }

                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: size
                    size: units.fingerUnit
                    image: 'plus-24844'

                    onClicked: newDocumentDialog.addDocumentFromList()
                }

                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: size
                    size: units.fingerUnit
                    image: 'cog-147414'

                    onClicked: visibleInfo = !visibleInfo
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
            }


        }

        GridLayout {
            id: mainGrid

            Layout.fillWidth: true
            Layout.fillHeight: true

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

                        visibleImageInfo: false

                        onEditorRequested: documentsMosaicItem.editorRequested(file)

                        Common.ImageButton {
                            anchors {
                                top: parent.top
                                right: parent.right
                            }

                            size: units.fingerUnit
                            image: 'arrows-145992'
                            visible: visibleInfo

                            onClicked: {
                                documentSourceSelected(singleFileViewer.fileURL);
                            }
                        }

                    }
                }
            }
        }
    }

    Common.SuperposedWidget {
        id: newDocumentDialog

        function addDocumentFromList() {
            load(qsTr('Afegeix document'), 'documents/DocumentsList', {});
        }

        Connections {
            target: newDocumentDialog.mainItem

            onDocumentSelected: {
                newDocumentDialog.close();

                documentsList = documentsList + "\n" + document;
                if (documentsNumber >= columnsNumber * rowsNumber) {
                    rowsNumber++;
                }

                assignDocuments();
            }
        }
    }

    function assignDocuments() {
        var linesArray = documentsList.match(/[^\r\n]+/g);
        var max = columnsNumber * rowsNumber;
        documentsNumber = 0;
        documentsListModel.clear();
        if (linesArray) {
            for (var i=0; i<max; i++) {
                if (i<linesArray.length) {
                    var object = documentsModel.getObject(linesArray[i]);
                    documentsListModel.append({document: linesArray[i], source: object['source']});
                    documentsNumber++;
                } else {
                    documentsListModel.append({document: '', source: ''});
                }
            }
        }
    }

    Component.onCompleted: assignDocuments()
}
