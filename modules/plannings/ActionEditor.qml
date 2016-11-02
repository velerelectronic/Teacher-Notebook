import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import QtQuick.Dialogs 1.2
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import 'qrc:///modules/annotations2' as Annotations

Item {
    id: actionEditorItem

    property int action: -1
    property string fieldValue: ''
    property alias contentsValue: contentsEditor.content
    property string stateValue
    property alias pendingValue: pendingEditor.content
    property int newActionValue

    signal actionSaved()

    Common.UseUnits {
        id: units
    }

    clip: true

    Models.PlanningActionsModel {
        id: actionsModel

        function update() {
            console.log('action', action);
            var object = actionsModel.getObject(action);

            fieldValue = object['field'];
            contentsValue = object['contents'];
            pendingValue = object['pending'];
            stateValue = object['state'];
            newActionValue = object['newAction'];
        }
    }

    ListView {
        id: editorList
        anchors.fill: parent

        spacing: units.nailUnit
        model: ObjectModel {

            GridLayout {
                width: editorList.width
                height: childrenRect.height

                columns: 2

                Text {
                    Layout.preferredWidth: contentWidth
                    Layout.preferredHeight: units.fingerUnit
                    Layout.alignment: Qt.AlignTop

                    font.pixelSize: units.readUnit
                    font.bold: true

                    text: qsTr('Camp')
                }

                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    Layout.alignment: Qt.AlignTop

                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    text: fieldValue
                }

                Text {
                    Layout.preferredWidth: contentWidth
                    Layout.preferredHeight: units.fingerUnit
                    Layout.alignment: Qt.AlignTop

                    font.pixelSize: units.readUnit
                    font.bold: true

                    text: qsTr('Continguts')
                }

                Editors.TextAreaEditor3 {
                    id: contentsEditor

                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 6
                    Layout.alignment: Qt.AlignTop
                }

                Text {
                    Layout.preferredWidth: contentWidth
                    Layout.preferredHeight: units.fingerUnit
                    Layout.alignment: Qt.AlignTop

                    font.pixelSize: units.readUnit
                    font.bold: true

                    text: qsTr('Pendent')
                }

                Editors.TextAreaEditor3 {
                    id: pendingEditor

                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 6
                    Layout.alignment: Qt.AlignTop

                    color: 'red'
                }

                Text {
                    Layout.preferredWidth: contentWidth
                    Layout.preferredHeight: units.fingerUnit
                    Layout.alignment: Qt.AlignTop

                    font.pixelSize: units.readUnit
                    font.bold: true

                    text: qsTr('Estat')
                }

                Flow {
                    id: stateEditor

                    Layout.fillWidth: true
                    Layout.preferredHeight: childrenRect.height

                    spacing: units.fingerUnit

                    Repeater {
                        model: ['open', 'completed', 'discarded']

                        Rectangle {
                            width: stateValueText.width + units.nailUnit * 2
                            height: units.fingerUnit * 1.5

                            color: (stateValue == modelData)?'yellow':'#AAAAAA'

                            Text {
                                id: stateValueText

                                anchors {
                                    left: parent.left
                                    margins: units.nailUnit
                                }
                                anchors.verticalCenter: parent.verticalCenter
                                width: contentWidth

                                font.pixelSize: units.readUnit
                                text: modelData
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: stateValue = modelData
                            }
                        }
                    }
                }

                Text {
                    Layout.preferredWidth: contentWidth
                    Layout.preferredHeight: units.fingerUnit
                    Layout.alignment: Qt.AlignTop

                    font.pixelSize: units.readUnit
                    font.bold: true

                    text: qsTr('Nova acció')
                }

                Text {
                    id: newActionText

                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    Layout.alignment: Qt.AlignTop

                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    text: newActionValue
                }
            }

            Common.Button {
                width: editorList.width
                height: units.fingerUnit

                text: qsTr('Desa')

                onClicked: {
                    actionsModel.updateObject(action, {contents: contentsValue, pending: pendingValue, state: stateValue, newAction: newActionValue});
                    actionsModel.update();
                    actionSaved();
                }
            }

            Common.Button {
                width: editorList.width
                height: units.fingerUnit

                text: qsTr('Esborra')

                onClicked: {
                    confirmDeletionDialog.open();
                }
            }
        }

    }

    MessageDialog {
        id: confirmDeletionDialog

        title: qsTr("Esborrar una acció")

        text: qsTr("Estàs a punt d'esborrar l'acció. Vols continuar?")

        standardButtons: StandardButton.Yes | StandardButton.No

        onYes: {
            actionsModel.removeObject(action);
            actionSaved();
        }
    }

    Component.onCompleted: {
        actionsModel.update();
    }
}
