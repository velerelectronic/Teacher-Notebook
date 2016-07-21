import QtQuick 2.5
import 'qrc:///common' as Common

Common.ImageButton {
    Common.UseUnits {
        id: units
    }

    width: height
    height: parent.height
    size: units.fingerUnit
    image: model.icon
}
