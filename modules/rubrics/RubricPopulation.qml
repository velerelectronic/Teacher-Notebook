import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import RubricXml 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

Rectangle {
    color: 'gray'

    Common.UseUnits {
        id: units
    }

    property RubricPopulationModel population

    ListView {
        id: populationList
        anchors.fill: parent

        spacing: units.nailUnit

        model: population // population

        clip: true

        delegate: Rectangle {
            width: populationList.width
            height: units.fingerUnit * 2
            RowLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit

                Text {
                    Layout.preferredWidth: parent.width / 4
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: model.identifier
                }
                Text {
                    Layout.preferredWidth: parent.width / 3
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: model.name
                }
                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: model.surname
                }
            }
        }

        Common.SuperposedButton {
            anchors {
                bottom: parent.bottom
                right: parent.right
            }

            imageSource: 'plus-24844'
            size: units.fingerUnit * 2
            margins: units.nailUnit

            onClicked: newIndividualDialog.open()
        }
    }

    Common.SuperposedMenu {
        id: newIndividualDialog

        title: qsTr("Nou individu avaluable")

        standardButtons: StandardButton.Ok | StandardButton.Cancel

        Editors.TextLineEditor {
            id: newIndividualIdentifier
            width: parent.width
            height: units.fingerUnit * 2
        }

        onAccepted: {
            if (newIndividualIdentifier.content !== "")
                population.append(
                            {
                                identifier: newIndividualIdentifier.content,
                                name: newIndividualIdentifier.content,
                                group: '',
                                faceImage: '',
                                surname: ''
                            });
        }
    }
}
