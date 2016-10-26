import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///modules/files' as Files
import 'qrc:///modules/basic' as Basic
import 'qrc:///modules/documents' as Documents
import "qrc:///common/FormatDates.js" as FormatDates
import "qrc:///modules/files/mediaTypes.js" as MediaTypes

Rectangle {
    id: docAnnotationsRect

    Common.UseUnits {
        id: units
    }

    property string document: ''
    property string stateValue: ''

    property string periodFilter: ''
    property string periodFilterString: '(start>=? AND end<?) OR (start<? AND end>=?) OR (start>=? AND start<?) OR (end>=? AND end<?)'
    property string periodStart: ''
    property string periodEnd: ''

    property bool filterPeriod: false

    property alias count: docAnnotationsModel.count
    signal annotationSelected(int annotation)
    signal annotationsListSelected2()

    property alias interactive: docAnnotationsList.interactive

    property bool inline: false

    property int requiredHeight: docAnnotationsList.contentItem.height + docAnnotationsList.anchors.margins * 2 + docAnnotationsList.bottomMargin + docAnnotationsHeader.height
    color: 'gray'

    property Item frameItem: parent

    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            id: docAnnotationsHeader

            color: '#C4FFA9'
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 4

            ColumnLayout {
                anchors.fill: parent

                Basic.ButtonsRow {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 1.5

                    color: 'transparent'
                    buttonsSpacing: units.fingerUnit

                    Item {
                        height: parent.height
                        width: parent.height
                    }

                    StateEditor {
                        height: parent.height
                        width: requiredWidth

                        clip: true
                        onStateValueChanged: {
                            stateValue = value;

                            docAnnotationsModel.update();
                        }
                    }

                    Common.SearchBox {
                        height: parent.height
                        width: units.fingerUnit * 4

                        onIntroPressed: {
                            docAnnotationsModel.searchFields = ['title', 'desc', 'document', 'labels'];
                            docAnnotationsModel.searchString = text;
                            docAnnotationsModel.update();
                        }
                    }

                    Text {
                        height: parent.height
                        width: contentWidth
                        font.pixelSize: units.readUnit
                        text: (filterPeriod)?(qsTr('Des de ') + periodStart):''
                    }
                    Text {
                        height: parent.height
                        width: contentWidth
                        font.pixelSize: units.readUnit
                        text: (filterPeriod)?(qsTr('Fins a ') + periodEnd):''
                    }

                    Common.ImageButton {
                        height: parent.height
                        width: height
                        size: height
                        image: 'cog-147414'
                        onClicked: annotationsListOptionsDialog.open();
                    }

                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        Text {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            font.pixelSize: units.readUnit
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: qsTr('Títol i descripció')
                        }
                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: docAnnotationsHeader.width / 6
                            font.pixelSize: units.readUnit
                            font.bold: true
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            verticalAlignment: Text.AlignVCenter
                            text: qsTr('Etiquetes')
                        }
                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: docAnnotationsHeader.width / 3 - stateHeading.width
                            font.pixelSize: units.readUnit
                            font.bold: true
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            verticalAlignment: Text.AlignVCenter
                            text: qsTr('Termini')
                        }
                        Text {
                            id: stateHeading
                            Layout.fillHeight: true
                            Layout.preferredWidth: Math.max(units.fingerUnit, stateHeading.contentWidth)

                            font.pixelSize: units.readUnit
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: qsTr('Estat')
                        }
                    }
                }
            }

        }

        ListView {
            id: docAnnotationsList

            Layout.fillHeight: true
            Layout.fillWidth: true
    //        anchors.margins: units.nailUnit

            clip: true

            model: Models.DocumentAnnotations {
                id: docAnnotationsModel

                sort: 'end ASC, start ASC, id DESC'

                function update() {
                    var stateFilter = '';
                    switch(stateValue) {
                    case '':
                        stateFilter = '1=1';
                        break;
                    case '1':
                        stateFilter = "state='1'";
                        break;
                    case '2':
                        stateFilter = "state='2'";
                        break;
                    case '3':
                        stateFilter = "state='3'";
                        break;
                    case '4':
                        stateFilter = "state='4'";
                        break;
                    case '-1':
                        stateFilter = "state<'0'";
                        break;
                    case '0':
                    default:
                        stateFilter = "state='0' OR state='1' OR state='' OR state IS NULL";
                        break;
                    }

                    // Update filters and bind values

                    var newFilter = [];
                    var newBindValues = [];
                    newFilter.push(stateFilter);

                    if (document !== '') {
                        newFilter.push('document=?');
                        newBindValues.push(document);
                    }
                    if (filterPeriod) {
                        if ((periodStart == '') && (periodEnd == '')) {
                            var today = new Date();
                            periodStart = today.toYYYYMMDDFormat();
                            today.setDate(today.getDate()+1);
                            periodEnd = today.toYYYYMMDDFormat();
                        }
                        newFilter.push(periodFilterString);
                        for (var repeat=1; repeat<=4; repeat++) {
                            newBindValues.push(periodStart, periodEnd);
                        }
                    }

                    docAnnotationsModel.filters = newFilter;
                    docAnnotationsModel.bindValues = newBindValues;

                    docAnnotationsModel.select();
                    console.log('compte', docAnnotationsModel.count);
                }
            }

            interactive: false
            spacing: units.nailUnit

            delegate: Rectangle {
                width: docAnnotationsList.width
                height: units.fingerUnit * 2

                RowLayout {
                    id: singleAnnotationLayout
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        text: '<b>' + model.title + '</b>&nbsp;' + model.desc + ''
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: singleAnnotationLayout.width / 6
                        font.pixelSize: units.readUnit
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        color: 'green'
                        text: model.labels
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: singleAnnotationLayout.width / 6
                        font.pixelSize: units.readUnit
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: 'green'
                        text: (model.start == '')?'---':model.start
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: singleAnnotationLayout.width / 6
                        font.pixelSize: units.readUnit
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: 'red'
                        text: (model.end == '')?'---':model.end
                    }
                    StateDisplay {
                        Layout.fillHeight: true
                        Layout.preferredWidth: units.fingerUnit

                        stateValue: model.state
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: annotationSelected(model.id)
                }
            }

            bottomMargin: (inline)?0:(addAnnotationButton.size + addAnnotationButton.margins)
            footer: (inline)?footerItem:null

            Component {
                id: footerItem

                Item {
                    width: docAnnotationsList.width
                    height: addAnnotationButton.size + addAnnotationButton.margins
                    Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: docAnnotationsList.spacing
                        Button {
                            text: qsTr('Obre llista apart')
                            onClicked: annotationsListSelected2()
                        }
                    }
                }
            }

            Common.SuperposedButton {
                id: addAnnotationButton
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                }
                size: units.fingerUnit * 2
                imageSource: 'plus-24844'
                onClicked: {
                    newAnnotationDialog.load(qsTr('Nova anotació'), 'annotations2/NewAnnotation', {document: document, annotationsModel: docAnnotationsModel, periodStart: periodStart, periodEnd: periodEnd});
                }
            }

        }

    }

    function getDeletedInSelectedAnnotations() {
        var selectedObjects = [];
        for (var i=0; i<docAnnotationsModel.count; i++) {
            var object = docAnnotationsModel.getObjectInRow(i);
            if (object['state'] < 0) {
                selectedObjects.push(object['id']);
            }
        }
        return selectedObjects;
    }

    function destroyDeletedInSelectedAnnotations(selectedObjects) {
        var item = selectedObjects.pop();
        while (item) {
            docAnnotationsModel.removeObject(item);
            item = selectedObjects.pop();
        }
        docAnnotationsModel.update();
    }

    Common.SuperposedWidget {
        id: newAnnotationDialog

        parentWidth: frameItem.width
        parentHeight: frameItem.height

        Connections {
            target: newAnnotationDialog.mainItem

            onNewDrawingAnnotationSelected: {
                newAnnotationDialog.close();
                newAnnotationDialog.load(qsTr('Nou dibuix a mà alçada'), 'whiteboard/CompleteWhiteBoard', {selectedFile: document, zoomedRectangle: Qt.rect(0,0,units.fingerUnit * 10, units.fingerUnit * 6)});
                console.log('new drawing', document);
            }
        }
    }

    Common.SuperposedMenu {
        id: annotationsListOptionsDialog

        parentWidth: frameItem.width
        parentHeight: frameItem.height

        Common.SuperposedMenuEntry {
            text: qsTr('Treu filtre de dates')
            onClicked: {
                annotationsListOptionsDialog.close();
                filterPeriod = false;
                docAnnotationsModel.update();
            }
        }

        Common.SuperposedMenuEntry {
            text: qsTr('Destrueix anotacions eliminades')
            onClicked: {
                annotationsListOptionsDialog.close();
                confirmDestructionDialog.openConfirmation();
            }
        }
    }

    MessageDialog {
        id: confirmDestructionDialog

        property var selectedAnnotations: []
        property int annotationsNumber: 0

        title: qsTr('Confirma la destrucció')

        text: qsTr("Es destruiran ") + annotationsNumber + qsTr(" anotacions. Vols continuar?")

        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: {
            destroyDeletedInSelectedAnnotations(selectedAnnotations);
        }

        function openConfirmation() {
            var selectedObjects = getDeletedInSelectedAnnotations();
            selectedAnnotations = selectedObjects;
            annotationsNumber = selectedObjects.length;
            open();
        }
    }

    Component.onCompleted: docAnnotationsModel.update()
}

