import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.0

import ClipboardAdapter 1.0
import PersonalTypes 1.0

import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import 'qrc:///modules/documents' as Documents
import 'qrc:///modules/calendar' as Calendar
import 'qrc:///modules/files' as Files

Rectangle {
    id: annotationsListRect

    Common.UseUnits {
        id: units
    }

    property int maximumHeight

    height: Math.min(maximumHeight, requiredHeight)

    property string parentWorkFlow: ''
    property int workFlowState: -1
    property int headingsHeight
    property real annotationDetailsHeight: units.fingerUnit / 2

    property string searchString: ''

    signal workFlowAnnotationSelected(int annotation)
    signal workFlowUpdateRequested()

    border.color: 'black'
    color: '#DDDDDD'

    property int requiredHeight: stateHeading.height + annotationsList.contentItem.height + annotationsList.topMargin + annotationsList.bottomMargin + movingFooter.height

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        spacing: 0

        Common.BoxedText {
            id: stateHeading
            Layout.fillWidth: true
            Layout.preferredHeight: headingsHeight

            margins: units.nailUnit

            color: '#AAFFAA'

            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            boldFont: true

            text: model.title

            MouseArea {
                anchors.fill: parent
                onClicked: stateTitleEditorDialog.openEditor(singleStateRect.stateId, model.title);
            }
        }

        ListView {
            id: annotationsList

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            model: annotationsModel
            spacing: units.nailUnit
            topMargin: units.nailUnit * 2
            bottomMargin: units.nailUnit * 2
            leftMargin: units.nailUnit * 2
            rightMargin: units.nailUnit * 2

            ScrollBar.vertical: ScrollBar {
                active: true
            }

            boundsBehavior: ListView.StopAtBounds

            Models.WorkFlowAnnotations {
                id: annotationsModel

                filters: ['workFlowState=?']

                searchFields: ['title', 'desc']
                searchString: annotationsListRect.searchString

                function addAnnotation(title, desc) {
                    insertObject({title: title, desc: desc, workFlowState: annotationsListRect.workFlowState});
                    update();
                }

                function update() {
                    bindValues = [annotationsListRect.workFlowState];
                    select();
                }

                Component.onCompleted: update()
            }

            delegate: Rectangle {
                id: singleAnnotationItem

                width: annotationsList.width - annotationsList.leftMargin - annotationsList.rightMargin
                height: annotationColumn.height + units.nailUnit * 2

                radius: units.nailUnit
                clip: true

                property int annotationId: model.id
                property string desc: model.desc
                property string start: model.start
                property string end: model.end
                property int stateValue: model.state

                Column {
                    id: annotationColumn

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: units.nailUnit
                    }

                    spacing: units.nailUnit
                    height: annotationText.height + annotationDetails.height + spacing

                    Text {
                        id: annotationText

                        height: Math.max(units.fingerUnit, annotationText.contentHeight)
                        width: parent.width

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        verticalAlignment: Text.AlignVCenter

                        text: model.title
                    }

                    Flow {
                        id: annotationDetails

                        height: Math.max(0,childrenRect.height)
                        width: parent.width
                        spacing: units.nailUnit

                        Component.onCompleted: {
                            // Show details

                            // Does the annotation have a description?
                            if (singleAnnotationItem.desc !== '') {
                                descIndicatorComponent.createObject(annotationDetails);
                            }

                            // Does the annotation have dates defined?
                            if ((singleAnnotationItem.start !== '') || (singleAnnotationItem.end !== '')) {
                                timeIndicatorComponent.createObject(annotationDetails, {text: singleAnnotationItem.start + "-" + singleAnnotationItem.end});
                            }

                            // Which is the annotation state?
                            if ((typeof singleAnnotationItem.stateValue !== null) && (singleAnnotationItem.stateValue !== 0)) {
                                stateIndicatorComponent.createObject(annotationDetails, {stateValue: singleAnnotationItem.stateValue});
                            }

                            // Which are the labels?
                            labelsComponent.createObject(annotationDetails, {annotationId: singleAnnotationItem.annotationId});

                            // Does the annotation have documents?
                            if (documentsModel.getDocumentsCount() > 0) {
                                documentsComponent.createObject(annotationDetails);
                            }

                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: workFlowAnnotationSelected(model.id)
                    onPressAndHold: changeStateDialog.openChangeState(model.id, model.title, parentWorkFlow, model.workFlowState)
                }

                Models.WorkFlowAnnotationDocuments {
                    id: documentsModel

                    filters: ['annotation=?']

                    function getDocumentsCount() {
                        bindValues = [model.id];
                        select();
                        return count;
                    }
                }
            }

        }

        Item {
            id: movingFooter

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2

            Common.BoxedText {
                anchors.fill: parent

                color: '#AAFFAA'
                margins: units.nailUnit

                text: qsTr('Afegeix anotació...')

                MouseArea {
                    anchors.fill: parent
                    onClicked: newAnnotationDialog.openNewAnnotation()
                }
            }
        }

    }

    Component {
        id: descIndicatorComponent

        Common.ImageButton {
            image: 'comment-27179'
            height: size
            width: size
            size: annotationDetailsHeight
        }
    }

    Component {
        id: timeIndicatorComponent

        Text {
            height: annotationDetailsHeight
            font.pixelSize: annotationDetailsHeight
            width: contentWidth
        }
    }

    Component {
        id: stateIndicatorComponent

        StateDisplay {
            width: annotationDetailsHeight
            height: width
        }
    }

    Component {
        id: labelsComponent

        LabelsList {
            width: requiredWidth
            height: annotationDetailsHeight

            simple: true

            workFlow: parentWorkFlow
        }
    }

    Component {
        id: documentsComponent

        Common.ImageButton {
            image: 'paper-clip-27821'
            height: size
            width: size
            size: annotationDetailsHeight
        }
    }

    Common.SuperposedWidget {
        id: newAnnotationDialog

        function openNewAnnotation() {
            load(qsTr('Nova anotació'), 'workflow/GetTitleDialog', {});
        }

        Connections {
            target: newAnnotationDialog.mainItem

            onAcceptedTitle: {
                var newTitle = title;
                newAnnotationDialog.close();
                var re = new RegExp("^(.*)(?:\\n*)(.*(?:.|\\n)*)?$", "g");
                var result = re.exec(newTitle);
                annotationsModel.addAnnotation(result[1], result[2]);
            }
            onCanceledTitle: newAnnotationDialog.close()
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
                workFlowUpdateRequested();
            }
        }
    }

    function update() {
        annotationsModel.update()
    }
}

