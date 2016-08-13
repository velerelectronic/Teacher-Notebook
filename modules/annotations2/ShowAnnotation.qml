import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import QtQuick.Dialogs 1.2

import ClipboardAdapter 1.0
import PersonalTypes 1.0

import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import 'qrc:///modules/annotations' as AnnotationsComponents

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
    signal showRelatedAnnotations()
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
                            Text {
                                id: startText
                                height: contentHeight
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.readUnit
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: showRelatedAnnotationsByPeriod();
                                }
                            }
                            Item {
                                width: units.fingerUnit * 2
                            }

                            Item {
                                width: units.fingerUnit * 2
                            }

                            Text {
                                id: endText
                                Layout.preferredHeight: contentHeight
                                Layout.preferredWidth: parent.width / 3
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.readUnit
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: showRelatedAnnotationsByPeriod();
                                }
                            }
                            Common.ImageButton {
                                id: changePeriodButton
                                Layout.fillHeight: true
                                Layout.preferredWidth: size
                                size: units.fingerUnit
                                image: 'edit-153612'
                                onClicked: annotationPeriodSelected(periodStart, periodEnd)
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
                                onClicked: titleEditorDialog.open()
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
                            property int requiredHeight: Math.max(contentHeight, units.fingerUnit)

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
                                onClicked: descEditorDialog.open()
                            }
                        }
                    }
                }

                Common.BasicSection {
                    width: partsList.width
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Anotacions relacionades')

                    Item {
                        id: relatedAnnotationsArea
                        width: parent.width
                        height: units.fingerUnit * 2
                        RowLayout {
                            anchors.fill: parent
                            spacing: units.nailUnit
                            Text {
                                Layout.preferredWidth: units.fingerUnit * 4
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                text: qsTr('Anotacions relacionades')
                            }

                            ListView {
                                id: relatedAnnotationsList
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                orientation: ListView.Horizontal
                                clip: true

                                rightMargin: units.fingerUnit * 3
                                model: annotationsModel

                                spacing: units.nailUnit

                                delegate: Rectangle {
                                    z: 1
                                    width: units.fingerUnit * 6
                                    height: relatedAnnotationsList.height
                                    border.color: 'black'
                                    Text {
                                        anchors.fill: parent
                                        anchors.margins: units.nailUnit
                                        font.pixelSize: units.readUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        elide: Text.ElideRight
                                        text: model.title
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: annotationSelected(model.id)
                                    }
                                }
                                footer: Common.ImageButton {
                                    id: relatedAnnotationsButton
                                    height: relatedAnnotationsList.height
                                    width: relatedAnnotationsButton.height
                                    image: 'arrow-145766'
                                    size: units.fingerUnit * 2
                                    onClicked: showRelatedAnnotations()
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
            contentText.text = parser.toHtml(obj['desc']);
            stateValue = obj['state'];
            document = obj['document'];
        }

        // Look for related annotations in labels and period
        annotationsModel.sort = 'start ASC, end ASC, title ASC';
        var labelsArray = showAnnotationItem.labels.trim().split(' ');
        var labelFilter = [];
        for (var i=0; i<labelsArray.length; i++) {
            labelFilter.push("(INSTR(' '||lower(labels)||' ', ?))");
        }
        var labelFilterString = labelFilter.join(" OR ");

        var periodFilter = "((start <=?) AND (end >= ?))";
        var notitleFilter = "(title != '')"
        var differentTitle = "(title != ?)"

        annotationsModel.filters = [notitleFilter,differentTitle,periodFilter + ((labelFilterString != "")?" OR (" + labelFilterString + ")":'')];
        labelsArray.unshift(showAnnotationItem.periodStart);
        labelsArray.unshift(showAnnotationItem.periodStart);
        labelsArray.unshift(identifier);
        annotationsModel.bindValues = labelsArray;
        console.log("LABELS array",labelsArray);
        annotationsModel.select();
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
        id: titleEditorDialog

        parentWidth: parent.width

        title: qsTr('Edia el títol')
        standardButtons: StandardButton.Save | StandardButton.Cancel

        Editors.TextAreaEditor3 {
            id: titleEditor
            width: parent.width
            content: showAnnotationItem.title;
        }

        onAccepted: {
            annotationsModel.updateObject(identifier, {title: titleEditor.content});
            getText();
        }
    }

    Common.SuperposedMenu {
        id: descEditorDialog

        parentWidth: parent.width

        title: qsTr('Edia la descripció')
        standardButtons: StandardButton.Save | StandardButton.Cancel

        Editors.TextAreaEditor3 {
            id: descEditor
            width: parent.width
            content: showAnnotationItem.descText;
        }

        onAccepted: {
            annotationsModel.updateObject(identifier, {desc: descEditor.content});
            getText();
        }
    }

    Common.SuperposedMenu {
        id: stateEditorDialog

        parentWidth: parent.width

        title: qsTr("Edia l'estat")
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

    Component.onCompleted: getText()
}
