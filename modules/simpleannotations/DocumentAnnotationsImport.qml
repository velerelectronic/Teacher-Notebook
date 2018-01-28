import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import ImageItem 1.0
import 'qrc:///common' as Common

Rectangle {
    id: docAnnotationsImporter

    signal annotationCreated(int identifier)

    property int selectedAnnotationId: -1

    color: 'green'

    Common.UseUnits {
        id: units
    }

    ColumnLayout {
        anchors.fill: parent

        Common.SearchBox {
            id: searchFilter

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            onTextChanged: docAnnotationsModel.update()
        }

        SimpleAnnotationsModel {
            id: simpleAnnotationsModel
        }

        AnnotationTimeMarksModel {
            id: marksModel
        }

        DocumentAnnotationsModel {
            id: docAnnotationsModel

            function update() {
                if (searchFilter.text == '') {
                    searchFields = [];
                } else {
                    searchFields = fieldNames;
                }
                searchString = searchFilter.text
                select();
            }

            Component.onCompleted: update()
        }

        ListView {
            id: annotationsList

            Layout.fillHeight: true
            Layout.fillWidth: true

            clip: true
            spacing: units.nailUnit

            model: docAnnotationsModel

            headerPositioning: ListView.OverlayHeader
            header: Rectangle {
                z: 2
                width: annotationsList.width
                height: units.fingerUnit * 2

                color: '#AAAAAA'

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit

                    Text {
                        Layout.preferredWidth: parent.width / 7
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true

                        text: qsTr('Títol')
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true

                        text: qsTr('Descripció')
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 7
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true

                        text: qsTr('Document i etiquetes')
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 7
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true

                        text: qsTr('Principi i final')
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 7
                        Layout.fillHeight: true
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                        text: qsTr('Font i hash')
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 7
                        Layout.fillHeight: true
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                        text: qsTr('Continguts')
                    }

                    Text {
                        Layout.preferredWidth: parent.width / 7
                        Layout.fillHeight: true
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                        text: qsTr('Estat i creació')
                    }
                }

            }

            delegate: Rectangle {
                z: 1
                width: annotationsList.width
                height: units.fingerUnit * 4

                clip: true

                color: (ListView.isCurrentItem)?'yellow':'white'
                property string title: model.title
                property string desc: model.desc
                property string document: model.document
                property string labels: model.labels
                property string start: model.start
                property string end: model.end
                property string state: model.state
                property string created: model.created
                property string contents: model.contents
                property string hash: model.hash
                property string source: model.source

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit

                    Text {
                        Layout.preferredWidth: parent.width / 7
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight

                        text: model.title
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight

                        text: model.desc
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 7
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight

                        text: model.document + "\n# " + model.labels
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 7
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight

                        text: model.start + " -> " + model.end
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 7
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight

                        text: model.source + "\n" + model.hash
                    }

                    ImageFromBlob {
                        id: imagePreviewer

                        Layout.preferredWidth: parent.width / 7
                        Layout.fillHeight: true

                        data: model.contents
                    }

                    /*
                    Text {
                        Layout.preferredWidth: parent.width / 7
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight

                        text: model.contents
                    }
                    */

                    Text {
                        Layout.preferredWidth: parent.width / 7
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight

                        text: model.state + "\n" + model.created
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        selectedAnnotationId = model[docAnnotationsModel.primaryKey];
                        annotationsList.currentIndex = model.index;
                    }
                }
            }
        }

        Common.TextButton {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2

            text: qsTr('Trasllada')

            onClicked: {
                var sItem = annotationsList.currentItem;
                var document = (sItem.document != '')?(" [" + sItem.document + "]"):''
                var labels = (sItem.labels != '')?(qsTr('Etiquetes: ') + sItem.labels + "\n"):''
                var created = (sItem.created != '')?(qsTr('Creada: ') + sItem.created + "\n"):''
                var state = qsTr('Estat: ') + sItem.state

                // Time marks
                var start = (typeof sItem.start !== 'undefined')?sItem.start:''
                var end = (typeof sItem.end !== 'undefined')?sItem.end:''

                // Another table
                var contents = sItem.contents
                var hash = sItem.hash
                var source = sItem.source

                var annotId = simpleAnnotationsModel.newAnnotation(sItem.title + document, created + labels + state + sItem.desc, 'ImportManager');
                if (annotId > -1) {
                    if (start !== '') {
                        marksModel.insertObject({annotation: annotId, markType: 'start', label: 'ImportManager', timeMark: start});
                    }
                    if (end !== '') {
                        marksModel.insertObject({annotation: annotId, markType: 'end', label: 'ImportManager', timeMark: end});
                    }

                    // Add contents to a special table
                    // *** Still to be built ***

                    annotationCreated(annotId);
                    deleteAfterImportDialog.open();
                }
            }
        }
    }

    MessageDialog {
        id: deleteAfterImportDialog

        title: qsTr("Eliminar anotació")
        text: qsTr("S'ha importat l'anotació dins la nova versió de la base de dades. Vols esborrar l'anotació de la versió anterior?")

        standardButtons: StandardButton.Yes | StandardButton.No

        onYes: removeSelectedAnnotation()
    }

    function removeSelectedAnnotation() {
        if (selectedAnnotationId > -1) {
            docAnnotationsModel.removeObject(selectedAnnotationId);
            docAnnotationsModel.update();
            annotationsList.currentIndex = -1;
            selectedAnnotationId = -1;
        }
    }
}
