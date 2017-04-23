import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import QtQuick.Dialogs 1.2

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

    property string parentWorkFlow: ''
    property int workFlowState: -1
    property real annotationDetailsHeight: units.fingerUnit / 2

    signal workFlowAnnotationSelected(int annotation)
    signal workFlowUpdateRequested()

    border.color: 'black'
    color: '#DDDDDD'

    property int requiredHeight: annotationsList.contentItem.height + annotationsList.topMargin + annotationsList.bottomMargin

    ListView {
        id: annotationsList

        anchors.fill: parent

        clip: true
        model: annotationsModel
        spacing: units.nailUnit
        topMargin: units.nailUnit
        bottomMargin: units.fingerUnit * 2 + units.nailUnit
        leftMargin: units.nailUnit
        rightMargin: units.nailUnit

        boundsBehavior: ListView.StopAtBounds

        Models.WorkFlowAnnotations {
            id: annotationsModel

            filters: ['workFlowState=?']

            function addAnnotation() {
                insertObject({title: qsTr('Nova anotació'), workFlowState: annotationsListRect.workFlowState});
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

            clip: true

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

                    Component.onCompleted: {
                        if (singleAnnotationItem.desc !== '') {
                            descIndicatorComponent.createObject(annotationDetails);
                        }
                        if ((singleAnnotationItem.start !== '') || (singleAnnotationItem.end !== '')) {
                            timeIndicatorComponent.createObject(annotationDetails);
                        }
                        if ((typeof singleAnnotationItem.stateValue !== null) && (singleAnnotationItem.stateValue !== 0)) {
                            stateIndicatorComponent.createObject(annotationDetails, {stateValue: singleAnnotationItem.stateValue});
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: workFlowAnnotationSelected(model.id)
                onPressAndHold: changeStateDialog.openChangeState(model.id, model.title, parentWorkFlow, model.workFlowState)
            }
        }

        Item {
            id: movingFooter

            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            height: units.fingerUnit * 2

            Common.BoxedText {
                anchors.fill: parent

                color: '#AAFFAA'
                margins: units.nailUnit

                text: qsTr('Afegeix anotació...')

                MouseArea {
                    anchors.fill: parent
                    onClicked: annotationsModel.addAnnotation()
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

        Common.ImageButton {
            image: 'hourglass-23654'
            height: size
            width: size
            size: annotationDetailsHeight
        }
    }

    Component {
        id: stateIndicatorComponent

        StateDisplay {
            width: annotationDetailsHeight
            height: width
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
}

