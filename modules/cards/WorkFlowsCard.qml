import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import 'qrc:///common' as Common
import 'qrc:///models' as Models

BaseCard {
    Common.UseUnits {
        id: units
    }

    signal workFlowsListSelected()

    clip: true

    requiredHeight: units.fingerUnit * 2

    Common.TextButton {
        anchors.fill: parent

        text: qsTr('Diagrames de treball')

        onClicked: workFlowsListSelected()
    }

    function updateContents() {

    }

    Component.onCompleted: updateContents()
}
