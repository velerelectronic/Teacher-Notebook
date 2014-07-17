import QtQuick 2.2
import QtQuick.Window 2.1

Item {
    id: units

    property int dimensioMenor: Math.min(Screen.width,Screen.height)
    property int decimaPart: Math.round(dimensioMenor / 10)
    property int fingerUnit: Screen.pixelDensity * 6
    property int nailUnit: Screen.pixelDensity * 1
    property int glanceUnit: Screen.pixelDensity * 6
    property int readUnit: Screen.pixelDensity * 3
    property int smallReadUnit: Screen.pixelDensity * 2
    property int titleReadUnit: Screen.pixelDensity * 4

    // Paper
    property int widthA4: Screen.pixelDensity * 210
    property int heightA4: Screen.pixelDensity * 297
    property int widthA5: Screen.pixelDensity * 148
    property int heightA5: Screen.pixelDensity * 210
    property int maximumReadWidth: widthA5

    // Fluent margins
    function fluentMargins(refDimension, minimum) {
        return Math.max(Math.round(refDimension / 50), minimum);
    }
}
