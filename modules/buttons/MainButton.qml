import QtQuick 2.5
import 'qrc:///common' as Common

Common.ImageButton {
    objectName: 'MainButton'
    Common.UseUnits {
        id: units
    }


    property string icon: ''
    width: height
//    height: parent.height
    size: units.fingerUnit * 2
    image: icon
}
