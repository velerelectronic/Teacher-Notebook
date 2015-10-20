import QtQuick 2.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Rectangle {
    id: groupsIndividuals

    property string pageTitle: qsTr('Grups i individus')

    signal editGroupIndividual(int individual, var groupsIndividualsModel)

    Common.UseUnits {
        id: units
    }

    Models.IndividualsModel {
        id: individualsModel

        sort: 'id DESC'
        Component.onCompleted: select()
    }

    ListView {
        id: mainList
        anchors.fill: parent

        clip: true
        model: individualsModel

        delegate: Rectangle {
            width: mainList.width
            height: units.fingerUnit * 2
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
                    text: (model.index+1)
                }

                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: row.width / 4
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: model.group
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: row.width / 4
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: model.name
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: row.width / 4
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: model.surname
                }
            }
            MouseArea {
                anchors.fill: row
                onClicked: editGroupIndividual(model.id, individualsModel)
                onPressAndHold: {
                    individualDeletionAsk.individualName = model.name + " " + model.surname;
                    individualDeletionAsk.individualId = model.id;
                    individualDeletionAsk.open();
                }
            }
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

