import QtQuick 2.7
import QtQml.Models 2.2
import 'qrc:///common' as Common

Rectangle {
    id: buttonsRowItem

    default property alias buttons: buttonsModel.children

    property int margins: units.nailUnit
    property int buttonsSpacing: units.fingerUnit

    height: units.fingerUnit * 2 + margins * 2

    Common.UseUnits {
        id: units
    }

    ListView {
        anchors.fill: parent
        anchors.margins: buttonsRowItem.margins

        orientation: ListView.Horizontal
        boundsBehavior: ListView.StopAtBounds

        model: ObjectModel {
            id: buttonsModel
        }

        spacing: buttonsSpacing
    }
}

