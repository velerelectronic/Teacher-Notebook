import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import QtQuick.Dialogs 1.2

import ClipboardAdapter 1.0
import PersonalTypes 1.0

import ImageItem 1.0

import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///modules/documents' as Documents
import 'qrc:///modules/calendar' as Calendar
import 'qrc:///modules/files' as Files

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

    property int identifier
    property string title: ''
    property string descText: ''
    property string created: ''
    property string updated: ''
    property int stateValue: 0

    color: 'transparent'

    onIdentifierChanged: getText()

    Common.UseUnits {
        id: units
    }

    SimpleAnnotationsModel {
        id: annotationsModel
        //limit: 6
    }

    MarkDownParser {
        id: parser
    }

    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(titleText.contentHeight, units.fingerUnit * 2) + 2 * units.nailUnit

            color: 'green'

            Text {
                id: titleText

                anchors.fill: parent
                padding: units.nailUnit

                color: 'white'
                font.bold: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: units.readUnit
                elide: Text.ElideRight
                text: showAnnotationItem.title

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
            }
        }

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
                                font.pixelSize: units.readUnit
                                text: qsTr('Modificació:')
                            }

                            Text {
                                Layout.fillWidth: true
                                height: contentHeight
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: units.readUnit
                                elide: Text.ElideRight
                                text: "<p>" + showAnnotationItem.created + "</p><p>" + showAnnotationItem.updated + "</p>"
                            }

                            Item {
                                Layout.fillHeight: true
                                width: units.fingerUnit * 2

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
                        height: contentText.height + contentImage.height
                        spacing: 0

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
                    caption: qsTr('Etiquetes')

                    ListView {
                        width: parent.width
                        height: contentItem.height
                    }
                }

                Common.BasicSection {
                    width: partsList.width
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Marques de temps')

                    Common.GeneralListView {
                        id: timeMarksList

                        width: parent.width
                        height: requiredHeight

                        model: AnnotationTimeMarksModel {
                            id: marksModel

                            function newTimeMark(mark, label, type) {
                                insertObject({annotation: identifier, timeMark: mark, label: label, markType: type});
                                update();
                            }

                            function update() {
                                console.log('uppt');
                                marksModel.filters = ['annotation=?']
                                marksModel.bindValues = [identifier];
                                marksModel.select();
                            }

                            Component.onCompleted: update()
                        }

                        toolBarHeight: 0

                        headingBar: Rectangle {
                            width: timeMarksList.width
                            height: units.fingerUnit
                            color: '#DDDDDD'

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: units.nailUnit
                                spacing: units.nailUnit

                                Text {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: units.readUnit
                                    font.bold: true

                                    text: qsTr("Marca de temps")
                                }

                                Text {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: parent.width / 4

                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: units.readUnit
                                    font.bold: true

                                    text: qsTr("Etiqueta")
                                }

                                Text {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: parent.width / 4

                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: units.readUnit
                                    font.bold: true

                                    text: qsTr("Tipus de marca")
                                }
                            }
                        }

                        footerBar: Item {
                            height: units.fingerUnit * 2
                            width: timeMarksList.width

                            Common.SuperposedButton {
                                anchors.fill: parent
                                size: units.fingerUnit

                                imageSource: 'plus-24844'

                                onClicked: timeEditor.openNewTimeEditor()
                            }
                        }

                        delegate: Rectangle {
                            width: timeMarksList.width
                            height: units.fingerUnit

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: units.nailUnit
                                spacing: units.nailUnit

                                Text {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    text: model.timeMark
                                }

                                Text {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: parent.width / 4

                                    text: model.label
                                }

                                Text {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: parent.width / 4

                                    text: model.markType
                                }
                            }
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
            showAnnotationItem.title = obj['title'];
            descText = obj['desc'];
            created = obj['created'];
            updated = obj['updated'];
            contentText.text = parser.toHtml(descText);

            stateValue = obj['state'];
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

/*
        StateEditor {
            id: stateEditor

            width: parent.width
            height: units.fingerUnit * 3
            content: showAnnotationItem.stateValue
        }
*/

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

    Common.SuperposedWidget {
        id: timeEditor

        function openNewTimeEditor() {
            load(qsTr("Editor de marca de temps"), "simpleannotations/TimeMarkEditor", {})
        }

        Connections {
            target: timeEditor.mainItem

            onSaveTimeMark: {
                marksModel.newTimeMark(timeMark, label, markType);
                timeEditor.close();
            }
        }
    }

    Component.onCompleted: getText()
}