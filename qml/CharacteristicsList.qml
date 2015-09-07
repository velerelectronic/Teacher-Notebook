import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors


Rectangle {
    id: characteristicsMainItem

    property string pageTitle: qsTr('Característiques')

    property int project

    signal importData(var fieldNames, var fieldConstants, var writeModel)

    Common.UseUnits {
        id: units
    }

    Models.CharacteristicsModel {
        id: characteristicsModel

        filters: ["ref='" + project + "'"]
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit
        spacing: units.nailUnit

        Text {
            id: projectInfo
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2
        }

        ListView {
            id: characteristicsList
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true

            model: characteristicsModel

            headerPositioning: ListView.OverlayHeader
            header: Rectangle {
                width: characteristicsList.width
                height: units.fingerUnit
                color: 'green'
                z: 2

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    Text {
                        Layout.preferredWidth: characteristicsList.width / 2
                        Layout.preferredHeight: units.fingerUnit
                        font.bold: true
                        font.pixelSize: units.readUnit
                        color: 'white'
                        text: qsTr('Títol')
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit
                        font.bold: true
                        font.pixelSize: units.readUnit
                        color: 'white'
                        text: qsTr('Descripció')
                    }
                }
            }

            delegate: Rectangle {
                id: characteristicRectangle
                width: characteristicsList.width
                height: units.fingerUnit * 2
                z: 1
                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Common.BoxedText {
                        Layout.preferredWidth: characteristicRectangle.width / 2
                        Layout.fillHeight: true
                        margins: units.nailUnit
                        fontSize: units.readUnit
                        text: model.title
                    }

                    Common.BoxedText {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        margins: units.nailUnit
                        fontSize: units.readUnit
                        text: model.desc
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onPressAndHold: {
                        deleteCharacteristicDialog.characteristicId = model.id;
                        deleteCharacteristicDialog.characteristicString = model.title + " " + model.desc
                        deleteCharacteristicDialog.open();
                    }
                }
            }

            Component.onCompleted: {
                characteristicsModel.select();
            }

            Common.SuperposedButton {
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }
                size: units.fingerUnit * 2
                imageSource: 'plus-24844'
                onClicked: characteristicsMainItem.importData(['title','desc'],[{name: 'ref', value: project}],characteristicsModel)
            }
        }
    }

    MessageDialog {
        id: deleteCharacteristicDialog

        property string characteristicString: ''
        property string characteristicId
        title: qsTr('Eliminar característica')
        text: qsTr("Vols continuar per eliminar la característica?")
        informativeText: qsTr("Si acceptes, s'eliminarà la característica «" + characteristicString + "»")
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: {
            characteristicsModel.removeObjectWithKeyValue(characteristicId);
            characteristicsModel.select();
        }
    }

    onProjectChanged: getProjectTitle()

    function getProjectTitle() {
        if (typeof project !== null) {
            var obj = globalProjectsModel.getObject(project);
            projectInfo.text = obj['name'] + ' ' + obj['desc'];

        }
    }
}
