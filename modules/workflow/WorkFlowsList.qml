import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///modules/basic' as Basic

Rectangle {
    id: workFlowsListRect

    Common.UseUnits {
        id: units
    }

    signal workFlowSelected(string title)

    Common.GeneralListView {
        id: workFlowsView

        anchors.fill: parent

        property string selectedWorkFlow: ''

        model: Models.WorkFlows {
            id: workFlowsModel

            sort: 'title ASC'
            limit: 10
            searchFields: ['title', 'desc']

            function update() {
                workFlowsModel.searchString = searchString;

                workFlowsModel.select();
            }
        }

        toolBar: Basic.ButtonsRow {
            id: annotationsListButtons

            color: '#AAFFAA'

            buttonsSpacing: units.fingerUnit

            Common.SearchBox {
                id: searchBox

                height: annotationsListButtons.height
                width: annotationsListButtons.width - height * 2

                text: workFlowsModel.searchString

                onIntroPressed: {
                    workFlowsModel.searchFields = ['title', 'desc', 'document', 'labels'];
                    workFlowsModel.searchString = text;
                    workFlowsModel.update();
                }
            }

            Common.ImageButton {
                height: annotationsListButtons.height
                width: height

                image: 'check-mark-303498'
                onClicked: {
                    workFlowsView.toggleSelection()
                }
            }
        }

        headingBar: Rectangle {
            id: workFlowsHeader

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
                    text: qsTr('Títol')
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: workFlowsHeader.width / 3
                    font.pixelSize: units.readUnit
                    font.bold: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    verticalAlignment: Text.AlignVCenter
                    text: qsTr('Descripció')
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: workFlowsHeader.width / 3
                    font.pixelSize: units.readUnit
                    font.bold: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    verticalAlignment: Text.AlignVCenter
                    text: qsTr('Estats i transicions')
                }
            }
        }

        delegate: Rectangle {
            id: singleWorkFlow

            width: workFlowsView.width
            height: units.fingerUnit * 2

            // Annotation selected: gray
            color: (workFlowsView.selectedWorkFlow == model.title)?'#AAAAAA':'white'

            property string identifier: model.title
            property int statesCount: 0
            property int transitionsCount: 0

            Models.WorkFlowStates {
                id: statesModel

                filters: ['workFlow=?']

                function getStatesCount() {
                    bindValues = [singleWorkFlow.identifier];
                    select();
                    return count;
                }
            }

            RowLayout {
                id: singleWorkFlowLayout

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
                    font.bold: true
                    text: model.title
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: singleWorkFlowLayout.width / 3
                    font.pixelSize: units.readUnit
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    text: model.desc
                }
                Text {
                    id: workFlorExtraText

                    Layout.fillHeight: true
                    Layout.preferredWidth: singleWorkFlowLayout.width / 3
                    font.pixelSize: units.readUnit
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    color: 'green'

                    text: singleWorkFlow.statesCount + " " + qsTr('estats') + "\n" + singleWorkFlow.transitionsCount + " " + qsTr('transicions')
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: workFlowSelected(model.title)
                onPressAndHold: {
                    workFlowsView.selectedWorkFlow = model.title;
                    workFlowsView.enableSelection();
                }
            }

            Component.onCompleted: {
                statesCount = statesModel.getStatesCount();
                transitionsCount = -1;
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
                    text: workFlowsView.selectedWorkFlow
                }

                Common.TextButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: contentWidth
                    text: qsTr('Títol')

                    onClicked: {}
                }
                Common.TextButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: contentWidth
                    text: qsTr('Descripció')
                }

                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height

                    image: 'road-sign-147409'

                    onClicked: {
                        workFlowsView.disableSelection();
                    }
                }
            }
        }

//        footerBar: moreOptionsComponent

        Common.SuperposedButton {
            id: addWorkFlowButton
            anchors {
                right: parent.right
                bottom: parent.bottom
            }
            size: units.fingerUnit * 2
            imageSource: 'plus-24844'
            onClicked: {
                newWorkFlowDialog.load(qsTr('Nou flux de treball'), 'workflow/NewWorkFlow', {workFlowsModel: workFlowsModel});
            }
        }
    }

    Common.SuperposedMenu {
        id: titleEditorDialog

        parentWidth: workFlowsListRect.width

        title: qsTr("Edita el títol")

        standardButtons: StandardButton.Save | StandardButton.Cancel

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
        id: newWorkFlowDialog

        parentWidth: workFlowsListRect.width
        parentHeight: workFlowsListRect.height

        Connections {
            target: newWorkFlowDialog.mainItem

            onNewDrawingAnnotationSelected: {
                newWorkFlowDialog.close();
                newWorkFlowDialog.load(qsTr('Nou dibuix a mà alçada'), 'whiteboard/CompleteWhiteBoard', {selectedFile: document, zoomedRectangle: Qt.rect(0,0,units.fingerUnit * 10, units.fingerUnit * 6)});
                console.log('new drawing', document);
            }

            onAnnotationCreated: {
                newAnnotationDialog.close();
                docAnnotationsRect.annotationSelected(annotation);
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
                docAnnotationsRect.annotationSelected(annotation);
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

    Component.onCompleted: workFlowsModel.update()
}

