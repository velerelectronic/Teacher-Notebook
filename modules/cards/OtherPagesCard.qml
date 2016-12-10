import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0
import 'qrc:///models' as Models
import 'qrc:///common' as Common

BaseCard {
    requiredHeight: units.fingerUnit * 2

    Common.UseUnits {
        id: units
    }

    Common.BoxedText {
        anchors.fill: parent

        text: qsTr('Obre una altra pàgina')

        MouseArea {
            anchors.fill: parent
            onClicked: newSectionDialog.openNewSection()
        }
    }

    Common.SuperposedWidget {
        id: newSectionDialog

        parentWidth: Screen.width
        parentHeight: Screen.height

        function openNewSection() {
            load(qsTr('Nova secció'), 'pagesfolder/NewSectionDialog', {})
            newSectionConnections.target = newSectionDialog.mainItem;
        }

        Connections {
            id: newSectionConnections

            onAddPage: {
                newSectionDialog.close();
                selectedPage(page, parameters, title);
            }
        }
    }

}
