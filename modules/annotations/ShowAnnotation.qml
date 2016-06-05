import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///modules/annotations' as AnnotationsComponents
import ClipboardAdapter 1.0

Item {
    id: showAnnotationItem

    signal annotationSelected(string title)
    signal annotationDescriptionSelected(string description, var widget)
    signal annotationLabelsSelected(string labels)
    signal annotationPeriodSelected(string start, string end)
    signal annotationStateSelected(int stateValue)
    signal annotationTitleSelected(var widget)
    signal attachmentsSelected()
    signal resourceSelected(int resource)
    signal rubricAssessmentSelected(int assessment)
    signal newRubricAssessment(string annotation)
    signal showRelatedAnnotations()
    signal showRelatedAnnotationsByLabels()
    signal showRelatedAnnotationsByPeriod()

    property var sharedObject: null

    property string identifier: ''
    property string descText: ''
    property string labels: ''
    property string periodStart: ''
    property string periodEnd: ''
    property int stateValue: 0

    Common.UseUnits {
        id: units
    }

    Models.ExtendedAnnotations {
        id: relatedAnnotationsSimpleModel
        //limit: 6
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
                        height: Math.max(units.fingerUnit, childrenRect.height)
                        border.color: 'black'

                        GridLayout {
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }

                            columns: 3

                            columnSpacing: units.nailUnit
                            rowSpacing: units.nailUnit

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
                                text: showAnnotationItem.identifier
                                elide: Text.ElideRight
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
                            AnnotationsComponents.StateComponent {
                                id: stateComponent

                                Layout.preferredWidth: units.fingerUnit * 2
                                Layout.preferredHeight: stateComponent.requiredHeight

                                stateValue: showAnnotationItem.stateValue

                                onClicked: {
                                    console.log('edit state');
                                    annotationStateSelected(showAnnotationItem.stateValue);
                                }
                            }
                            Item {
                                width: units.fingerUnit * 2
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
                                onClicked: annotationTitleSelected(changeTitleButton)
                            }
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
                                onClicked: annotationDescriptionSelected(descText, changeDescriptionButton)
                            }
                        }
                    }
                }

                Common.BasicSection {
                    width: partsList.width
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Elements annexos')

                    AnnotationsComponents.AnnotationAttachedItems {
                        id: attachedItemsArea

                        width: parent.width
                        height: units.fingerUnit * 10

                        annotation: showAnnotationItem.identifier

                        onNewRubricAssessment: showAnnotationItem.newRubricAssessment(annotation)
                        onRubricAssessmentSelected: showAnnotationItem.rubricAssessmentSelected(assessment)
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
                                model: relatedAnnotationsSimpleModel

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
                                        onClicked: annotationSelected(model.title)
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
        if (showAnnotationItem.identifier != '') {
            annotationsModel.filters = ["title = ?"];
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
            identifier = obj['title'];
            startText.text = qsTr('Inici: ') + obj['start'];
            endText.text = qsTr('Final: ') + obj['end'];
            labelsText.text = '# ' + obj['labels'];
            labels = obj['labels'];
            titleText.text = showAnnotationItem.identifier;
            showAnnotationItem.labels = "" + obj['labels'];
            periodStart = obj['start'];
            periodEnd = obj['end'];
            descText = obj['desc'];
            contentText.text = parser.toHtml(obj['desc']);
            stateValue = obj['state'];
        }

        // Look for related annotations in labels and period
        relatedAnnotationsSimpleModel.sort = 'start ASC, end ASC, title ASC';
        var labelsArray = showAnnotationItem.labels.trim().split(' ');
        var labelFilter = [];
        for (var i=0; i<labelsArray.length; i++) {
            labelFilter.push("(INSTR(' '||lower(labels)||' ', ?))");
        }
        var labelFilterString = labelFilter.join(" OR ");

        var periodFilter = "((start <=?) AND (end >= ?))";
        var notitleFilter = "(title != '')"
        var differentTitle = "(title != ?)"

        relatedAnnotationsSimpleModel.filters = [notitleFilter,differentTitle,periodFilter + ((labelFilterString != "")?" OR (" + labelFilterString + ")":'')];
        labelsArray.unshift(showAnnotationItem.periodStart);
        labelsArray.unshift(showAnnotationItem.periodStart);
        labelsArray.unshift(identifier);
        relatedAnnotationsSimpleModel.bindValues = labelsArray;
        console.log("LABELS array",labelsArray);
        relatedAnnotationsSimpleModel.select();
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
}
