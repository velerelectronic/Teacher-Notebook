import QtQuick 2.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Rectangle {
    id: groupsIndividuals

    property string pageTitle: qsTr('Grups i individus')

    Common.UseUnits {
        id: units
    }

    Models.IndividualsModel {
        id: individualsModel

        sort: 'id DESC'
        Component.onCompleted: select()
    }

    Common.ExpandableListView {
        id: mainList
        anchors.fill: parent

        clip: true
        model: individualsModel

        itemComponent: Rectangle {
            id: singleIndividualItem

            width: mainList.width
            property int requiredHeight: units.fingerUnit * 2
            property var model: individualsModel.fieldNames

            border.color: 'black'
            RowLayout {
                id: row
                anchors {
                    fill: parent
                    margins: units.nailUnit
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: row.width / 4
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: (singleIndividualItem.model.index+1)
                }

                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: row.width / 4
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: singleIndividualItem.model.group
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: row.width / 4
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: singleIndividualItem.model.name
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: row.width / 4
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: singleIndividualItem.model.surname
                }
            }
            MouseArea {
                anchors.fill: row
                onClicked: {
                    console.log('open individual',singleIndividualItem.model.individual);
                    mainList.expandItem(singleIndividualItem.model.index, {individual: singleIndividualItem.model.id});
                }
                onPressAndHold: {
                    individualDeletionAsk.individualName = singleIndividualItem.model.name + " " + singleIndividualItem.model.surname;
                    individualDeletionAsk.individualId = singleIndividualItem.model.id;
                    individualDeletionAsk.open();
                }
            }
        }

        expandedComponent: GroupIndividualEditor {
            groupsIndividualsModel: individualsModel
        }

        Common.SuperposedButton {
            anchors {
                bottom: parent.bottom
                right: parent.right
            }
            size: units.fingerUnit * 2
            imageSource: 'plus-24844'
            onClicked: addIndividual()
        }
    }

    MessageDialog {
        id: individualDeletionAsk
        property string individualName: ''
        property int individualId: -1

        title: qsTr('Esborrar individu')
        text: qsTr("S'esborrarà l'individu «" + individualName + "». Vols continuar?")
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: {
            Qt.inputMethod.hide();
            individualsModel.removeObject(individualId);
            individualsModel.select();
        }
    }

    function addIndividual() {
        individualsModel.insertObject({group: qsTr('Nou grup'), name: qsTr('-'), surname: qsTr('-'), faceImage: ''});
        individualsModel.select();
    }
}

