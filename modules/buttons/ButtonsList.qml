import QtQuick 2.5
import QtQml.Models 2.2
import 'qrc:///common' as Common

ListView {
    id: buttonsList

    default property alias buttons: buttonObjectsModel.children
    property int requiredWidth: contentItem.width

    Common.UseUnits {
        id: units
    }

    spacing: units.fingerUnit
    interactive: false
    orientation: ListView.Horizontal

    model: ObjectModel {
        id: buttonObjectsModel
        property int width: parent.width
        property int height: parent.height
    }
}
