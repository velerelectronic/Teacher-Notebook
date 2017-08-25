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
import 'qrc:///modules/annotations2' as Annotations
import 'qrc:///modules/calendar' as Calendar
import 'qrc:///modules/files' as Files
import 'qrc:///modules/connections' as AnnotationsConnections

Item {
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
    signal annotationUpdated()
    signal annotationCover(var contents)

    property var sharedObject: null

    property int identifier
    property string title: ''
    property string descText: ''
    property string periodStart: ''
    property string periodEnd: ''
    property int stateValue: 0
    property string document: ''
    property string workFlow: ''
    property int workFlowState
    property string workFlowStateTitle: ''

    Common.UseUnits {
        id: units
    }

    Models.WorkFlowAnnotations {
        id: annotationsModel
        //limit: 6
    }

    Models.WorkFlowStates {
        id: statesModel
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

                        ColumnLayout {
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                                margins: units.nailUnit
                            }
                            height: childrenRect.height
                            spacing: units.fingerUnit

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: imagePreviewer.height

                                ImageFromBlob {
                                    id: imagePreviewer
                                    anchors {
                                        top: parent.top
                                        left: parent.left
                                        right: parent.right
                                    }
                                    height: implicitHeight * imagePreviewer.width / Math.max(implicitWidth,1)
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    onClicked: {}
                                }
                            }

                            Text {
                                id: titleText
                                Layout.fillWidth: true
                                Layout.preferredHeight: Math.max(contentHeight, units.fingerUnit)
                                font.pixelSize: units.glanceUnit
                                verticalAlignment: Text.AlignVCenter
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
                                    onClicked: titleEditorDialog.open()
                                }
                                text: showAnnotationItem.title
                            }
                            Text {
                                Layout.fillWidth: true
                                Layout.preferredHeight: contentHeight

                                font.pixelSize: units.readUnit
                                text: '<b>' + workFlowStateTitle + '</b>'+ qsTr(' dins ') + '<b>' + workFlow + '</b>'

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: changeStateDialog.openChangeState(showAnnotationItem.identifier, showAnnotationItem.title, showAnnotationItem.workFlow, showAnnotationItem.workFlowState)
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: childrenRect.height + detailsFlow.anchors.margins * 2

                                color: '#AAAAAA'

                                Flow {
                                    id: detailsFlow

                                    anchors {
                                        top: parent.top
                                        left: parent.left
                                        right: parent.right
                                        margins: units.fingerUnit
                                    }
                                    height: childrenRect.height
                                    spacing: units.fingerUnit

                                    Item {
                                        height: units.fingerUnit
                                        width: childrenRect.width

                                        Row {
                                            anchors {
                                                top: parent.top
                                                left: parent.left
                                                bottom: parent.bottom
                                            }

                                            Text {
                                                id: startText
                                                height: parent.height
                                                width: contentWidth
                                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                                font.pixelSize: units.readUnit
                                                MouseArea {
                                                    anchors.fill: parent
                                                    onClicked: showRelatedAnnotationsByPeriod();
                                                }
                                            }
                                            Text {
                                                id: endText
                                                height: parent.height
                                                width: contentWidth
                                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                                font.pixelSize: units.readUnit
                                                MouseArea {
                                                    anchors.fill: parent
                                                    onClicked: showRelatedAnnotationsByPeriod();
                                                }
                                            }
                                            Common.ImageButton {
                                                id: changePeriodButton
                                                height: parent.height
                                                width: units.fingerUnit
                                                size: units.fingerUnit
                                                image: 'edit-153612'
                                                onClicked: periodEditorDialog.openPeriodEditor()
                                            }

                                        }
                                    }
                                    LabelsList {
                                        height: units.fingerUnit
                                        width: requiredWidth

                                        annotationId: showAnnotationItem.identifier
                                        workFlow: showAnnotationItem.workFlow

                                        onAnnotationLabelsSelected: {}

                                        onAnnotationLabelsUpdated: annotationUpdated()
                                    }
                                    Annotations.StateDisplay {
                                        id: stateComponent

                                        width: units.fingerUnit * 2
                                        height: stateComponent.requiredHeight

                                        stateValue: showAnnotationItem.stateValue

                                        onClicked: stateEditorDialog.open()
                                    }

                                }
                            }


                            Text {
                                id: contentText
                                property int requiredHeight: Math.max(contentHeight, units.fingerUnit) + addDescriptionButton.size + units.fingerUnit

                                Layout.preferredHeight: contentText.requiredHeight
                                Layout.fillWidth: true

                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                onLinkActivated: Qt.openUrlExternally(link)
                                Common.ImageButton {
                                    id: changeDescriptionButton
                                    anchors {
                                        top: parent.top
                                        right: parent.right
                                    }

                                    size: units.fingerUnit
                                    image: 'edit-153612'
                                    onClicked: descEditorDialog.open()
                                }
                                Common.ImageButton {
                                    id: addDescriptionButton
                                    anchors {
                                        bottom: parent.bottom
                                        right: parent.right
                                    }

                                    size: units.fingerUnit
                                    image: 'plus-24844'
                                    onClicked: descAppenderDialog.openAppender()
                                }
                            }

                            Calendar.WeekPeriodDisplay {
                                id: weekPeriodDisplayItem

                                Layout.fillWidth: true
                                Layout.preferredHeight: weekPeriodDisplayItem.requiredHeight
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

                        Connections {
                            target: showAnnotationItem

                            onAnnotationCover: imagePreviewer.data = contents;
                        }
                    }
                }

                Common.BasicSection {
                    id: titleRect

                    width: partsList.width
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Documents')

                    DocumentsList {
                        width: parent.width
                        height: requiredHeight

                        annotationId: identifier

                        onDocumentSourceSelected: imageViewer.showDocument(source)

                        onDocumentContentsSelected: imageViewer.showDocument(contents)

                        onDocumentAdded: annotationUpdated()

                        onDocumentCover: annotationCover(contents)
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
            showAnnotationItem.title = obj['title'];
            periodStart = obj['start'];
            periodEnd = obj['end'];

            weekPeriodDisplayItem.setPeriod(periodStart, periodEnd);

            descText = obj['desc'];
            contentText.text = parser.toHtml(descText);

            stateValue = obj['state'];

            workFlowState = parseInt(obj['workFlowState']);

            console.log('Work flow state', workFlowState);

            var stateObj = statesModel.getObject(workFlowState);
            workFlow = stateObj['workFlow'];
            workFlowStateTitle = stateObj['title'];
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

    MouseArea {
        anchors.fill: parent

        enabled: imageViewer.visible

        onPressed: {
            mouse.accepted = true;
        }

        onClicked: imageViewer.visible = false

        Rectangle {
            anchors.fill: parent
            color: 'black'
            opacity: 0.5

            visible: imageViewer.visible
        }

        Files.ImageBlobViewer {
            id: imageViewer

            anchors.fill: parent
            visible: false

            function showDocument(newContents) {
                contents = newContents;
                reload();
                visible = true;
            }

            onCloseViewer: {
                visible = false;
            }
        }
    }

    Common.SuperposedMenu {
        id: titleEditorDialog

        parentWidth: parent.width

        title: qsTr('Edita el títol')
        standardButtons: StandardButton.Save | StandardButton.Cancel

        Editors.TextAreaEditor3 {
            id: titleEditor
            width: parent.width
            content: showAnnotationItem.title;
        }

        onAccepted: {
            annotationsModel.updateObject(identifier, {title: titleEditor.content});
            getText();
            annotationUpdated();
        }
    }

    Common.SuperposedMenu {
        id: descEditorDialog

        parentWidth: parent.width

        title: qsTr('Edita la descripció')
        standardButtons: StandardButton.Save | StandardButton.Cancel

        Editors.TextAreaEditor3 {
            id: descEditor
            width: parent.width
            content: showAnnotationItem.descText;
        }

        onAccepted: {
            annotationsModel.updateObject(identifier, {desc: descEditor.content});
            getText();
            annotationUpdated();
        }
    }

    Common.SuperposedMenu {
        id: descAppenderDialog

        parentWidth: parent.width

        title: qsTr('Afegeix text a la descripció')

        standardButtons: StandardButton.Save | StandardButton.Cancel

        Editors.TextAreaEditor3 {
            id: extraDescEditor
            width: parent.width
        }

        onAccepted: {
            var date = new Date();
            annotationsModel.updateObject(identifier, {desc: showAnnotationItem.descText + '\n\n**' + date.toLocaleString() + '** ' + extraDescEditor.content.trim()});
            getText();
            annotationUpdated();
        }

        function openAppender() {
            extraDescEditor.content = '';
            open();
        }
    }

    Common.SuperposedMenu {
        id: stateEditorDialog

        parentWidth: parent.width

        title: qsTr("Edita l'estat")
        standardButtons: StandardButton.Save | StandardButton.Cancel

        Annotations.StateEditor {
            id: stateEditor

            width: parent.width
            height: units.fingerUnit * 3
            content: showAnnotationItem.stateValue
        }

        onAccepted: {
            annotationsModel.updateObject(identifier, {state: stateEditor.content});
            getText();
            annotationUpdated();
        }
    }

    Common.SuperposedMenu {
        id: periodEditorDialog

        title: qsTr('Editor de període de temps')

        standardButtons: StandardButton.Save | StandardButton.Cancel

        function openPeriodEditor() {
            periodEditorItem.setContent(periodStart, periodEnd);
            periodEditorDialog.open();
        }

        Annotations.PeriodEditor {
            id: periodEditorItem

            width: parent.width
            height: showAnnotationItem.height * 0.8
        }

        onAccepted: {
            var start = periodEditorItem.getStartDateString();
            var end = periodEditorItem.getEndDateString();
            annotationsModel.updateObject(identifier, {start: start, end: end});
            getText();
            annotationUpdated();
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
            annotationUpdated();
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
                annotationUpdated();
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

    Common.SuperposedWidget {
        id: changeStateDialog

        function openChangeState(annotationId, annotationTitle, parentWorkFlow, workFlowState) {
            load(qsTr('Canvia estat'), 'workflow/ChangeAnnotationState', {annotationId: annotationId, annotationTitle: annotationTitle, initialWorkFlow: parentWorkFlow, initialState: workFlowState});
        }

        Connections {
            target: changeStateDialog.mainItem

            onWorkFlowAnnotationStateChanged: {
                changeStateDialog.close();
                getText();
                annotationUpdated();
            }
        }
    }

    Component.onCompleted: getText()
}
