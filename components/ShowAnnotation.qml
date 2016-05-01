import QtQuick 2.5
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///components' as Components
import ClipboardAdapter 1.0

Item {
    id: showAnnotationItem

    signal annotationSelected(string title)
    signal annotationDescriptionSelected(string description)
    signal annotationLabelsSelected(string labels)
    signal annotationPeriodSelected(string start, string end)
    signal annotationStateSelected(int stateValue)
    signal annotationTitleSelected()
    signal rubricAssessmentSelected(int assessment)
    signal resourceSelected(int resource)
    signal showRelatedAnnotations()
    signal showRelatedAnnotationsByLabels()
    signal showRelatedAnnotationsByPeriod()

    property string identifier: ''
    property string descText: ''
    property string labels: ''
    property string periodStart: ''
    property string periodEnd: ''
    property int stateValue: 0

    Models.ExtendedAnnotations {
        id: relatedAnnotationsSimpleModel
        //limit: 6
    }

    Models.RubricsAssessmentModel {
        id: rubricsAssessmentModel
        filters: ["annotation=?"]
    }

    Models.ResourcesModel {
        id: resourcesModel
        filters: ["annotation=?"]
    }

    ListModel {
        id: attachedItems
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit
            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: units.readUnit
                text: showAnnotationItem.identifier
                elide: Text.ElideRight
            }
        }

        Flickable {
            id: flickableText
            Layout.fillHeight: true
            Layout.fillWidth: true
            contentHeight: groupAnnotationItem.height
            contentWidth: groupAnnotationItem.width
            clip: true

            visible: flickableText.enabled
            enabled: !editorArea.enabled

            Item {
                id: groupAnnotationItem

                property int interspacing: units.nailUnit
                width: flickableText.width
                height: Math.max(headerData.height + titleRect.height + contentText.requiredHeight + 2 * groupAnnotationItem.interspacing, flickableText.height)

                ColumnLayout {
                    anchors.fill: parent
                    spacing: groupAnnotationItem.interspacing

                    Rectangle {
                        id: headerData
                        Layout.preferredHeight: Math.max(startText.height, endText.height, labelsText.height, stateComponent.height, units.fingerUnit) + 2 * units.nailUnit
                        Layout.fillWidth: true
                        border.color: 'black'

                        MouseArea {
                            anchors.fill: parent
                            onClicked: annotationSelected(showAnnotationItem.identifier)
                        }
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            spacing: units.nailUnit
                            Common.ImageButton {
                                id: changePeriodButton
                                Layout.fillHeight: true
                                Layout.preferredWidth: size
                                size: units.fingerUnit
                                image: 'edit-153612'
                                onClicked: annotationPeriodSelected(periodStart, periodEnd)
                            }

                            Text {
                                id: startText
                                Layout.preferredHeight: contentHeight
                                Layout.preferredWidth: parent.width / 3
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.readUnit
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: showRelatedAnnotationsByPeriod();
                                }
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
                                id: changeLabelsButton
                                image: 'edit-153612'
                                size: units.fingerUnit
                                Layout.fillHeight: true
                                Layout.preferredWidth: size
                                onClicked: annotationLabelsSelected(showAnnotationItem.labels)
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

                            Components.StateComponent {
                                id: stateComponent

                                Layout.preferredWidth: units.fingerUnit * 2
                                Layout.preferredHeight: stateComponent.requiredHeight

                                stateValue: showAnnotationItem.stateValue

                                onClicked: {
                                    console.log('edit state');
                                    annotationStateSelected(showAnnotationItem.stateValue);
                                }
                            }
                        }
                    }

                    Item {
                        id: titleRect

                        Layout.preferredHeight: titleText.height + 2
                        Layout.fillWidth: true

                        Text {
                            id: titleText
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }

                            height: Math.max(contentHeight, units.fingerUnit)
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
                                onClicked: annotationTitleSelected()
                            }
                        }
                        Rectangle {
                            anchors {
                                top: titleText.bottom
                                left: parent.left
                                right: parent.right
                            }
                            height: 2
                            color: 'black'
                        }

                    }

                    Text {
                        id: contentText
                        property int requiredHeight: Math.max(contentHeight, units.fingerUnit)

                        Layout.fillHeight: true
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
                            onClicked: annotationDescriptionSelected(descText)
                        }
                    }
                }
            }

        }
        Item {
            id: rubricsArea

            Layout.fillWidth: true
            Layout.preferredHeight: (rubricsAssessmentModel.count>0)?units.fingerUnit * 2:0

            ListView {
                id: rubricsAnnotationInfo

                anchors.fill: parent
                orientation: ListView.Horizontal

                model: attachedItems
                spacing: units.nailUnit
                delegate: Common.BoxedText {
                    height: rubricsAnnotationInfo.height
                    width: units.fingerUnit * 6
                    text: model.visualTitle
                    margins: units.nailUnit
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            switch(model.type) {
                            case 'rubric':
                                annotationView.openPageArgs('RubricsModule', {rubricAssessmentIdentifier: model.identifier});
                                break;
                            case 'resource':
                                annotationView.openPageArgs('ResourcesModule', {resourceId: model.identifier, state: 'displaySource'});
                                break;
                            default:
                                break;
                            }
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2
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
        console.log('gt text');
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

        // Get rubrics
        attachedItems.clear();
        rubricsAssessmentModel.bindValues = [showAnnotationItem.identifier];
        rubricsAssessmentModel.select();

        for (var i=0; i<rubricsAssessmentModel.count; i++) {
            var rubricObj = rubricsAssessmentModel.getObjectInRow(i);
            attachedItems.append({type: 'rubric', visualTitle: rubricObj.title + " (" + rubricObj.group + ")", identifier: rubricObj.id});
        }

        // Get resources
        resourcesModel.bindValues = [showAnnotationItem.identifier];
        resourcesModel.select();

        for (var i=0; i<resourcesModel.count; i++) {
            var resourceObj = resourcesModel.getObjectInRow(i);
            attachedItems.append({type: 'resource', visualTitle: resourceObj.title, identifier: resourceObj.id});
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
