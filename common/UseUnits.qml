import QtQuick 2.2
import QtQuick.Window 2.1

Item {
    id: units
    property int fingerUnit: Screen.pixelDensity * 10
    property int nailUnit: Screen.pixelDensity * 2
    property int glanceUnit: Screen.pixelDensity * 6
    property int readUnit: Screen.pixelDensity * 4
}
