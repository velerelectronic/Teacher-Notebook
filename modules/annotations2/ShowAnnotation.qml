import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import QtQuick.Dialogs 1.2

import ClipboardAdapter 1.0
import PersonalTypes 1.0

import ImageItem 1.0

import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import 'qrc:///modules/documents' as Documents
import 'qrc:///modules/calendar' as Calendar
import 'qrc:///modules/files' as Files
import 'qrc:///modules/connections' as AnnotationsConnections

Rectangle {
    id: showAnnotationItem

    signal annotationSelected(int annotation)
    signal annotationLabelsSelected(string labels)
    signal annotationPeriodSelected(string start, string end)
    signal attachmentsSelected()
    signal documentSelected(string document)
    signal newRubricAssessment(string annotation)
    signal resourceSelected(int resource)
    signal rubricAssessmentSelected(int assessment)
    signal showRelatedAnnotationsByLabels()
    signal showRelatedAnnotationsByPeriod()

    property var sharedObject: null

    property int identifier
    property string title: ''
    property string descText: ''
    property string labels: ''
    property string periodStart: ''
    property string periodEnd: ''
    property int stateValue: 0
    property string document: ''

    color: 'transparent'

    Common.UseUnits {
        id: units
    }

    Models.DocumentAnnotations {
        id: annotationsModel
        //limit: 6
    }

    MarkDownParser {
        id: parser
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit

        Common.HorizontalStaticMenu {
            id: optionsMenu
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2

            spacing: units.nailUnit
            underlineColor: 'orange'
            underlineWidth: units.nailUnit

            sectionsModel: annotationSectionsModel
            connectedList: partsList
        }

        ListView {
            id: partsList
            Layout.fillWidth: true
            Layout.fillHeight: true

            visible: partsList.enabled
            enabled: !editorArea.enabled

            clip: true

            spacing: units.fingerUnit

            model: ObjectModel {
                id: annotationSectionsModel

                Common.BasicSection {
                    width: partsList.width
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Principal')

                    Rectangle {
                        id: headerData
                        width: parent.width
                        height: childrenRect.height
                        border.color: 'black'

                        GridLayout {
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }

                            columns: 3

                            columnSpacing: units.nailUnit * 2
                            rowSpacing: units.nailUnit * 2

                            Text {
                                width: headerData.width / 2
                                height: units.fingerUnit
                                font.pixelSize: units.readUnit
                                text: qsTr('Anotació:')
                            }
                            Text {
                                Layout.fillWidth: true
                                height: contentHeight
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: units.readUnit
                                elide: Text.ElideRight
                                text: showAnnotationItem.title
                            }
                            Item {
                                width: units.fingerUnit * 2
                                height: units.fingerUnit
                            }

                            Text {
                                font.pixelSize: units.readUnit
                                text: qsTr('Període:')
                            }

                            Rectangle {
                                id: periodText

                                Layout.fillWidth: true
                                Layout.preferredHeight: childrenRect.height

                                property int durationInDays: 0

                                Flow {
                                    anchors {
                                        top: parent.top
                                        left: parent.left
                                        right: parent.right
                                    }
                                    height: childrenRect.height

                                    spacing: units.nailUnit

                                    Text {
                                        id: startText
                                        width: Math.max(contentWidth, units.fingerUnit * 4)
                                        height: units.fingerUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        font.pixelSize: units.readUnit
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: showRelatedAnnotationsByPeriod();
                                        }
                                    }

                                    Repeater {
                                        model: periodText.durationInDays

                                        delegate: Rectangle {
                                            width: units.fingerUnit
                                            height: units.fingerUnit

                                            color: 'orange'
                                        }
                                    }

                                    Text {
                                        id: endText
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: Math.max(contentWidth, units.fingerUnit * 4)
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        font.pixelSize: units.readUnit
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: showRelatedAnnotationsByPeriod();
                                        }
                                    }

                                }
                            }

                            Common.ImageButton {
                                id: changePeriodButton
                                Layout.fillHeight: true
                                Layout.preferredWidth: size
                                size: units.fingerUnit
                                image: 'edit-153612'
                                onClicked: periodEditor.openPeriodEditor()
                            }

                            Text {
                                font.pixelSize: units.readUnit
                                text: qsTr('Etiquetes:')
                            }
                            Text {
                                id: labelsText
                                Layout.preferredHeight: contentHeight
                                Layout.fillWidth: true
                                color: 'green'
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.readUnit
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: showRelatedAnnotationsByLabels()
                                }
                            }
                            Common.ImageButton {
                                id: changeLabelsButton
                                image: 'edit-153612'
                                size: units.fingerUnit
                                Layout.fillHeight: true
                                Layout.preferredWidth: size
                                onClicked: annotationLabelsSelected(showAnnotationItem.labels)
                            }

                            Text {
                                font.pixelSize: units.readUnit
                                text: qsTr('Estat:')
                            }
                            StateDisplay {
                                id: stateComponent

                                Layout.preferredWidth: units.fingerUnit * 2
                                Layout.preferredHeight: stateComponent.requiredHeight

                                stateValue: showAnnotationItem.stateValue

                                onClicked: stateEditorDialog.open()
                            }
                            Item {
                                width: units.fingerUnit * 2
                            }

                            Text {
                                Layout.preferredHeight: documentText.height
                                Layout.alignment: Qt.AlignVCenter
                                font.pixelSize: units.readUnit
                                text: qsTr('Document:')
                            }
                            Text {
                                id: documentText
                                Layout.fillWidth: true
                                Layout.preferredHeight: Math.max(contentHeight, units.fingerUnit * 2)
                                Layout.alignment: Qt.AlignVCenter
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: document
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: documentSelected(document);
                                }
                            }
                            Common.ImageButton {
                                id: changeDocumentButton
                                image: 'edit-153612'
                                size: units.fingerUnit
                                Layout.fillHeight: true
                                Layout.preferredWidth: size
                                onClicked: documentEditorDialog.open()
                            }
                        }

                        Common.InsideEditor {
                            id: periodEditor

                            width: parent.width
                            height: units.fingerUnit * 20

                            function openPeriodEditor() {
                                loadComponent("annotations2/PeriodEditor", {});
                                open();
                            }

                            onEditorLoaded: item.setContent(showAnnotationItem.periodStart, showAnnotationItem.periodEnd);

                            onAccepted: {
                                var start = item.getStartDateString();
                                var end = item.getEndDateString();
                                annotationsModel.updateObject(identifier, {start: start, end: end});
                                getText();
                                close();
                            }

                            onCancelled: close()
                        }
                    }
                }

                Common.BasicSection {
                    id: titleRect

                    width: partsList.width
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Descripció')

                    ColumnLayout {
                        width: parent.width
                        height: titleText.height + barTitleSeparator.height + contentText.height
                        spacing: 0
                        Text {
                            id: titleText
                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.max(contentHeight, units.fingerUnit)
                            font.pixelSize: units.glanceUnit
                            font.bold: true
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            Common.ImageButton {
                                id: changeTitleButton
                                anchors {
                                    top: parent.top
                                    right: parent.right
                                }
                                size: units.fingerUnit
                                image: 'edit-153612'
                                onClicked: titleDescEditor.openTitleEditor()
                            }
                            text: showAnnotationItem.title
                        }
                        Rectangle {
                            id: barTitleSeparator
                            Layout.fillWidth: true
                            Layout.preferredHeight: 2
                            color: 'black'
                        }
                        Text {
                            id: contentText
                            property int requiredHeight: Math.max(contentHeight, units.fingerUnit) + addDescriptionButton.size + units.fingerUnit

                            Layout.preferredHeight: contentText.requiredHeight
                            Layout.fillWidth: true

                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            onLinkActivated: openAnnotation(link)
                            Common.ImageButton {
                                id: changeDescriptionButton
                                anchors {
                                    top: parent.top
                                    right: parent.right
                                }

                                size: units.fingerUnit
                                image: 'edit-153612'
                                onClicked: titleDescEditor.openDescEditor()
                            }
                            Common.ImageButton {
                                id: addDescriptionButton
                                anchors {
                                    bottom: parent.bottom
                                    right: parent.right
                                }

                                size: units.fingerUnit
                                image: 'plus-24844'
                                onClicked: titleDescEditor.openAppender()
                            }
                        }
                        Files.FileViewer {
                            id: contentImage

                            Layout.preferredHeight: (contentImage.fileURL !== '')?contentImage.width:0
                            //Layout.preferredHeight: (fileURL !== '')?contentImage.requiredHeight:0
                            Layout.fillWidth: true

                            clip: true

                            reloadEnabled: false
                        }
                    }
                    Common.InsideEditor {
                        id: titleDescEditor

                        width: parent.width
                        height: units.fingerUnit * 10
                        property int opc: 0

                        function openTitleEditor() {
                            opc = 1;
                            loadComponent('../editors/TextAreaEditor3', {content: showAnnotationItem.title});
                            open();
                        }

                        function openDescEditor() {
                            opc = 2;
                            loadComponent('../editors/TextAreaEditor3', {content: showAnnotationItem.descText});
                            open();
                        }

                        function openAppender() {
                            opc = 3;
                            loadComponent('../editors/TextAreaEditor3', {content: ""});
                            open();
                        }

                        onAccepted: {
                            switch(opc) {
                            case 1:
                                annotationsModel.updateObject(identifier, {title: getContent()});
                                break;
                            case 2:
                                annotationsModel.updateObject(identifier, {desc: getContent()});
                                break;
                            default:
                                var date = new Date();
                                annotationsModel.updateObject(identifier, {desc: showAnnotationItem.descText + '\n\n**' + date.toLocaleString() + '** ' + getContent().trim()});
                            }

                            getText();
                            close();
                        }

                        onCancelled: close()
                    }
                }

                Common.BasicSection {
                    width: partsList.width
                    height: requiredHeight

                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Continguts')

                    Item {
                        id: wholeContentsArea

                        width: parent.width
                        height: imagePreviewer.height + contentsOptionsRow.height

                        property bool showHotSpots: false

                        ImageFromBlob {
                            id: imagePreviewer

                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }

                            height: width * implicitHeight / Math.max(implicitWidth,1)
                        }

                        Item {
                            id: contentsOptionsRow

                            anchors {
                                top: imagePreviewer.bottom
                                left: parent.left
                                right: parent.right
                            }

                            height: units.fingerUnit

                            RowLayout {
                                anchors.fill: parent

                                Common.ImageButton {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: height
                                    size: units.fingerUnit

                                    image: 'hierarchy-35795'

                                    onClicked: hotSpotsArea.visible = !hotSpotsArea.visible
                                }

                                Common.ImageButton {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: height
                                    size: units.fingerUnit

                                    image: 'edit-153612'

                                    onClicked: importImageDialog.openGallery()
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: imagePreviewer
                            onClicked: {
                                var relX = mouse.x / width;
                                var relY = mouse.y / height;

                                var minimumSqDistance;
                                var minimumConnection;
                                var minimumAnnotation;
                                var minimumDefined = false;

                                // Look for the location closer to (relX,relY)
                                for (var i=0; i<annotationsConnectionsItem.connectionsModelRef.count; i++) {
                                    var connectionObj = annotationsConnectionsItem.connectionsModelRef.getObjectInRow(i);
                                    var parts = connectionObj['location'].split(' ');
                                    if (parts[0] == 'rel') {
                                        var posX = parseFloat(parts[1]);
                                        var posY = parseFloat(parts[2]);

                                        var newDistance = Math.pow((relX - posX), 2) + Math.pow((relY - posY), 2);
                                        if (minimumDefined) {
                                            if (newDistance < minimumSqDistance) {
                                                minimumSqDistance = newDistance;
                                                minimumConnection = connectionObj['id'];
                                                minimumAnnotation = connectionObj['annotationTo'];
                                            }
                                        } else {
                                            minimumSqDistance = newDistance;
                                            minimumConnection = connectionObj['id'];
                                            minimumAnnotation = connectionObj['annotationTo'];
                                            minimumDefined = true;
                                        }
                                    }
                                }

                                if (minimumDefined) {
                                    annotationSelectorItem.reposition(relX, relY);
                                    annotationSelectorItem.select(minimumAnnotation);
                                }
                            }
                        }

                        Item {
                            id: hotSpotsArea
                            anchors.fill: imagePreviewer
                            visible: false

                            Repeater {
                                model: annotationsConnectionsItem.connectionsModelRef

                                Rectangle {
                                    id: hotSpotItem

                                    anchors {
                                        top: parent.top
                                        left: parent.left
                                        leftMargin: hotSpotItem.relativeX * hotSpotsArea.width - hotSpotItem.width / 2;
                                        topMargin: hotSpotItem.relativeY * hotSpotsArea.height - hotSpotItem.height / 2;
                                    }

                                    width: units.fingerUnit
                                    height: units.fingerUnit
                                    radius: units.fingerUnit / 2
                                    border.width: units.nailUnit
                                    border.color: 'black'
                                    color: 'yellow'

                                    property string relativeLocation: model.location
                                    property real relativeX: 0
                                    property real relativeY: 0

                                    function calculateLocation() {
                                        console.log('REL loc', relativeLocation);
                                        var parts = relativeLocation.split(' ');
                                        if ((parts[0] == 'rel') && (parts.length == 3)) {
                                            console.log('computing');
                                            relativeX = parseFloat(parts[1]);
                                            relativeY = parseFloat(parts[2]);
                                            console.log(parts[1], parts[2]);
                                            hotSpotItem.visible = true;
                                        } else {
                                            hotsPotItem.visible = false;
                                        }
                                    }

                                    onRelativeLocationChanged: calculateLocation()
                                }
                            }
                        }


                        Common.BoxedText {
                            id: annotationSelectorItem

                            property int selectedAnnotation: -1

                            anchors {
                                top: imagePreviewer.top
                                horizontalCenter: imagePreviewer.horizontalCenter
                            }

                            width: imagePreviewer.width * 0.8
                            height: units.fingerUnit * 2

                            visible: false

                            margins: units.nailUnit
                            verticalAlignment: Text.AlignVCenter
                            fontSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            elide: Text.ElideRight

                            function reposition(posX, posY) {
                                //anchors.leftMargin = posX * imagePreviewer.width;
                                anchors.topMargin = posY * imagePreviewer.height;
                            }

                            function select(annotation) {
                                var obj = annotationsModel.getObject(annotation);
                                if (obj) {
                                    selectedAnnotation = annotation;
                                    annotationSelectorItem.text = '<b>' + obj['title'] + '</b>&nbsp;' + obj['desc'];
                                    visible = true;
                                }
                            }

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    if (annotationSelectorItem.selectedAnnotation > -1) {
                                        annotationSelectorItem.visible = false;
                                        annotationPreviewDialog.openAnnotationPreview(annotationSelectorItem.selectedAnnotation);
                                        //annotationSelected(annotationSelectorItem.selectedAnnotation);
                                    }
                                }
                            }

                            Common.ImageButton {
                                anchors {
                                    top: parent.top
                                    right: parent.right
                                    bottom: parent.bottom
                                    margins: units.nailUnit
                                }
                                size: units.fingerUnit

                                image: 'road-sign-147409'

                                onClicked: {
                                    annotationSelectorItem.visible = false;
                                }
                            }
                        }
                    }
                }

                Common.BasicSection {
                    width: partsList.width
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Connexions')

                    AnnotationsConnections.AnnotationConnections {
                        id: annotationsConnectionsItem

                        annotationId: showAnnotationItem.identifier

                        width: parent.width
                        height: requiredHeight

                        onAnnotationSelected: {
                            annotationPreviewDialog.openAnnotationPreview(annotation);
                            //showAnnotationItem.annotationSelected(annotation);
                        }
                    }
                }

                Common.BasicSection {
                    width: partsList.width
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Hi referencien')

                    AnnotationsConnections.AnnotationConnections {
                        id: annotationsReversedConnectionsItem

                        reversedConnections: true
                        annotationId: showAnnotationItem.identifier

                        width: parent.width
                        height: requiredHeight

                        onAnnotationSelected: {
                            annotationPreviewDialog.openAnnotationPreview(annotation);
                            //showAnnotationItem.annotationSelected(annotation);
                        }
                    }
                }
            }
        }
    }


    Rectangle {
        id: editorArea
        anchors.fill: parent
        anchors.margins: units.nailUnit
        border.color: 'black'
        enabled: false
        visible: editorArea.enabled

        property var newContent: ''

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: units.nailUnit
            spacing: units.nailUnit

            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                font.pixelSize: units.readUnit
                font.bold: true
                text: qsTr('Editor')
            }
            Loader {
                id: editorLoader

                Layout.fillWidth: true
                Layout.fillHeight: true

                onLoaded: {
                    item.content = editorArea.newContent;
                    item.setChanges(false);
                }
            }
        }

        function showContent(newComponent, newContent) {
            editorArea.newContent = newContent;
            editorLoader.sourceComponent = newComponent;
            editorArea.enabled = true;

            annotationView.pushButtonsModel();
            annotationView.buttonsModel.append({icon: 'floppy-35952', object: annotationView, method: 'saveEditorContents'});
            annotationView.buttonsModel.append({icon: 'road-sign-147409', object: editorArea, method: 'discardEditorContents'});
        }

        function getEditedContent() {
            return editorLoader.item.content;
        }

        function hideEditorContents() {
            editorLoader.sourceComponent = null;
            editorArea.enabled = false;
            annotationView.popButtonsModel();
        }

        /*
        function saveEditorContents() {
            annotationView.saveEditorContents();
        }
*/
    }


    function getText() {
        console.log('identifier is ', showAnnotationItem.identifier);
        if (showAnnotationItem.identifier > -1) {
            annotationsModel.filters = ["id = ?"];
            annotationsModel.bindValues = [showAnnotationItem.identifier];

        } else {
            var today = new Date();
            var filters = [];
            filters.push("title != ''");
            filters.push("(start <= ?) OR (end <= ?)");
            annotationsModel.filters = filters;
            var todayText = today.toYYYYMMDDHHMMFormat();
            var values = [];
            values.push(todayText);
            values.push(todayText);
            annotationsModel.bindValues = values;
            annotationsModel.sort = 'start DESC, end DESC, title DESC';
        }

        annotationsModel.select();
        console.log('annotations with id', showAnnotationItem.identifier, 'count', annotationsModel.count);

        if (annotationsModel.count>0) {
            var obj;
            obj = annotationsModel.getObjectInRow(0);
            startText.text = qsTr('Inici: ') + obj['start'];
            endText.text = qsTr('Final: ') + obj['end'];
            labelsText.text = '# ' + obj['labels'];
            labels = obj['labels'];
            showAnnotationItem.title = obj['title'];
            showAnnotationItem.labels = "" + obj['labels'];
            periodStart = obj['start'];
            periodEnd = obj['end'];

            descText = obj['desc'];
            imagePreviewer.data = obj['contents'];
            contentText.text = parser.toHtml(descText);

            stateValue = obj['state'];
            document = obj['document'];


            console.log('dura', obj['start'], obj['end']);
            if ((obj['start'] !== "") && (obj['end'] !== '')) {
                console.log('calculant durada');
                var startDate = new Date();
                var endDate = new Date();
                startDate.fromYYYYMMDDHHMMFormat(obj['start']);
                endDate.fromYYYYMMDDHHMMFormat(obj['end']);
                periodText.durationInDays = startDate.differenceInDays(endDate);

                console.log('durada', periodText.durationInDays)
            }
        }
    }

    function copyAnnotationDescription() {
        clipboard.copia(showAnnotationItem.descText);
    }

    function rubricAssessmentMenu() {
        console.log('hola');
//        annotationView.openMenu(units.fingerUnit * 2, addRubricMenu, {})
    }

    QClipboard {
        id: clipboard
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
            content: showAnnotationItem.stateValue
        }

        onAccepted: {
            annotationsModel.updateObject(identifier, {state: stateEditor.content});
            getText();
        }
    }

    Common.SuperposedMenu {
        id: documentEditorDialog

        property string selectedDocument: ''

        title: qsTr('Mou a un altre document')
        standardButtons: StandardButton.Save | StandardButton.Cancel

        Documents.DocumentsList {
            width: parent.width
            height: showAnnotationItem.height * 0.8

            onDocumentSelected: documentEditorDialog.selectedDocument = document;
        }

        onAccepted: {
            annotationsModel.updateObject(identifier, {document: documentEditorDialog.selectedDocument});
            getText();
        }
    }

    StandardPaths {
        id: paths
    }

    Common.SuperposedWidget {
        id: importImageDialog

        function openGallery() {
            load(qsTr('Tria imatge'), 'files/Gallery', {folder: "file://" + paths.pictures});
        }

        function openImportImage(file) {
            load(qsTr('Importa imatge'), 'files/ImportImageIntoAnnotation', {annotation: showAnnotationItem.identifier, fileURL: file});
        }

        Connections {
            target: importImageDialog.mainItem

            ignoreUnknownSignals: true

            onFileSelected: {
                importImageDialog.openImportImage(file);
            }

            onImportedFileIntoAnnotation: {
                importImageDialog.close();
                getText();
            }
        }
    }

    Common.SuperposedWidget {
        id: annotationPreviewDialog

        function openAnnotationPreview(annotation) {
            load(qsTr('Previsualitza anotació'), 'annotations2/AnnotationPreview', {identifier: annotation});
        }

        Connections {
            target: annotationPreviewDialog.mainItem
            ignoreUnknownSignals: true

            onAnnotationSelected: {
                annotationPreviewDialog.close();
                showAnnotationItem.annotationSelected(annotation);
            }
        }
    }

    Component.onCompleted: getText()
}
