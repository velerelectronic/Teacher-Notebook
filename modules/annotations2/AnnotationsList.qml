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
import 'qrc:///modules/cards' as Cards
import 'qrc:///modules/calendar' as Calendar
import "qrc:///common/FormatDates.js" as FormatDates
import "qrc:///modules/files/mediaTypes.js" as MediaTypes

Rectangle {
    id: docAnnotationsRect

    Common.UseUnits {
        id: units
    }

    property string document: ''
    property string stateValue: '0'

    property bool   filterPeriod: false
    property string selectedDate: ''


    property bool previewEnabled: true

    property alias searchString: docAnnotationsModel.searchString
    property alias count: docAnnotationsModel.count
    signal annotationSelected(int annotation)
    signal annotationsListSelected2()

    property bool inline: false

    property int requiredHeight: annotationsView2.contentItem.height + annotationsView2.anchors.margins * 2 + annotationsView2.bottomMargin + annotationsView2.headingBar.height

    color: 'transparent'

    property Item frameItem: parent

    GridLayout {
        id: mainLayout

        property bool verticalLayout: mainLayout.width < mainLayout.height

        anchors.fill: parent
        rows: (verticalLayout)?2:1
        columns: (verticalLayout)?1:2

        Common.GeneralListView {
            id: annotationsView2

            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: true

            property int selectedAnnotation: -1
            property string selectedText: ''
            property int selectedStateValue: 0

            model: SqlTableModel {
                id: docAnnotationsModel

                primaryKey: 'id'
                tableName: 'documentAnnotations'
                fieldNames: ['id', 'document', 'title', 'desc', 'created', 'labels', 'start', 'end', 'state', 'source', 'contents', 'hash']
                searchFields: ['title', 'desc', 'document', 'labels']
                limit: 10

                function update() {
                    var newBindValues = [];

                    // Prepare state filter

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
                    stateFilter = " (" + stateFilter + ")";

                    // Prepare date filter

                    var dateFilterString = "";
                    if (filterPeriod) {
                        if (selectedDate == '') {
                            var today = new Date();
                            selectedDate = today.toYYYYMMDDFormat();
                        }
                        dateFilterString = "(IFNULL(start, '') != '' OR IFNULL(end, '') != '') AND (IFNULL(start, '') = '' OR INSTR(start, ?) OR start <= ?) AND (IFNULL(end,'') = '' OR INSTR(end, ?) OR end >= ?)";
                        dateFilterString = " AND (" + dateFilterString + ")";

                        for (var repeat=1; repeat<=4; repeat++) {
                            newBindValues.push(selectedDate);
                        }
                    }

                    // Prepare looking for strings
                    var searchFilter = "";
                    var fieldsCount = searchFields.length;

                    if (searchString !== "") {
                        searchFilter = getSearchString();
                        for (var i=1; i<=fieldsCount; i++) {
                            newBindValues.push(searchString);
                        }
                        searchFilter = " AND (" + searchFilter + ")";
                    }

                    newBindValues.push(docAnnotationsModel.limit);

                    // Execute query with previous filters

                    bindValues = newBindValues;
                    select(
                                "SELECT " + fieldNames.join(", ") + " FROM documentAnnotations WHERE"
                                + stateFilter
                                + dateFilterString
                                + searchFilter
                                + " ORDER BY end ASC, start ASC, id DESC LIMIT ?");
                }

                function updateAnnotation(id, data) {
                    updateObject(id, data);
                    update();
                }
            }

            toolBarHeight: (units.fingerUnit + units.nailUnit) * 4

            toolBar: Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: units.nailUnit

                    Basic.ButtonsRow {
                        id: annotationsListButtons

                        color: '#AAFFAA'
                        clip: true

                        Layout.fillWidth: true
                        Layout.fillHeight: true

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
                                filterPeriod = false;
                                docAnnotationsModel.searchFields = ['title', 'desc', 'document', 'labels'];
                                docAnnotationsModel.searchString = text;
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

                            image: 'check-mark-303498'
                            onClicked: {
                                annotationsView2.toggleSelection()
                            }
                        }
                    }

                    Calendar.CalendarStripe {
                        verticalLayout: false

                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        onDateSelected: {
                            console.log('date type', date, typeof date);
                            if (date !== '') {
                                docAnnotationsRect.selectedDate = date;
                                filterPeriod = true;
                            } else {
                                filterPeriod = false;
                            }

                            docAnnotationsModel.update();
                        }
                    }
                }

            }

            headingBar: Rectangle {
                id: docAnnotationsHeader

                color: '#DDFFDD'

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

            delegate: Item {
                id: wholeAnnotationItem

                width: annotationsView2.width
                height: units.fingerUnit * 2 + attachmentsSection.height + annotationPreviewRect.height

                property bool hasAttachments: false // model.image

                states: [
                    State {
                        name: 'simple'
                        PropertyChanges {
                            target: singleAnnotationRect
                            x: 0
                        }
                        StateChangeScript {
                            script: annotationPreviewLoader.closePreviewer()
                        }
                        PropertyChanges {
                            target: annotationPreviewRect
                            height: 0
                        }
                    },
                    State {
                        name: 'moving'
                    },
                    State {
                        name: 'stateControls'
                        PropertyChanges {
                            target: singleAnnotationRect
                            x: -annotationStateEditor.requiredWidth - units.nailUnit
                        }
                    },
                    State {
                        name: 'preview'
                        StateChangeScript {
                            script: annotationPreviewLoader.openPreviewer()
                        }
                        PropertyChanges {
                            target: annotationPreviewRect
                            height: annotationsView2.height
                        }
                        PropertyChanges {
                            target: singleAnnotationRect
                            color: '#AAAAAA'
                            x: 0
                        }
                    }

                ]
                state: 'simple'

                transitions: [
                    Transition {
                        from: 'moving'

                        NumberAnimation {
                            target: singleAnnotationRect
                            properties: "x"
                            duration: 250
                        }
                    },
                    Transition {
                        from: 'stateControls'

                        NumberAnimation {
                            target: singleAnnotationRect
                            properties: "x"
                            duration: 250
                        }
                    }
                ]

                StateEditor {
                    id: annotationStateEditor

                    anchors {
                        top: parent.top
                        right: parent.right
                        bottom: parent.bottom
                    }
                    width: requiredWidth
                    z: 0

                    onStateValueChanged: {
                        docAnnotationsModel.updateAnnotation(model.id, {state: value});
                    }
                }

                Rectangle {
                    id: singleAnnotationRect

                    y: 0
                    z: 1
                    width: parent.width
                    height: units.fingerUnit * 2

                    // Annotation selected: gray
                    color: (annotationsView2.selectedAnnotation == model.id)?'#AAAAAA':'white'

                    Rectangle {
                        id: attachmentsSection

                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                        }
                        height: wholeAnnotationItem.hasAttachments?(units.fingerUnit * 2):0

                        Loader {
                            id: attachedImageLoader

                            anchors.fill: parent
                        }
                    }

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

                        drag.target: singleAnnotationRect
                        drag.axis: Drag.XAxis
                        property bool dragIsActive: drag.active

                        onDragIsActiveChanged: {
                            if (dragIsActive) {
                                if (wholeAnnotationItem.state == 'simple')
                                    wholeAnnotationItem.state = 'moving';
                            } else {
                                if ((wholeAnnotationItem.state == 'stateControls') || (singleAnnotationRect.x > -units.fingerUnit * 2)) {
                                    wholeAnnotationItem.state = 'simple';
                                } else {
                                    wholeAnnotationItem.state = 'stateControls';
                                }
                            }
                        }

                        onClicked: {
                            if (wholeAnnotationItem.state == 'preview')
                                wholeAnnotationItem.state = 'simple';
                            else {
                                if (previewEnabled)
                                    wholeAnnotationItem.state = 'preview';
                                else
                                    annotationSelected(model.id);
                            }
                            //annotationPreviewDialog.openAnnotationPreview(model.id);
                            //annotationSelected(model.id);
                        }
                        onPressAndHold: {
                            annotationsView2.selectedAnnotation = model.id;
                            annotationsView2.selectedText = model.title;
                            annotationsView2.selectedStateValue = model.state;
                            annotationsView2.enableSelection();
                        }
                    }
                }

                Rectangle {
                    id: annotationPreviewRect

                    z: 2
                    anchors {
                        top: singleAnnotationRect.bottom
                        left: parent.left
                        right: parent.right
                    }
                    height: 0
                    clip: true

                    Loader {
                        id: annotationPreviewLoader

                        anchors.fill: parent

                        property int annotation

                        function openPreviewer() {
                            annotation = model.id;
                            setSource('qrc:///modules/annotations2/AnnotationPreview.qml', {identifier: model.id});
                        }

                        function closePreviewer() {
                            sourceComponent = undefined;
                        }

                        Connections {
                            target: annotationPreviewLoader.item

                            onAnnotationSelected: {
                                docAnnotationsRect.annotationSelected(annotationPreviewLoader.annotation);
                            }

                        }
                    }
                }

            }


            selectionBox: Rectangle {
                color: 'yellow'
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.fingerUnit

                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: units.readUnit
                        font.bold: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: annotationsView2.selectedText
                    }

                    Common.TextButton {
                        Layout.fillHeight: true
                        Layout.preferredWidth: contentWidth
                        text: qsTr('Estat')

                        onClicked: stateEditorDialog.open()
                    }
                    Common.TextButton {
                        Layout.fillHeight: true
                        Layout.preferredWidth: contentWidth
                        text: qsTr('Inici')
                    }
                    Common.TextButton {
                        Layout.fillHeight: true
                        Layout.preferredWidth: contentWidth
                        text: qsTr('Final')
                    }

                    Common.ImageButton {
                        Layout.fillHeight: true
                        Layout.preferredWidth: height

                        image: 'road-sign-147409'

                        onClicked: {
                            annotationsView2.disableSelection();
                        }
                    }
                }
            }

            footerBar: (inline)?footerItem:moreOptionsComponent

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


    Component {
        id: footerItem

        Item {
            width: annotationsView2.width
            height: addAnnotationButton.size + addAnnotationButton.margins
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: annotationsView2.spacing
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
            width: annotationsView2.width
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

    Common.SuperposedMenu {
        id: stateEditorDialog

        parentWidth: parent.width

        title: qsTr("Edita l'estat")
        standardButtons: StandardButton.Save | StandardButton.Cancel

        StateEditor {
            id: stateEditor

            width: parent.width
            height: units.fingerUnit * 3
            content: annotationsView2.selectedStateValue
        }

        onAccepted: {
            docAnnotationsModel.updateObject(annotationsView2.selectedAnnotation, {state: stateEditor.content});
            docAnnotationsModel.update();
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

            onAnnotationCreated: {
                newAnnotationDialog.close();
                docAnnotationsRect.annotationSelected(annotation);
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

