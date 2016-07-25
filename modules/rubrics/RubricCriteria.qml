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

    property RubricCriteriaModel criteria

    ListView {
        id: criteriaList
        anchors.fill: parent

        spacing: units.nailUnit

        model: criteria

        clip: true

        delegate: Rectangle {
            width: criteriaList.width
            height: units.fingerUnit * 2
            RowLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit

                Text {
                    Layout.preferredWidth: parent.width / 5
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: model.identifier
                }
                Text {
                    Layout.preferredWidth: parent.width / 5
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: model.title
                }
                Text {
                    Layout.preferredWidth: parent.width / 5
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: model.description
                }
                Text {
                    Layout.preferredWidth: parent.width / 5
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: model.weight
                }
                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: model.order
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

            onClicked: newCriteriumDialog.open()
        }
    }

    Common.SuperposedMenu {
        id: newCriteriumDialog

        title: qsTr("Nou criteri d'avaluació")

        standardButtons: StandardButton.Ok | StandardButton.Cancel

        Editors.TextLineEditor {
            id: newCriteriumIdentifier
            width: parent.width
            height: units.fingerUnit * 2
        }

        onAccepted: {
            if (newCriteriumIdentifier.content !== '')
                criteria.append({identifier: newCriteriumIdentifier.content, title: newCriteriumIdentifier.content, description: '', score: '', weight: 1});
        }
    }

}
