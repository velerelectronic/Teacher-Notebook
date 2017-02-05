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
    property string stateValue: '0'

    property string dateFilterString: "(IFNULL(start, '') != '' OR IFNULL(end, '') != '') AND (IFNULL(start, '') = '' OR INSTR(start, ?) OR start <= ?) AND (IFNULL(end,'') = '' OR INSTR(end, ?) OR end >= ?)"
    property bool   filterPeriod: false
    property string selectedDate: ''


    property alias searchString: docAnnotationsModel.searchString
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
                    id: annotationsListButtons
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 1.5

                    color: 'transparent'
                    buttonsSpacing: units.fingerUnit

                    Item {
                        height: annotationsListButtons.height
                        width: annotationsListButtons.height
                    }

                    StateEditor {
                        height: annotationsListButtons.height
                        width: requiredWidth

                        clip: true
                        onStateValueChanged: {
                            stateValue = value;

                            docAnnotationsModel.update();
                        }
                    }

                    Common.SearchBox {
                        id: searchBox

                        height: annotationsListButtons.height
                        width: units.fingerUnit * 4

                        text: docAnnotationsRect.searchString

                        onIntroPressed: {
                            docAnnotationsModel.searchFields = ['title', 'desc', 'document', 'labels'];
                            docAnnotationsModel.searchString = text;
                            docAnnotationsModel.update();
                        }
                    }

                    Common.ImageButton {
                        height: annotationsListButtons.height
                        width: height
                        image: 'arrow-145769'
                        onClicked: {
                            var date = new Date();
                            date.fromYYYYMMDDFormat(selectedDate);
                            date.setDate(date.getDate()-1);
                            selectedDate = date.toYYYYMMDDFormat();
                            docAnnotationsModel.update();
                        }
                    }

                    Text {
                        height: annotationsListButtons.height
                        width: Math.max(contentWidth, units.fingerUnit * 2)
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: units.readUnit
                        text: {
                            var date = new Date();
                            date.fromYYYYMMDDFormat(selectedDate);
                            return (filterPeriod)?(date.toLongDate()):'';
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: annotationsListOptionsDialog.open();
                        }
                    }

                    Common.ImageButton {
                        height: annotationsListButtons.height
                        width: height
                        image: 'arrow-145766'
                        onClicked: {
                            var date = new Date();
                            date.fromYYYYMMDDFormat(selectedDate);
                            date.setDate(date.getDate()+1);
                            selectedDate = date.toYYYYMMDDFormat();
                            docAnnotationsModel.update();
                        }
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
                limit: 10
                searchFields: ['title', 'desc', 'document', 'labels']

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
                        if (selectedDate == '') {
                            var today = new Date();
                            selectedDate = today.toYYYYMMDDFormat();
                        }
                        newFilter.push(dateFilterString);
                        for (var repeat=1; repeat<=4; repeat++) {
                            newBindValues.push(selectedDate);
                        }
                    }

                    docAnnotationsModel.filters = newFilter;
                    docAnnotationsModel.bindValues = newBindValues;

                    docAnnotationsModel.searchString = searchString;

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
            footer: (inline)?footerItem:moreOptionsComponent

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

            Component {
                id: moreOptionsComponent

                Rectangle {
                    width: docAnnotationsList.width
                    height: units.fingerUnit * 2
                    color: '#AAFFAA'

                    RowLayout {
                        anchors.fill: parent
                        spacing: units.fingerUnit

                        Text {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            font.pixelSize: units.readUnit
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter

                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: docAnnotationsModel.count + qsTr(' anotacions')
                        }

                        Button {
                            Layout.fillHeight: true
                            Layout.fillWidth: mustShow
                            visible: mustShow

                            property bool mustShow: (docAnnotationsModel.limit>0) && (docAnnotationsModel.count == docAnnotationsModel.limit)

                            text: docAnnotationsModel.limit + qsTr(' primers. Més...')

                            onClicked: {
                                docAnnotationsModel.limit = docAnnotationsModel.limit + 10;
                                docAnnotationsModel.update();
                            }
                        }

                        Button {
                            Layout.fillHeight: true
                            Layout.fillWidth: mustShow
                            visible: mustShow

                            property bool mustShow: stateValue !== ''

                            text: qsTr('Només entrada. Mostra qualsevol tipus')

                            onClicked: {
                                stateValue = '';
                                docAnnotationsModel.update();
                            }
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
                    newAnnotationDialog.load(qsTr('Nova anotació'), 'annotations2/NewAnnotation', {document: document, annotationsModel: docAnnotationsModel, periodStart: selectedDate, periodEnd: selectedDate});
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

