import QtQuick 2.7
import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

import 'qrc:///common' as Common
import 'qrc:///models' as Models

Rectangle {
    Common.UseUnits {
        id: units
    }

    Models.WorkFlows {
        id: workFlowsModel
    }

    property int annotationId: -1
    property string annotationTitle: ''
    property string initialWorkFlow: ''
    property int initialState: -1

    signal workFlowAnnotationStateChanged(int annotation, int state)

    Models.WorkFlowStates {
        id: workFlowStatesModel

        filters: ['workFlow=?']
    }

    Models.WorkFlowAnnotations {
        id: annotationsModel
    }

    Grid {
        anchors.fill: parent

        spacing: units.fingerUnit
        columns: 2
        rows: 4

        Text {
            Layout.preferredHeight: units.fingerUnit
            width: contentWidth
            text: qsTr('Anotació')
        }

        Text {
            id: annotationText

            Layout.preferredHeight: units.fingerUnit
            Layout.fillWidth: true
            text: annotationTitle
        }

        Text {
            Layout.preferredHeight: units.fingerUnit
            width: contentWidth
            text: qsTr('Flux de treball')
        }

        ComboBox {
            id: workFlowSelector

            Layout.preferredHeight: units.fingerUnit
            Layout.fillWidth: true

            model: ListModel {
                id: workFlowsListModel
            }

            onActivated: calculateStates(index)

            Component.onCompleted: {
                var selected = -1;
                workFlowsListModel.clear();

                workFlowsModel.select();
                for (var i=0; i<workFlowsModel.count; i++) {
                    var obj = workFlowsModel.getObjectInRow(i);

                    console.log('compare', obj['title'], initialWorkFlow);
                    if (obj['title'] == initialWorkFlow) {
                        selected = i;
                    }
                    workFlowsListModel.append({text: obj['title']});
                }
                if (selected > -1) {
                    workFlowSelector.currentIndex = selected;
                    calculateStates(selected);
                }

            }

            function calculateStates(index) {
                statesListModel.clear();
                var workFlowId = workFlowsModel.getObjectInRow(index)['title'];

                workFlowStatesModel.bindValues = [workFlowId];
                workFlowStatesModel.select();

                for (var i=0; i<workFlowStatesModel.count; i++) {
                    var obj = workFlowStatesModel.getObjectInRow(i);
                    statesListModel.append({text: "(" + obj['id'] + ")" + obj['title']});
                }
            }
        }

        Text {
            Layout.preferredHeight: units.fingerUnit
            width: contentWidth
            text: qsTr('Estat')
        }

        ComboBox {
            id: stateSelector

            Layout.preferredHeight: units.fingerUnit
            Layout.fillWidth: true

            model: ListModel {
                id: statesListModel
            }
        }

        Item {
            Layout.preferredHeight: units.fingerUnit
            Layout.fillWidth: true
        }

        Button {
            Layout.preferredHeight: units.fingerUnit
            Layout.fillWidth: true

            text: qsTr('Canvia')

            onClicked: {
                var newStateId = parseInt(workFlowStatesModel.getObjectInRow(stateSelector.currentIndex)['id']);
                annotationsModel.updateObject(annotationId, {workFlowState: newStateId});
                workFlowAnnotationStateChanged(annotationId, newStateId);
            }
        }
    }
}
